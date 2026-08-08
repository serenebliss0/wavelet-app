import 'package:Wavelet/pages/initalpair/initial-pair-final_page.dart';
import 'package:Wavelet/pages/login_page.dart';
import 'package:Wavelet/util/home-device-list.dart';
import 'package:flutter/material.dart';
import 'package:Wavelet/theme/colors.dart';

//remove later
import 'package:Wavelet/models/wavelet_device.dart';
import 'package:Wavelet/services/device_service.dart';
//rem

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
  final VoidCallback toggleTheme; // add this

  List<String> devices = [];

}

class _HomePageState extends State<HomePage> {

final DeviceService _deviceService = DeviceService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: WaveletColors.background(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

//profile, notif, greetings
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Row(
              
                children: [
              
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 38),
              
                        child: Text(
                          'Good afternoon',  //change to time specific later
                          style: TextStyle(
                            color: WaveletColors.textSecondary(context),
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
              
                      SizedBox(height: 2,),
              
                      Padding(
                        padding: const EdgeInsets.only(left: 38),
                        child: Text(
                          'Serenity',  //change to username
                          style: TextStyle(
                            color: WaveletColors.textPrimary(context),
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      )
                    ],
                  ),
              
                  SizedBox(width: 130,),
              
              //notification bell
                  IconButton(
                    onPressed: (){}, 
                    icon: Icon(
                      Icons.circle_notifications_rounded,
                      color: WaveletColors.textSecondary(context),
                      
                      ),
              
                      style: IconButton.styleFrom(
                        backgroundColor: WaveletColors.secondaryButton(context)
                      ),
                      ),

                      SizedBox(width: 10,),
              
              //profile icon
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: WaveletColors.accent(context),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.person),
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 41,),

//online, playing, device count
            SizedBox(
              // width: 350,
              height: 41.6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: WaveletColors.surfaceVariant(context),
                  border: Border.all(
                    color: WaveletColors.border(context),
                    width: 0.8,
                  )
                ),
                child: Row(
                  
                  children: [
                    SizedBox(width: 12,),
              
              //online circle
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: WaveletColors.success(context),
                        shape: BoxShape.circle,
                      ),
                    ),
              
                    SizedBox(width: 8,),
              
                    Text(
                      '2 online', //replace with device onl count
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: WaveletColors.textPrimary(context)
                      ),
                    ),
              
                    SizedBox(width: 41.46,),
              
              
              //divider
                    SizedBox(
                      height: 16,
                      child: VerticalDivider(
                        width: 1,
                        color: WaveletColors.divider(context),
                        
                      ),
                    ),
              
                    SizedBox(width: 12,),
              
                    Icon(Icons.music_note, color: Color(0xFFFF4D6D),),
              
                    SizedBox(width:8 ,),
              
                    Text(
                      '1 playing', //replace with device onl count
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: WaveletColors.textPrimary(context)
                      ),
                    ),
              
                  SizedBox(width: 32.48,),
              
              //divider
                    SizedBox(
                      height: 16,
                      child: VerticalDivider(
                        width: 1,
                        color: WaveletColors.divider(context),
                        
                      ),
                    ),
              
                    SizedBox(width: 12,),
              
                    Icon(Icons.speaker, color: Color(0xFFC084B0),),
              
                    SizedBox(width: 8,),
              
                    Text(
                      '3 devices', //replace with device acc count
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: WaveletColors.textPrimary(context)
                      ),
                    ),
                  ], //end of info bar
                ),
              ),
            ),

            //test code
            //remove later
            ElevatedButton(
    onPressed: () async {
      try {
        final device = WaveletDevice(
          id: 'TEST_MINI_001',
          model: 'mini',
          name: 'Bedroom Mini',
          color: 'blue',
          firmwareVersion: '1.0.0',
          pairedAt: DateTime.now(),
        );

        await _deviceService.addDevice(device);

        print('Device added successfully!');
      } catch (e) {
        print('DEVICE ERROR: $e');
      }
    },
    child: const Text('Add Test Mini'),
  ),
//remove laterrrr


  //replace later

  //test my devices

  Expanded(child: DeviceList())






          ], //end of column

          
        ),

    );
  }
}