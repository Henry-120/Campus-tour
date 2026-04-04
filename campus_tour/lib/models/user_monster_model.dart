import 'package:cloud_firestore/cloud_firestore.dart';
class UserMonsterModel {
  final DocumentReference? monsterRef;
  final DateTime caughtAt;

  UserMonsterModel({
    required this.monsterRef,
    required this.caughtAt
  });

  factory UserMonsterModel.fromMap(Map<String, dynamic> data) {
    return UserMonsterModel(
      monsterRef: data['monsterRef'] as DocumentReference,
      caughtAt: (data['caughtAt'] as Timestamp).toDate()
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monsterRef': monsterRef,
      'caughtAt': caughtAt
    };
  }
}
