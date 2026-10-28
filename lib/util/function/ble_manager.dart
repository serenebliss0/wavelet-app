import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleManager {
  // ─────────────────────────────────────────────────────────────────────────
  // Wavelet UUIDs
  // ─────────────────────────────────────────────────────────────────────────

  static const String waveletServiceUuid =
      "4fafc201-1fb5-459e-8fcc-c5c9c331914b";

  static const String deviceInfoUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  static const String commandUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  static const String wifiSsidUuid = "beb5483e-36e1-4688-b7f5-ea07361b26aa";

  static const String wifiPasswordUuid = "beb5483e-36e1-4688-b7f5-ea07361b26ab";

  static const String statusUuid = "beb5483e-36e1-4688-b7f5-ea07361b26ac";

  static const String deviceNameUuid = "beb5483e-36e1-4688-b7f5-ea07361b26ad";
  static const String spotifyTokenUuid = "beb5483e-36e1-4688-b7f5-ea07361b26ae";

  // ─────────────────────────────────────────────────────────────────────────
  // Connection
  // ─────────────────────────────────────────────────────────────────────────

  BluetoothDevice? device;

  BluetoothCharacteristic? deviceInfo;
  BluetoothCharacteristic? command;
  BluetoothCharacteristic? wifiSsid;
  BluetoothCharacteristic? wifiPassword;
  BluetoothCharacteristic? status;
  BluetoothCharacteristic? deviceName;
  BluetoothCharacteristic? spotifyToken;

  bool get isConnected => device?.isConnected ?? false;
  bool _autoReconnectEnabled = false;
  bool _intentionalDisconnect = false;
  bool _connecting = false;
  bool _discovering = false;
  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  String? lastStatus;

  // Status stream
  StreamSubscription<List<int>>? _statusSubscription;

  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  Stream<String> get statusStream => _statusController.stream;

  // ─────────────────────────────────────────────────────────────────────────
  // Connect
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> connect(
    BluetoothDevice selectedDevice, {
    bool autoReconnect = true,
    bool requireWifi = false,
  }) async {
    if (device?.remoteId == selectedDevice.remoteId &&
        selectedDevice.isConnected &&
        command != null) {
      _autoReconnectEnabled = autoReconnect;
      return;
    }

    await _detachCurrentDevice();
    device = selectedDevice;
    _autoReconnectEnabled = autoReconnect;
    _intentionalDisconnect = false;
    _reconnectAttempt = 0;
    _listenForConnection(selectedDevice, requireWifi: requireWifi);

    try {
      await _connectAndDiscover(selectedDevice, requireWifi: requireWifi);
    } catch (error) {
      _autoReconnectEnabled = false;
      await _detachCurrentDevice();
      rethrow;
    }
  }

  Future<void> reconnectFromId(String remoteId, {bool requireWifi = false}) =>
      connect(
        BluetoothDevice.fromId(remoteId),
        autoReconnect: true,
        requireWifi: requireWifi,
      );

  void _listenForConnection(
    BluetoothDevice target, {
    required bool requireWifi,
  }) {
    _connectionSubscription?.cancel();
    _connectionSubscription = target.connectionState.listen((state) {
      if (device?.remoteId != target.remoteId) return;
      if (state == BluetoothConnectionState.disconnected) {
        _clearCharacteristics();
        if (_autoReconnectEnabled && !_intentionalDisconnect) {
          _scheduleReconnect(target, requireWifi: requireWifi);
        }
      } else if (state == BluetoothConnectionState.connected &&
          !_connecting &&
          !_discovering &&
          command == null) {
        unawaited(_discoverServices(requireWifi: requireWifi));
      }
    });
  }

  Future<void> _connectAndDiscover(
    BluetoothDevice target, {
    required bool requireWifi,
  }) async {
    if (_connecting) return;
    _connecting = true;
    try {
      if (!target.isConnected) {
        await target.connect(timeout: const Duration(seconds: 15));
      }
      await target.connectionState
          .firstWhere((state) => state == BluetoothConnectionState.connected)
          .timeout(const Duration(seconds: 15));
      await _discoverServices(requireWifi: requireWifi);
    } finally {
      _connecting = false;
    }
  }

  void _scheduleReconnect(BluetoothDevice target, {required bool requireWifi}) {
    if (_reconnectTimer != null || !_autoReconnectEnabled) return;
    const delays = [1, 2, 4, 8, 15];
    final delay = delays[_reconnectAttempt.clamp(0, delays.length - 1)];
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: delay), () async {
      _reconnectTimer = null;
      if (!_autoReconnectEnabled ||
          _intentionalDisconnect ||
          device?.remoteId != target.remoteId ||
          target.isConnected) {
        return;
      }
      try {
        await _connectAndDiscover(target, requireWifi: requireWifi);
        _reconnectAttempt = 0;
      } catch (_) {
        _scheduleReconnect(target, requireWifi: requireWifi);
      }
    });
  }

  Future<void> _detachCurrentDevice() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    final current = device;
    _clearCharacteristics();
    if (current != null && current.isConnected) {
      try {
        await current.disconnect();
      } catch (_) {
        // The peripheral may already have dropped the connection.
      }
    }
    device = null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Discover services and characteristics
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _discoverServices({bool requireWifi = false}) async {
    if (_discovering) return;
    _discovering = true;
    try {
      await _discoverServicesInternal(requireWifi: requireWifi);
    } finally {
      _discovering = false;
    }
  }

  Future<void> _discoverServicesInternal({required bool requireWifi}) async {
    if (device == null) {
      throw Exception('No Bluetooth device connected');
    }

    print('[BLE] Discovering services...');

    final services = await device!.discoverServices();

    BluetoothService? waveletService;

    for (final service in services) {
      print('[BLE] Service: ${service.uuid}');

      if (service.uuid.toString().toLowerCase() ==
          waveletServiceUuid.toLowerCase()) {
        waveletService = service;
      }
    }

    if (waveletService == null) {
      throw Exception('Wavelet BLE service not found');
    }

    print('[BLE] Wavelet service found');

    for (final characteristic in waveletService.characteristics) {
      final uuid = characteristic.uuid.toString().toLowerCase();

      print('[BLE] Characteristic: $uuid');

      switch (uuid) {
        case deviceInfoUuid:
          deviceInfo = characteristic;
          break;

        case commandUuid:
          command = characteristic;
          break;

        case wifiSsidUuid:
          wifiSsid = characteristic;
          break;

        case wifiPasswordUuid:
          wifiPassword = characteristic;
          break;

        case statusUuid:
          status = characteristic;
          break;

        case deviceNameUuid:
          deviceName = characteristic;
          break;

        case spotifyTokenUuid:
          spotifyToken = characteristic;
          break;
      }
    }

    // Make sure the characteristics we actually need exist.
    if (requireWifi && wifiSsid == null) {
      throw Exception('Wi-Fi SSID characteristic not found');
    }

    if (requireWifi && wifiPassword == null) {
      throw Exception('Wi-Fi password characteristic not found');
    }

    if (status == null) {
      throw Exception('Status characteristic not found');
    }

    if (command == null) {
      throw Exception('Command characteristic not found');
    }

    if (deviceName == null) {
      throw Exception('Device name characteristic not found');
    }

    print('[BLE] Required characteristics found');

    await _enableStatusNotifications();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Status notifications
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _enableStatusNotifications() async {
    if (status == null) return;

    print('[BLE] Enabling status notifications...');

    await status!.setNotifyValue(true);

    await _statusSubscription?.cancel();

    _statusSubscription = status!.onValueReceived.listen((value) {
      final message = String.fromCharCodes(value);
      lastStatus = message;

      print('[BLE] Status received: $message');

      _statusController.add(message);
    });

    print('[BLE] Status notifications enabled');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Send Wi-Fi credentials
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> sendWifiCredentials({
    required String ssid,
    required String password,
  }) async {
    if (!isConnected || wifiSsid == null || wifiPassword == null) {
      throw Exception('Wi-Fi characteristics are not available');
    }

    print('[BLE] Sending Wi-Fi SSID...');
    await wifiSsid!.write(ssid.codeUnits, withoutResponse: false);

    print('[BLE] Sending Wi-Fi password...');
    await wifiPassword!.write(password.codeUnits, withoutResponse: false);

    print('[BLE] Wi-Fi credentials sent');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Commands
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> sendCommand(String value) async {
    if (!isConnected || command == null) {
      throw Exception('Command characteristic is not available');
    }

    print(
      value.startsWith('VERIFY_SETUP_TOKEN:')
          ? '[BLE] Sending Mini setup token verification'
          : '[BLE] Sending command: $value',
    );

    await command!.write(value.codeUnits, withoutResponse: false);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Device name
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setDeviceName(String name) async {
    if (!isConnected || deviceName == null) {
      throw Exception('Device name characteristic is not available');
    }

    print('[BLE] Sending device name...');

    await deviceName!.write(name.codeUnits, withoutResponse: false);
  }

  Future<Map<String, dynamic>> readDeviceInfo() async {
    if (!isConnected || deviceInfo == null) {
      throw Exception('Device information is unavailable');
    }
    final bytes = await deviceInfo!.read();
    return jsonDecode(String.fromCharCodes(bytes)) as Map<String, dynamic>;
  }

  Future<String> requestDeviceStatus() async {
    if (!isConnected || status == null) {
      throw Exception('Device status is unavailable');
    }
    final response = Completer<String>();
    final subscription = statusStream.listen((value) {
      if (value.startsWith('{') && !response.isCompleted) {
        response.complete(value);
      }
    });
    try {
      await sendCommand('GET_STATUS');
      return await response.future.timeout(const Duration(seconds: 4));
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> setSpotifyRefreshToken(String token) async {
    if (!isConnected || spotifyToken == null) {
      throw Exception('Spotify token characteristic is unavailable');
    }
    await spotifyToken!.write(token.codeUnits, withoutResponse: false);
  }

  Future<void> setVolume(int percent) async {
    if (percent < 0 || percent > 100) {
      throw RangeError.range(percent, 0, 100, 'percent');
    }
    await sendCommand('SET_VOLUME:$percent');
  }

  Future<void> setMiniTheme({required bool dark}) =>
      sendCommand('SET_THEME:${dark ? 'DARK' : 'LIGHT'}');

  Future<void> setShuffle({required bool enabled}) =>
      sendCommand('SET_SHUFFLE:${enabled ? 'ON' : 'OFF'}');

  Future<void> setRepeatMode(String mode) {
    const allowed = {'OFF', 'TRACK', 'CONTEXT'};
    final normalized = mode.toUpperCase();
    if (!allowed.contains(normalized)) {
      throw ArgumentError.value(mode, 'mode', 'Use OFF, TRACK, or CONTEXT');
    }
    return sendCommand('SET_REPEAT:$normalized');
  }

  Future<void> syncDeviceTime(DateTime time) =>
      sendCommand('SYNC_TIME:${time.millisecondsSinceEpoch ~/ 1000}');

  Future<bool> verifyMiniSetupToken(String token) async {
    if (!isConnected || command == null) {
      throw Exception('Wavelet Mini is not connected');
    }
    final result = Completer<bool>();
    final subscription = statusStream.listen((value) {
      if (value == 'SETUP_TOKEN_VALID' && !result.isCompleted) {
        result.complete(true);
      } else if (value == 'SETUP_TOKEN_INVALID' && !result.isCompleted) {
        result.complete(false);
      }
    });
    try {
      await sendCommand('VERIFY_SETUP_TOKEN:${token.toUpperCase()}');
      return await result.future.timeout(const Duration(seconds: 4));
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> completeSetup() async {
    if (command == null) {
      throw Exception('Setup command is unavailable');
    }
    final target = device;
    try {
      await command!.write('SETUP_COMPLETE'.codeUnits, withoutResponse: false);
    } catch (_) {
      // Both firmware builds save the name before acknowledging SETUP_COMPLETE,
      // then reboot. A disconnect caused by that reboot is an expected result.
      if (target == null || target.isConnected) rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Disconnect
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    print('[BLE] Disconnecting...');
    _intentionalDisconnect = true;
    _autoReconnectEnabled = false;
    await _statusSubscription?.cancel();
    _statusSubscription = null;
    await _detachCurrentDevice();
    print('[BLE] Disconnected');
  }

  void _clearCharacteristics() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    deviceInfo = null;
    command = null;
    wifiSsid = null;
    wifiPassword = null;
    status = null;
    deviceName = null;
    spotifyToken = null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────────────────────────────────

  void dispose() {
    _statusSubscription?.cancel();
    _connectionSubscription?.cancel();
    _reconnectTimer?.cancel();
    _statusController.close();
  }
}

final bleManager = BleManager();
