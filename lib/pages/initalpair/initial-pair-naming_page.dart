import 'package:Wavelet/theme/colors.dart';
import 'package:Wavelet/util/five_step_navigation.dart';
import 'package:flutter/material.dart';
import 'package:Wavelet/util/function/ble_manager.dart';

class NameDevicePage extends StatefulWidget {
  const NameDevicePage({
    super.key,
    required this.toggleTheme
    
    });

    final VoidCallback toggleTheme;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please give your Wavelet a name'),
        ),
      );
      return;
    }

    try {
      debugPrint('[SETUP] Setting Wavelet name: $name');

      await bleManager.setDeviceName(name);

      debugPrint('[SETUP] Wavelet name saved');

      if (!mounted) return;

      // For now, just show success.
      // We'll replace this with the actual post-setup flow.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wavelet setup complete!'),
        ),
      );

    } catch (e) {
      debugPrint('[SETUP] Failed to set Wavelet name: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save Wavelet name'),
        ),
      );
    }
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
                fontFamily: 'Inter'
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
                fontFamily: 'Inter'
              ),
            ),
          ),

          //speaker icon
          Center(
            child: Container(
              width: 342,
              height: 120,
            
              child: Center(
                child: Image.asset(
                  'assets/images/spk-temp.png'
                ),
              ),
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
                    fontWeight: FontWeight.w500
                  )
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
                  fontFamily: 'Inter'
                ),
              ),
          ),

          //add preset rooms here

          SizedBox(height: 352,),

          Center(child: FiveStepNavigation(position: 5)),

          SizedBox(height: 24,),

                    //signin button
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