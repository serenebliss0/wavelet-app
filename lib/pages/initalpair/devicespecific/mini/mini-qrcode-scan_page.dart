import 'package:Wavelet/pages/initalpair/devicespecific/mini/mini-manual-code_page.dart';
import 'package:Wavelet/pages/initalpair/devicespecific/mini/mini-wifi-connect_page.dart';
import 'package:Wavelet/theme/colors.dart';
import 'package:Wavelet/util/five_step_navigation.dart';
import 'package:Wavelet/util/function/ble_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MiniQrScanPage extends StatefulWidget {
  const MiniQrScanPage({
    super.key,
    required this.toggleTheme,
    required this.pageStep,
    required this.device,
  });
  final VoidCallback toggleTheme;
  final BluetoothDevice device;
  final int pageStep;

  @override
  State<MiniQrScanPage> createState() => _MiniQrScanPageState();
}

class _MiniQrScanPageState extends State<MiniQrScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  String? _error;

  Future<void> _handleQr(String raw) async {
    final uri = Uri.tryParse(raw);
    final token = uri?.queryParameters['token'];
    final validShape =
        uri?.scheme == 'wavelet' &&
        uri?.queryParameters['model'] == 'mini' &&
        token != null &&
        RegExp(r'^[A-Z0-9]{8}$', caseSensitive: false).hasMatch(token);
    if (!validShape) {
      await _controller.start();
      if (mounted)
        setState(() {
          _handled = false;
          _error = 'That QR code is not a valid Wavelet Mini setup code.';
        });
      return;
    }
    await _controller.stop();
    try {
      if (!bleManager.isConnected)
        await bleManager.connect(widget.device, requireWifi: true);
      if (!await bleManager.verifyMiniSetupToken(token!)) throw Exception();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MiniWifiPage(
            toggleTheme: widget.toggleTheme,
            deviceName: widget.device.platformName,
            pageStep: 4,
            device: widget.device,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Could not verify the Mini. Check that it is nearby, then try again.';
        _handled = false;
      });
      await _controller.start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openManualEntry() async {
    await _controller.stop();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MiniManualCodePage(
          toggleTheme: widget.toggleTheme,
          device: widget.device,
        ),
      ),
    );
    if (mounted) await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width.clamp(220.0, 320.0);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MINI  ·  Mini only',
          style: TextStyle(
            color: WaveletColors.primary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Scan QR code',
          style: TextStyle(
            color: WaveletColors.textPrimary(context),
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Find the QR code on the bottom of your Wavelet Mini and point your camera at it.',
          style: TextStyle(color: WaveletColors.textSecondary(context)),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: WaveletColors.error(context).withOpacity(.12),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              _error!,
              style: TextStyle(color: WaveletColors.error(context)),
            ),
          ),
        ],
        const Spacer(),
        Center(
          child: SizedBox(
            width: size,
            height: size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (_handled) return;
                  final raw = capture.barcodes.firstOrNull?.rawValue;
                  if (raw == null) return;
                  _handled = true;
                  _handleQr(raw);
                },
              ),
            ),
          ),
        ),
        const Spacer(),
        Center(child: FiveStepNavigation(position: 4)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _openManualEntry,
            style: OutlinedButton.styleFrom(
              foregroundColor: WaveletColors.secondaryButtonText(context),
              side: BorderSide(color: WaveletColors.border(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Enter code manually'),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: WaveletColors.background(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(padding: const EdgeInsets.all(24), child: content),
          ),
        ),
      ),
    );
  }
}
