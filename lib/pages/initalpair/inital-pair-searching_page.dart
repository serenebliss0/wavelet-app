import 'dart:async';

import 'package:Wavelet/pages/initalpair/initial-pair-found-devices_page.dart';
import 'package:Wavelet/util/five_step_navigation.dart';
import 'package:Wavelet/util/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:Wavelet/theme/colors.dart';
import 'package:Wavelet/util/function/ble_scanner.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.toggleTheme});
  final VoidCallback toggleTheme;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // List<ScanResult> devices = [];
  bool isScanning = false;

  List<ScanResult> foundDevices = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _scanSubscription = BleScanner.scan().listen((results) {
      if (mounted) setState(() => foundDevices = results);
    });
  }

  @override
  void dispose() {
    BleScanner.stop();
    _scanSubscription?.cancel();
    super.dispose();
  }

  void goToResults() {
    BleScanner.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FoundDevices(
          toggleTheme: widget.toggleTheme,
          devices: foundDevices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(flex: 4),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(
                color: const Color(0x21FF4D6D),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.60, color: const Color(0xFFFF4D6D)),
                  borderRadius: BorderRadius.circular(26843500),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Icon(Icons.bluetooth),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 77, bottom: 31),
            child: Text(
              "Make sure your Wavelet is powered on",
              style: TextStyle(
                color: WaveletColors.textPrimary(context),
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: 192,
              child: TimedProgressBar(
                duration: Duration(seconds: 15),
                onComplete: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoundDevices(
                        toggleTheme: widget.toggleTheme,
                        devices: foundDevices,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 10),

          // live found count
          Text(
            foundDevices.isEmpty
                ? "Looking..."
                : "Found ${foundDevices.length} speaker${foundDevices.length > 1 ? 's' : ''}",
            style: TextStyle(
              color: WaveletColors.primary(context),
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(flex: 3),

          FiveStepNavigation(position: 2),

          SizedBox(height: 24),

          //disabled button i added : )
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: foundDevices.isEmpty ? null : goToResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WaveletColors.primaryButton(context),
                  foregroundColor: WaveletColors.primaryButtonText(context),
                  disabledBackgroundColor: WaveletColors.disabledButton(
                    context,
                  ),
                  disabledForegroundColor: WaveletColors.disabledButtonText(
                    context,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ),
        ], //end of column
      ),
    );
  }
}
