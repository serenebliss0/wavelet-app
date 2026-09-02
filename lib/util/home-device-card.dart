import 'package:flutter/material.dart';
import 'package:Wavelet/theme/colors.dart';

enum DeviceStatus {
  offline,
  idle,
  playing,
}

class HomeDeviceCard extends StatelessWidget {
  final String deviceName;
  final String deviceModel;
  final String volume;
  final String songName;
  final String artistName;
  final DeviceStatus deviceStatus;

  const HomeDeviceCard({
    super.key,
    required this.deviceName,
    required this.deviceModel,
    required this.volume,
    required this.songName,
    required this.artistName,
    required this.deviceStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right:16),
      child: SizedBox(
        width: 50,
        height: 132,
        child: Container(
          decoration: BoxDecoration(
            color: WaveletColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: WaveletColors.border(context),
              width: 0.8,
            ),
          ),
        
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              Row(
                children: [
        
                  Image.asset(
                    'assets/images/spk-temp.png',
                    width: 56,
                    height: 56,
                  ),
        
                  const SizedBox(width: 12),
        
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
        
                        Text(
                          deviceName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
        
                        const SizedBox(height: 3),
        
                        Text(
                          deviceModel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: WaveletColors.textDisabled(context),
                          ),
                        ),
                      ],
                    ),
                  ),
        
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                  ),
        
                ],
              ),
        
              const SizedBox(height: 12),
        
              Text(
                _statusText(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: WaveletColors.textDisabled(context),
                ),
              ),
        
              const SizedBox(height: 8),
        
              Text(
                '$songName — $artistName',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
        
            ],
          ),
        ),
      ),
    );
  }

  String _statusText() {
    switch (deviceStatus) {
      case DeviceStatus.offline:
        return 'Offline';

      case DeviceStatus.idle:
        return 'Idle • Volume $volume';

      case DeviceStatus.playing:
        return 'Playing • Volume $volume';
    }
  }
}