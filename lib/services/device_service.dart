import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Wavelet/models/wavelet_device.dart';

class DeviceService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DeviceService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _devices {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices');
  }

  Future<void> addDevice(WaveletDevice device) async {
    await _devices
        .doc(device.id)
        .set(device.toFirestore());
  }

  Future<void> updateDevice(WaveletDevice device) async {
    await _devices
        .doc(device.id)
        .update(device.toFirestore());
  }

  Future<void> deleteDevice(String deviceId) async {
    await _devices
        .doc(deviceId)
        .delete();
  }

  Future<WaveletDevice?> getDevice(String deviceId) async {
    final snapshot = await _devices
        .doc(deviceId)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return WaveletDevice.fromFirestore(
      snapshot.id,
      snapshot.data()!,
    );
  }

  Future<List<WaveletDevice>> getDevices() async {
    final snapshot = await _devices.get();

    return snapshot.docs
        .map(
          (doc) => WaveletDevice.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  Stream<List<WaveletDevice>> watchDevices() {
  return _devices.snapshots().map((snapshot) {
    return snapshot.docs
        .map(
          (doc) => WaveletDevice.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  });
}
}