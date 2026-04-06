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

  // ===== Monster =====
  Future<void> setMonster(MonsterModel monster) async {
    await _db.collection("monsters").doc(monster.id).set(monster.toMap());
  }

  Future<MonsterModel?> getMonster(String id) async {
    final doc = await _db.collection("monsters").doc(id).get();
    if (doc.exists) {
      return MonsterModel.fromMap(doc.data() as Map<String, dynamic>,id:doc.id);
    }
    return null;
  }

  Future<List<MonsterModel>> getAllMonsters() async {
    final snapshot = await _db.collection("monsters").get();
    return snapshot.docs
        .map((doc) => MonsterModel.fromMap(id:doc.id, doc.data() ))
        .toList();
  }

  // ===== Architecture =====
  Future<void> setArchitecture(ArchitectureModel arch) async {
    await _db.collection("architectures").doc(arch.id).set(arch.toMap());
  }

  Future<ArchitectureModel?> getArchitecture(String id) async {
    final doc = await _db.collection("architectures").doc(id).get();
    if (doc.exists) {
      return ArchitectureModel.fromMap(id:doc.id, doc.data() as Map<String, dynamic>);
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


  // 取得 Monster + Architecture + QA
  Future<Map<String, dynamic>?> getMonsterWithRelations(String id) async {
    final doc = await _db.collection("monsters").doc(id).get();
    if (!doc.exists) return null;

    // Monster 本身
    final monster = MonsterModel.fromMap(id:doc.id, doc.data() as Map<String, dynamic>);

    // Architecture
    ArchitectureModel? architecture;
    if (monster.architectureRef != null) {
      final archSnap = await monster.architectureRef!.get();
      if (archSnap.exists) {
        architecture = ArchitectureModel.fromMap(id:archSnap.id, archSnap.data() as Map<String, dynamic>);
      }
    }

    // QA
    QAModel? qa;
    if (monster.qaRef != null) {
      final qaSnap = await monster.qaRef!.get();
      if (qaSnap.exists) {
        qa = QAModel.fromMap(qaSnap.id, qaSnap.data() as Map<String, dynamic>);
      }
    }

    // 回傳整合資料
    return {
      "monster": monster,
      "architecture": architecture,
      "qa": qa,
    };
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

  Future<List<UserMonsterModel>> getUserMonsters(String uid) async {
    final snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("monsters")
        .get();

    return snapshot.docs
        .map((doc) => UserMonsterModel.fromMap(doc.data(), docId:doc.id))
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

}


