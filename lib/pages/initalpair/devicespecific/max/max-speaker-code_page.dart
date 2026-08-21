import 'package:Wavelet/theme/colors.dart';
import 'package:Wavelet/util/five_step_navigation.dart';
import 'package:flutter/material.dart';

class MaxSpeakerCodePage extends StatefulWidget {
  MaxSpeakerCodePage({
    super.key,
    required this.toggleTheme,
    required this.ssid,
    required this.password
    });

  final VoidCallback toggleTheme;
  String ssid = "";
  String password = "";
  @override
  State<MaxSpeakerCodePage> createState() => _MaxSpeakerCodePageState();
}

class _MaxSpeakerCodePageState extends State<MaxSpeakerCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaveletColors.background(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      //header
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 77),
              child: Container(
                // width: 350,
                // height: 122.60,
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Container(
                            width: double.infinity,
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: ShapeDecoration(
                                            color: const Color(0x2138BDF8),
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 0.80,
                                                    color: const Color(0x4438BDF8),
                                                ),
                                                borderRadius: BorderRadius.circular(26843500),
                                            ),
                                        ),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    'MAX',
                                                    style: TextStyle(
                                                        color: const Color(0xFF38BDF8),
                                                        fontSize: 10,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w700,
                                                        height: 1.50,
                                                        letterSpacing: 0.50,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                'Max only',
                                                style: TextStyle(
                                                    color: WaveletColors.textSecondary(context) /* Color-System-Text-Secondary-Text */,
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.33,
                                                ),
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                        Container(
                            // width: 350,
                            // height: 36,
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        'Enter speaker code',
                                        style: TextStyle(
                                            color: WaveletColors.textPrimary(context) /* Color-System-Text-Primary-Text */,
                                            fontSize: 24,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            height: 1.33,
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        Container(
                            // width: 350,
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    SizedBox(
                                        width: 350,
                                        child: Text(
                                            'Your Wavelet Max just played a 6-digit code. Enter it below to verify ownership',
                                            style: TextStyle(
                                                color: WaveletColors.textSecondary(context) /* Color-System-Text-Secondary-Text */,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                height: 1.43,
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
                      ),
            ),
        
          SizedBox(height: 130,),

          //acc input area

                    SizedBox(height: 201,),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FiveStepNavigation(position: 4),
            ),
          ),

          Center(
              child: Container(
                width: 350,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: ShapeDecoration(
                    color: WaveletColors.secondaryButton(context) /* Color-System-Buttons-Secondary-Button */,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 0.80,
                            color: WaveletColors.border(context)/* Color-System-UI-Border */,
                        ),
                        borderRadius: BorderRadius.circular(16),
                    ),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                        Text(
                            'Enter code manually',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: WaveletColors.secondaryButtonText(context) /* Color-System-Buttons-Secondary-Button-Text */,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.43,
                            ),
                        ),
                    ],
                ),
                      ),
            ),
          
        ], //end of column
      ),
    );
  }
}