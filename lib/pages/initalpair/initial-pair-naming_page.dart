import 'package:Wavelet/pages/initalpair/initial-pair-final_page.dart';
import 'package:Wavelet/theme/colors.dart';
import 'package:Wavelet/util/five_step_navigation.dart';
import 'package:flutter/material.dart';
import 'package:Wavelet/util/function/ble_manager.dart';
import 'package:Wavelet/models/wavelet_device.dart';
import 'package:Wavelet/services/device_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class NameDevicePage extends StatefulWidget {
  const NameDevicePage({
    super.key,
    required this.toggleTheme,
    required this.device,
  });

  final VoidCallback toggleTheme;
  final BluetoothDevice device;

  @override
  State<NameDevicePage> createState() => _NameDevicePageState();
}

class _NameDevicePageState extends State<NameDevicePage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finishSetup() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showError('Please give your Wavelet a name');
      return;
    }

    try {
      debugPrint('[SETUP] Setting Wavelet name: $name');

      await bleManager.setDeviceName(name);

      debugPrint('[SETUP] Wavelet name saved');

      await bleManager.completeSetup();

      final modelName = widget.device.platformName.toLowerCase();
      final model = modelName.contains('mini')
          ? 'mini'
          : modelName.contains('max')
          ? 'max'
          : 'regular';
      await DeviceService().addDevice(
        WaveletDevice(
          id: widget.device.remoteId.str,
          model: model,
          name: name,
          pairedAt: DateTime.now(),
          lastSeen: DateTime.now(),
        ),
      );

      if (!mounted) return;

      // For now, just show success.
      // We'll replace this with the actual post-setup flow.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FinishedPairPage(
            toggleTheme: widget.toggleTheme,
            userDeviceName: name,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[SETUP] Failed to set Wavelet name: $e');

      if (!mounted) return;

      _showError(
        'The speaker saved its name, but could not finish linking. Check your account connection and retry.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        backgroundColor: WaveletColors.error(context),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaveletColors.background(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //name your wavelet
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 78, 10, 6),

            child: Text(
              "Name your wavelet",
              style: TextStyle(
                color: WaveletColors.textPrimary(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),

          //where will it live
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 0, 27),
            child: Text(
              "Where will it live?",
              style: TextStyle(
                color: WaveletColors.textSecondary(context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
          ),

          //speaker icon
          Center(
            child: Container(
              width: 342,
              height: 120,

              child: Center(child: Image.asset('assets/images/spk-temp.png')),
            ),
          ),

          //device name field
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 33, 44, 24),
              child: TextField(
                controller: _nameController,
                obscureText: false,
                decoration: InputDecoration(
                  hintText: "Give your wavelet a name",
                  filled: true,
                  fillColor: WaveletColors.surfaceVariant(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none, // removes the outline border
                  ),

                  hintStyle: TextStyle(
                    color: WaveletColors.textDisabled(context),
                    // style: Theme.of(context).textTheme.displayLarge
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              "OR PICK A ROOM",
              style: TextStyle(
                color: WaveletColors.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),

          //add preset rooms here
          const Spacer(),

          Center(child: FiveStepNavigation(position: 5)),

          SizedBox(height: 24),

          //finish button
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _finishSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WaveletColors.primaryButton(context),
                  foregroundColor: WaveletColors.primaryButtonText(context),
                  minimumSize: Size(294, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text("Finish Setup"),
              ),
            ),
          ),
        ], //end of column
      ),
    );
  }
}
