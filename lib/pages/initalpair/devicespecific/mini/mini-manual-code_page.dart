import 'package:Wavelet/pages/initalpair/devicespecific/mini/mini-wifi-connect_page.dart';
import 'package:Wavelet/theme/colors.dart';
import 'package:Wavelet/util/function/ble_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MiniManualCodePage extends StatefulWidget {
  const MiniManualCodePage({
    super.key,
    required this.toggleTheme,
    required this.device,
  });
  final VoidCallback toggleTheme;
  final BluetoothDevice device;

  @override
  State<MiniManualCodePage> createState() => _MiniManualCodePageState();
}

class _MiniManualCodePageState extends State<MiniManualCodePage> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _verify() async {
    final token = _controller.text.trim();
    if (token.length != 8) {
      setState(() => _error = 'Enter the 8 character code shown on your Mini.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!bleManager.isConnected)
        await bleManager.connect(widget.device, requireWifi: true);
      if (!await bleManager.verifyMiniSetupToken(token)) throw Exception();
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
      if (mounted)
        setState(
          () => _error =
              'That code could not be verified. Check the code and try again.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Enter speaker code',
          style: TextStyle(
            color: WaveletColors.textPrimary(context),
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 8 character code shown beside the QR code on your Mini.',
          style: TextStyle(color: WaveletColors.textSecondary(context)),
        ),
        const SizedBox(height: 36),
        TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          maxLength: 8,
          style: TextStyle(
            color: WaveletColors.textPrimary(context),
            fontSize: 24,
            letterSpacing: 8,
            fontWeight: FontWeight.w700,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            UpperCaseTextFormatter(),
          ],
          decoration: InputDecoration(
            counterText: '',
            hintText: '────────',
            filled: true,
            fillColor: WaveletColors.surfaceVariant(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: WaveletColors.error(context).withOpacity(.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: WaveletColors.error(context)),
                ),
              ),
            ),
          ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _busy ? null : _verify,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaveletColors.primaryButton(context),
              foregroundColor: WaveletColors.primaryButtonText(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _busy
                ? const CircularProgressIndicator()
                : const Text('Verify Code'),
          ),
        ),
      ],
    );
    return Scaffold(
      backgroundColor: WaveletColors.background(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(padding: const EdgeInsets.all(24), child: content),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
  );
}
