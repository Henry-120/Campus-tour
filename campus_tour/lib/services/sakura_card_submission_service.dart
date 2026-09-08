import 'package:campus_tour/features/station_hardware/models/sakura_card_submission.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Replaces the current user's single handwriting document in Firestore.
class SakuraCardSubmissionService {
  SakuraCardSubmissionService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionName = 'HardwareStore';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> submit(SakuraCardSubmission submission) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User is not authenticated');
    }

    await _firestore.collection(_collectionName).doc(user.uid).set(
      <String, Object>{
        ...submission.toFirestore(),
        // A server value changes only after Firestore accepts this overwrite.
        'upDate': FieldValue.serverTimestamp(),
      },
    );
  }
}
