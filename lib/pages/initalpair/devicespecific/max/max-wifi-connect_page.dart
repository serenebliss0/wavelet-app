import 'package:Wavelet/pages/initalpair/devicespecific/max/max-speaker-code_page.dart';
import 'package:Wavelet/util/five_step_navigation.dart';
import 'package:flutter/material.dart';
import 'package:Wavelet/theme/colors.dart';
import 'package:wifi_scan/wifi_scan.dart';

class MaxWifiPage extends StatefulWidget {
  MaxWifiPage({
    super.key,
    required this.toggleTheme,
    required this.deviceName,
    required this.pageStep,
  });

  final VoidCallback toggleTheme;
  String deviceName;
  int pageStep;

  @override
  State<MaxWifiPage> createState() => _MaxWifiPageState();
}

class _MaxWifiPageState extends State<MaxWifiPage> {
  bool networkSelected = false;
  String? selectedSSID;
  String password = "";
  List<WiFiAccessPoint> networks = [];
  bool isScanning = false;
  String? scanError;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    scanNetworks();
    // button activates when password is typed
    _passwordController.addListener(() {
      setState(() => password = _passwordController.text);
    });
  }

  @override
  void dispose() {
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
            'Could not find Wi-Fi networks. Check permission and refresh.';
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
              onPressed: networkSelected && password.isNotEmpty
                  ? () {
                      // send to speaker over BLE next

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          //changes for each model
                          builder: (_) => MaxSpeakerCodePage(
                            toggleTheme: widget.toggleTheme,
                            ssid: selectedSSID!,
                            password: password,
                          ),
                        ),
                      );
                    }
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
