import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/monster_model.dart';
import '../models/architecture_model.dart';
import '../models/qa_model.dart';
import '../models/user_monster_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== User =====
  Future<void> setUser(UserModel user) async {
    await _db.collection("users").doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection("users").doc(uid).update(data);
  }

  /// Deletes all user-owned Firestore data known to the app.
  Future<void> deleteUserData(String uid) async {
    final userRef = _db.collection("users").doc(uid);
    final monsters = await userRef.collection("monsters").get();

    // Keep batches comfortably below Firestore's 500-operation limit.
    for (var offset = 0; offset < monsters.docs.length; offset += 400) {
      final batch = _db.batch();
      final end = offset + 400 < monsters.docs.length
          ? offset + 400
          : monsters.docs.length;
      for (final doc in monsters.docs.sublist(offset, end)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    await userRef.delete();
  }

  // ===== Monster =====
  Future<void> setMonster(MonsterModel monster) async {
    await _db.collection("monsters").doc(monster.id).set(monster.toMap());
  }

  Future<MonsterModel?> getMonster(String id) async {
    final doc = await _db.collection("monsters").doc(id).get();
    if (doc.exists) {
      return MonsterModel.fromMap(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    }
    return null;
  }

  Future<List<MonsterModel>> getAllMonsters() async {
    final snapshot = await _db.collection("monsters").get();
    return snapshot.docs
        .map((doc) => MonsterModel.fromMap(id: doc.id, doc.data()))
        .toList();
  }

  // ===== Architecture =====
  Future<void> setArchitecture(ArchitectureModel arch) async {
    await _db.collection("architectures").doc(arch.id).set(arch.toMap());
  }

  Future<ArchitectureModel?> getArchitecture(String id) async {
    final doc = await _db.collection("architectures").doc(id).get();
    if (doc.exists) {
      return ArchitectureModel.fromMap(
        id: doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }
    return null;
  }

  // ===== QA =====
  Future<void> setQA(QAModel qa) async {
    await _db.collection("questions").doc(qa.id).set(qa.toMap());
  }

  Future<QAModel?> getQA(String id) async {
    final doc = await _db.collection("questions").doc(id).get();
    if (doc.exists) {
      return QAModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // ===== UserMonster =====
  Future<void> addUserMonster(String uid, UserMonsterModel userMonster) async {
    final docRef = await _db
        .collection("users")
        .doc(uid)
        .collection("monsters")
        .add(userMonster.toMap()); // Firestore 自動生成 id
    userMonster.docId = docRef.id;
  }

  Future<void> setUserMonster(
    String uid,
    String monsterId,
    UserMonsterModel userMonster,
  ) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("monsters")
        .doc(monsterId)
        .set(userMonster.toMap());
    userMonster.docId = monsterId;
  }

  Future<List<UserMonsterModel>> getUserMonsters(String uid) async {
    final snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("monsters")
        .get();

    return snapshot.docs
        .map((doc) => UserMonsterModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  Future<void> deleteUserMonster(String uid, String monsterDocId) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("monsters")
        .doc(monsterDocId)
        .delete();
  }

  Future<void> deleteAllUserMonsters(String uid) async {
    final snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("monsters")
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
