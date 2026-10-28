import 'package:Wavelet/pages/initalpair/devicespecific/max/max-wifi-connect_page.dart';
import 'package:Wavelet/pages/initalpair/devicespecific/mini/mini-wifi-connect_page.dart';
import 'package:Wavelet/pages/initalpair/devicespecific/mini/mini-qrcode-scan_page.dart';
import 'package:Wavelet/pages/initalpair/devicespecific/regular/regular-naming_page.dart';
import 'package:Wavelet/pages/initalpair/initial-pair-naming_page.dart';
import 'package:Wavelet/pages/initalpair/inital-pair-searching_page.dart';
import 'package:Wavelet/pages/initalpair/initial-pair-final_page.dart';
import 'package:Wavelet/util/device_card.dart';
import 'package:Wavelet/util/five_step_navigation.dart';
import 'package:flutter/material.dart';
import 'package:Wavelet/theme/colors.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:Wavelet/util/function/ble_scanner.dart';
import 'package:Wavelet/util/function/ble_manager.dart';

class FoundDevices extends StatefulWidget {
  const FoundDevices({
    super.key,
    required this.toggleTheme,
    required this.devices,
  });
  final VoidCallback toggleTheme;

  final List<ScanResult> devices;

  @override
  State<FoundDevices> createState() => _FoundDevicesState();
}

class _FoundDevicesState extends State<FoundDevices> {
  bool _connecting = false;
  String? _error;

  Future<void> handleDeviceTap(BuildContext context, ScanResult result) async {
    if (_connecting) return;
    setState(() {
      _connecting = true;
      _error = null;
    });

    final model = BleScanner.extractModel(result.device.platformName);
    final device = result.device;
    // final model = device["model"]!;

    try {
      await bleManager.connect(device, requireWifi: model == 'mini');
      if (!mounted) return;
      switch (model) {
        case "mini":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MiniQrScanPage(
                toggleTheme: widget.toggleTheme,
                pageStep: 4,
                device: result.device,

                //deviceName: device,
              ),
            ),
          );
          break;

        case "max":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MaxWifiPage(
                toggleTheme: widget.toggleTheme,
                deviceName: device.platformName,
                pageStep: 4,
              ),
            ),
          );
          break;

        case "regular":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegularNameDevicePage(
                toggleTheme: widget.toggleTheme,
                device: result.device,
                // deviceName: device.toString(),
                // model: model,
              ),
            ),
          );
          break;
      }
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Could not connect. Move closer to your Wavelet and try again.',
        );
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaveletColors.background(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 69, 24, 4),
            child: Text(
              "Devices found",
              style: TextStyle(
                color: WaveletColors.textPrimary(context),
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: WaveletColors.error(context).withOpacity(.12),
                  border: Border.all(
                    color: WaveletColors.error(context).withOpacity(.35),
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: WaveletColors.error(context)),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 24, 43),
            child: Text(
              "Tap the Wavelet you want to set up.",
              style: TextStyle(
                color: WaveletColors.textSecondary(context),
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // device list
          Expanded(
            child: widget.devices.isEmpty
                ?
                  //device list is empty: no devices found
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.speaker,
                          color: WaveletColors.textDisabled(context),
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No speakers found",
                          style: TextStyle(
                            color: WaveletColors.textDisabled(context),
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SearchPage(toggleTheme: widget.toggleTheme),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WaveletColors.primaryButton(
                              context,
                            ),
                            foregroundColor: WaveletColors.primaryButtonText(
                              context,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Search again"),
                        ),
                      ],
                    ),
                  )
                //value if devices found
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    itemCount: widget.devices.length,
                    separatorBuilder: (_, __) => SizedBox(height: 32),
                    itemBuilder: (context, index) {
                      final result = widget.devices[index];
                      return DeviceCard(
                        deviceName: result.device.platformName,
                        deviceModel: BleScanner.extractModel(
                          result.device.platformName,
                        ),
                        signalStrength: BleScanner.signalLabel(result.rssi),
                        deviceImage: 'assets/images/spk-temp.png',
                        onTap: () => handleDeviceTap(context, result),
                      );
                    },
                  ),
          ),

          //step nav
          Center(
            //padding: const EdgeInsets.only(left:118, top:16),
            child: FiveStepNavigation(position: 3),
          ),

          // scan again button at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchPage(toggleTheme: widget.toggleTheme),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WaveletColors.surface(context),
                foregroundColor: WaveletColors.textSecondary(context),
                minimumSize: Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text("Scan again"),
            ),
          ),
        ],
      ),
    );
  }
}
