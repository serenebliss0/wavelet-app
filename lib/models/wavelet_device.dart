import 'package:cloud_firestore/cloud_firestore.dart';

class WaveletDevice {
  final String id;
  final String model;
  final String name;
  final String? color;
  final String? firmwareVersion;
  final DateTime? pairedAt;
  final DateTime? lastSeen;

  const WaveletDevice({
    required this.id,
    required this.model,
    required this.name,
    this.color,
    this.firmwareVersion,
    this.pairedAt,
    this.lastSeen,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'model': model,
      'name': name,
      'color': color,
      'firmwareVersion': firmwareVersion,
      'pairedAt': pairedAt != null
          ? Timestamp.fromDate(pairedAt!)
          : null,
      'lastSeen': lastSeen != null
          ? Timestamp.fromDate(lastSeen!)
          : null,
    };
  }

  factory WaveletDevice.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return WaveletDevice(
      id: id,
      model: data['model'] as String? ?? 'unknown',
      name: data['name'] as String? ?? 'Wavelet',
      color: data['color'] as String?,
      firmwareVersion: data['firmwareVersion'] as String?,
      pairedAt: (data['pairedAt'] as Timestamp?)?.toDate(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }
}