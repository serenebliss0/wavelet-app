import 'package:Wavelet/util/home-device-card.dart';
import 'package:flutter/material.dart';

import 'package:Wavelet/models/wavelet_device.dart';
import 'package:Wavelet/services/device_service.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({
    super.key,
  });

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {

  final DeviceService _deviceService = DeviceService();

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<WaveletDevice>>(
      stream: _deviceService.watchDevices(),

      builder: (context, snapshot) {

        // Firebase is still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Firebase returned an error
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Unable to load devices.',
            ),
          );
        }

        final devices = snapshot.data ?? [];

        // User has no cloud devices
        if (devices.isEmpty) {
          return const Center(
            child: Text(
              'No Wavelet devices yet.',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),

          itemCount: devices.length,

          separatorBuilder: (context, index) {
            return const SizedBox(height: 12);
          },

          itemBuilder: (context, index) {
            final device = devices[index];

            return HomeDeviceCard(
              deviceName: device.name,
              deviceModel: 'Wavelet ${device.model}',
              volume: '0%',
              songName: 'Nothing playing',
              artistName: 'Lyn',
              deviceStatus: DeviceStatus.offline,
            );
          },
        );
      },
    );
  }
}