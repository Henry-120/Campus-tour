import 'package:cloud_firestore/cloud_firestore.dart';

class MonsterModel {
  final String id;
  final String name;
  final String type;
  final String imageURL;
  final DocumentReference? architectureRef;
  final DocumentReference? qaRef;
  final GeoPoint location;

  MonsterModel({
    required this.id,
    required this.name,
    required this.type,
    required this.imageURL,
    this.architectureRef,
    this.qaRef,
    required this.location
  });

  factory MonsterModel.fromMap(String id, Map<String, dynamic> data) {
    final loc = data['location'];
    DocumentReference? archRef;
    if (data['architectureRef'] != null) {
      if (data['architectureRef'] is String) {
        // JSON 初始化時是字串路徑
        archRef = FirebaseFirestore.instance.doc(data['architectureRef'] as String);
      } else if (data['architectureRef'] is DocumentReference) {
        // Firestore 讀取時就是 DocumentReference
        archRef = data['architectureRef'] as DocumentReference;
      }
    }

    DocumentReference? qaRef;
    if (data['qaRef'] != null && data['qaRef'] != '') {
      if (data['qaRef'] is String) {
        qaRef = FirebaseFirestore.instance.doc(data['qaRef'] as String);
      } else if (data['qaRef'] is DocumentReference) {
        qaRef = data['qaRef'] as DocumentReference;
      }
    }

    GeoPoint location;
    if (loc is GeoPoint) {
      // Firestore 讀取時
      location = loc;
    } else if (loc is Map<String, dynamic>) {
      // JSON 初始化時
      location = GeoPoint(
        (loc['latitude'] ?? 0).toDouble(),
        (loc['longitude'] ?? 0).toDouble(),
      );
    } else {
      // 預設值
      location = const GeoPoint(0, 0);
    }

    return MonsterModel(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      imageURL: data['imageURL'] ?? '',
      architectureRef: archRef,
      qaRef: qaRef,
      location: location,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'imageURL': imageURL,
      'architectureRef': architectureRef,
      'qaRef': qaRef,
      'location': location
    };
  }
}
