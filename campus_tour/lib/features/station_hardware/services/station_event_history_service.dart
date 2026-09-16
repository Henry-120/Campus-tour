import 'package:campus_tour/features/station_hardware/models/station_hardware_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StationEventHistoryService {
  StationEventHistoryService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  static const String _collectionName = 'HardwareDevice';

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _currentDeviceReference {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User is not authenticated');
    }

    return _db.collection(_collectionName).doc(user.uid);
  }

  Future<HardwareDeviceData?> getCurrentDeviceData() async {
    final snapshot = await _currentDeviceReference.get();
    return _fromSnapshot(snapshot);
  }

  Stream<HardwareDeviceData?> watchCurrentDeviceData() {
    return _currentDeviceReference.snapshots().map(_fromSnapshot);
  }

  HardwareDeviceData? _fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) return null;

    final data = snapshot.data();
    if (data == null) {
      throw const FormatException('HardwareDevice document has no data');
    }

    return HardwareDeviceData.fromMap(data);
  }
}
