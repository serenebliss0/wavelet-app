import 'dart:async';

import 'package:Wavelet/pages/initalpair/devicespecific/max/max-speaker-code_page.dart';
import 'package:Wavelet/pages/initalpair/devicespecific/mini/mini-qrcode-scan_page.dart';
import 'package:Wavelet/pages/initalpair/initial-pair-naming_page.dart';
import 'package:Wavelet/util/five_step_navigation.dart';
import 'package:flutter/material.dart';
import 'package:Wavelet/theme/colors.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:Wavelet/util/function/ble_manager.dart';
import 'package:wifi_scan/wifi_scan.dart';

class MiniWifiPage extends StatefulWidget {
  MiniWifiPage({
    super.key,
    required this.toggleTheme,
    required this.deviceName,
    required this.pageStep,
    required this.device,
  });

  final VoidCallback toggleTheme;
  final BluetoothDevice device;
  String deviceName;
  int pageStep;

  @override
  State<MiniWifiPage> createState() => _MiniWifiPageState();
}

class _MiniWifiPageState extends State<MiniWifiPage> {
  bool networkSelected = false;
  String? selectedSSID;
  String password = "";
  List<WiFiAccessPoint> networks = [];
  bool isScanning = false;
  String? scanError;
  final TextEditingController _passwordController = TextEditingController();

  bool isConnecting = false;
  String? wifiStatus;
  StreamSubscription<String>? _statusSubscription;

  @override
  void initState() {
    super.initState();

    scanNetworks();

    _passwordController.addListener(() {
      setState(() => password = _passwordController.text);
    });

    _statusSubscription = bleManager.statusStream.listen((status) {
      debugPrint('[WIFI] Wavelet status: $status');

      if (!mounted) return;

      if (status == "WIFI_CONNECTING") {
        setState(() {
          isConnecting = true;
          wifiStatus = status;
        });
      } else if (status == "WIFI_CONNECTED") {
        setState(() {
          isConnecting = false;
          wifiStatus = status;
        });

        debugPrint('[WIFI] Wavelet connected to Wi-Fi!');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NameDevicePage(
              toggleTheme: widget.toggleTheme,
              device: widget.device,
            ),
          ),
        );
      } else if (status == "WIFI_FAILED") {
        setState(() {
          isConnecting = false;
          wifiStatus = status;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: const StadiumBorder(),
            backgroundColor: WaveletColors.error(context),
            content: const Text('Wavelet could not connect to Wi-Fi'),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> scanNetworks() async {
    if (!mounted) return;
    setState(() {
      isScanning = true;
      scanError = null;
    });
    try {
      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      if (!mounted) return;
      setState(() {
        networks = results;
        isScanning = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isScanning = false;
        scanError =
            'Could not find Wi-Fi networks. Check Wi-Fi permission and refresh.';
      });
    }
  }

  // convert signal strength to label
  String signalLabel(int? level) {
    if (level == null) return "Fair";
    if (level >= -60) return "Strong";
    if (level >= -75) return "Good";
    return "Fair";
  }

  Color signalColor(String label) {
    if (label == "Strong") return WaveletColors.success(context);
    if (label == "Good") return WaveletColors.warning(context);
    return WaveletColors.error(context);
  }

  Future<void> _sendWifiCredentials() async {
    if (selectedSSID == null || password.isEmpty) return;

    setState(() {
      isConnecting = true;
      wifiStatus = "SENDING";
    });

    debugPrint('[WIFI] Sending credentials to Wavelet...');
    debugPrint('[WIFI] SSID: $selectedSSID');

    try {
      await bleManager.sendWifiCredentials(
        ssid: selectedSSID!,
        password: password,
      );

      debugPrint('[WIFI] Credentials sent');

      debugPrint('[WIFI] Telling Wavelet to connect...');

      await bleManager.sendCommand("SET_WIFI");

      debugPrint('[WIFI] SET_WIFI command sent');
    } catch (e) {
      debugPrint('[WIFI] Failed to send credentials: $e');

      if (!mounted) return;

      setState(() {
        isConnecting = false;
        wifiStatus = "SEND_FAILED";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
          backgroundColor: WaveletColors.error(context),
          content: const Text('Could not send Wi-Fi credentials'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: WaveletColors.background(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 69, bottom: 4),
            child: Text(
              'Connect to Wi-Fi',
              style: TextStyle(
                color: WaveletColors.textPrimary(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 24, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Choose your network',
                    style: TextStyle(
                      color: WaveletColors.textSecondary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isScanning ? null : scanNetworks,
                  tooltip: 'Refresh networks',
                  icon: Icon(
                    Icons.refresh,
                    color: WaveletColors.primary(context),
                  ),
                ),
              ],
            ),
          ),

          //fill with wifi network cards
          Expanded(
            child: isScanning
                ? Center(
                    child: CircularProgressIndicator(
                      color: WaveletColors.primary(context),
                    ),
                  )
                : networks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: WaveletColors.textDisabled(context),
                            size: 36,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            scanError ??
                                'No Wi-Fi networks found. Tap refresh to scan again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: WaveletColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: scanNetworks,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    itemCount: networks.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final network = networks[index];
                      final ssid = network.ssid;
                      final label = signalLabel(network.level);
                      final isSelected = selectedSSID == ssid;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSSID = ssid;
                            networkSelected = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? WaveletColors.primary(
                                    context,
                                  ).withOpacity(0.15)
                                : WaveletColors.surfaceVariant(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? WaveletColors.primary(context)
                                  : WaveletColors.border(context),
                              width: isSelected ? 1.5 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wifi,
                                color: isSelected
                                    ? WaveletColors.primary(context)
                                    : WaveletColors.textSecondary(context),
                                size: 20,
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  ssid,
                                  style: TextStyle(
                                    color: WaveletColors.textPrimary(context),
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              Text(
                                label,
                                style: TextStyle(
                                  color: signalColor(label),
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isSelected) ...[
                                SizedBox(width: 8),
                                Icon(
                                  Icons.check_circle,
                                  color: WaveletColors.primary(context),
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          //wifi password
          if (networkSelected)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),

              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Wi-Fi Password",
                  filled: true,
                  fillColor: WaveletColors.surfaceVariant(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),

                  hintStyle: TextStyle(
                    color: WaveletColors.textDisabled(context),
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          Center(child: FiveStepNavigation(position: 4)),

          //continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 16, 40, 24),
            child: ElevatedButton(
              onPressed: networkSelected && password.isNotEmpty && !isConnecting
                  ? _sendWifiCredentials
                  : null, // null disables the button automatically

              style: ElevatedButton.styleFrom(
                backgroundColor: WaveletColors.primaryButton(context),
                foregroundColor: WaveletColors.primaryButtonText(context),
                disabledBackgroundColor: WaveletColors.disabledButton(context),
                disabledForegroundColor: WaveletColors.disabledButtonText(
                  context,
                ),
                minimumSize: Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text("Continue"),
            ),
          ),
        ], //end of column
      ),
    );
  }
}
