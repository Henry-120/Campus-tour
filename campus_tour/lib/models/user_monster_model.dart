import 'package:cloud_firestore/cloud_firestore.dart';

class UserMonsterModel {
  String? docId;
  final DocumentReference monsterRef;
  final String name;
  final String imageURL;
  final String arRef; // 💡 加入 AR 模型檔名
  final DateTime caughtAt;

  UserMonsterModel({
    this.docId,
    required this.name,
    required this.imageURL,
    required this.arRef,
    required this.monsterRef,
    required this.caughtAt
  });

  factory UserMonsterModel.fromMap(Map<String, dynamic> data, {String? docId}) {
    return UserMonsterModel(
      docId: docId,
      monsterRef: data['monsterRef'] as DocumentReference,
      caughtAt: (data['caughtAt'] as Timestamp).toDate(),
      name: data['name'] ?? '',
      imageURL: data['imageURL'] ?? '',
      arRef: data['ARRef'] ?? '', // 💡 讀取 ARRef
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monsterRef': monsterRef,
      'caughtAt': caughtAt,
      'name': name,
      'imageURL': imageURL,
      'ARRef': arRef, // 💡 存入 ARRef
    };
  }
}
