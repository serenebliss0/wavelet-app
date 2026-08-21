import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleManager {
  // ─────────────────────────────────────────────────────────────────────────
  // Wavelet UUIDs
  // ─────────────────────────────────────────────────────────────────────────

  static const String waveletServiceUuid =
      "4fafc201-1fb5-459e-8fcc-c5c9c331914b";

  static const String deviceInfoUuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  static const String commandUuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  static const String wifiSsidUuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26aa";

  static const String wifiPasswordUuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26ab";

  static const String statusUuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26ac";

  static const String deviceNameUuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26ad";

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

  bool get isConnected => device != null;

  // Status stream
  StreamSubscription<List<int>>? _statusSubscription;

  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  Stream<String> get statusStream => _statusController.stream;

  // ─────────────────────────────────────────────────────────────────────────
  // Connect
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> connect(BluetoothDevice selectedDevice) async {
    device = selectedDevice;

    print('[BLE] Connecting to ${selectedDevice.platformName}...');

    try {
      // In case the device is already connected.
      if (selectedDevice.isConnected) {
        print('[BLE] Device already connected');
      } else {
        await selectedDevice.connect();
        print('[BLE] Connected!');
      }

      await _discoverServices();

      print('[BLE] Wavelet BLE ready');
    } catch (e) {
      print('[BLE] Connection failed: $e');

      await disconnect();

      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Discover services and characteristics
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _discoverServices() async {
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
      }
    }

    // Make sure the characteristics we actually need exist.
    if (wifiSsid == null) {
      throw Exception('Wi-Fi SSID characteristic not found');
    }

    if (wifiPassword == null) {
      throw Exception('Wi-Fi password characteristic not found');
    }

    if (status == null) {
      throw Exception('Status characteristic not found');
    }

    if (command == null) {
      throw Exception('Command characteristic not found');
    }

    print('[BLE] All required characteristics found');

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
    if (wifiSsid == null || wifiPassword == null) {
      throw Exception('Wi-Fi characteristics are not available');
    }

    print('[BLE] Sending Wi-Fi SSID...');
    await wifiSsid!.write(
      ssid.codeUnits,
      withoutResponse: false,
    );

    print('[BLE] Sending Wi-Fi password...');
    await wifiPassword!.write(
      password.codeUnits,
      withoutResponse: false,
    );

    print('[BLE] Wi-Fi credentials sent');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Commands
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> sendCommand(String value) async {
    if (command == null) {
      throw Exception('Command characteristic is not available');
    }

    print('[BLE] Sending command: $value');

    await command!.write(
      value.codeUnits,
      withoutResponse: false,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Device name
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setDeviceName(String name) async {
    if (deviceName == null) {
      throw Exception('Device name characteristic is not available');
    }

    print('[BLE] Sending device name...');

    await deviceName!.write(
      name.codeUnits,
      withoutResponse: false,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Disconnect
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    print('[BLE] Disconnecting...');

    await _statusSubscription?.cancel();
    _statusSubscription = null;

    if (device != null) {
      try {
        await device!.disconnect();
      } catch (_) {
        // Already disconnected — nothing to worry about.
      }
    }

    device = null;

    deviceInfo = null;
    command = null;
    wifiSsid = null;
    wifiPassword = null;
    status = null;
    deviceName = null;

    print('[BLE] Disconnected');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────────────────────────────────

  void dispose() {
    _statusSubscription?.cancel();
    _statusController.close();
  }
}

final bleManager = BleManager();