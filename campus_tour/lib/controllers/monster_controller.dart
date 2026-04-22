import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';                // 提供 GetxController、Rxn、Obx 等
import '../services/firestore_service.dart';
import '../models/monster_model.dart';        // MonsterModel
import '../models/architecture_model.dart';   // ArchitectureModel
import '../models/qa_model.dart';             // QAModel
import 'package:geolocator/geolocator.dart'; // 💡 引入 GPS 套件
import '../models/user_monster_model.dart';
import "../services/monster_service.dart";

class MonsterController extends GetxController {
  final FirestoreService _service = FirestoreService();
  final MonsterService _monsterService = MonsterService();


  var monster = Rxn<MonsterModel>();
  var architecture = Rxn<ArchitectureModel>();
  var qa = Rxn<QAModel>();

  // 動態位置相關的 monsters
  var nearbyMonsters = <MonsterModel>[].obs;

  // 使用者已捕捉的怪物（圖鑑）
  var userMonsterCollection = <UserMonsterModel>[].obs;
  var capturedMonsterIds = <String>{}.obs;

  Future<void> loadMonsterWithRelations(String id) async {
    final result = await _service.getMonsterWithRelations(id);
    if (result != null) {
      monster.value = result["monster"] as MonsterModel;
      architecture.value = result["architecture"] as ArchitectureModel?;
      qa.value = result["qa"] as QAModel?;
    }
  }

  // 載入使用者的圖鑑（例如從 Firestore）
  Future<void> loadUserCollection(String userId) async {
    final result = await _service.getUserMonsters(userId);
    userMonsterCollection.value = result;
  }

  // 抓到怪物時更新圖鑑
  Future<void> addUserMonster(String userId,
      UserMonsterModel userMonster) async {
    await _service.addUserMonster(userId, userMonster);
    await loadUserCollection(userId);
  }

  // 捕捉怪物 - 從 nearbyMonsters 中選擇要捕捉的怪物
  Future<bool> captureMonster(MonsterModel monster, String userId) async {
    try {
      // 檢查是否已經捕捉過這隻怪物
      final alreadyCaptured = userMonsterCollection.any(
        (m) => m.monsterRef.id == monster.id,
      );

      if (alreadyCaptured) {
        debugPrint('[MonsterController] 怪物 ${monster.name} 已經被捕捉過');
        return false;
      }

      // 建立 UserMonsterModel
      final userMonster = UserMonsterModel(
        monsterRef: FirebaseFirestore.instance.collection("monsters").doc(monster.id),
        name: monster.name,
        imageURL: monster.imageURL,
        caughtAt: DateTime.now(),
      );

      // 新增到 Firestore
      await addUserMonster(userId, userMonster);
      // ✅ 捕捉後從 nearbyMonsters 移除 → 地圖上的 Marker 也會消失
      nearbyMonsters.removeWhere((m) => m.id == monster.id);
      debugPrint('[MonsterController] 成功捕捉怪物: ${monster.name}');
      return true;
    } catch (e) {
      debugPrint('[MonsterController] 捕捉怪物時出錯: $e');
      return false;
    }
  }

  Future<void> updateNearbyMonsters(Position userPosition) async {
    final monsters = await _service.getAllMonsters(); // 從資料庫抓全部
    nearbyMonsters.value = monsters.where((m) {
      return _monsterService.isWithinRange(userPosition, m.location);
    }).toList();
  }

//之後要拿掉，用來建立user monster collection 的假資料
  Future<void> seedUserMonsters(String uid) async {
    final db = FirebaseFirestore.instance;

    // 從 monsters collection 抓出幾筆資料
    final snapshot = await db.collection("monsters").limit(9).get();

    for (var doc in snapshot.docs) {
      final monsterData = doc.data();

      // 建立 UserMonsterModel
      final userMonster = UserMonsterModel(
        monsterRef: doc.reference,
        caughtAt: DateTime.now(), // 這裡可以隨機或指定時間
        name: monsterData["name"] ?? "未知怪物",
        imageURL: monsterData["imageURL"] ?? "",
      );

      // 加入使用者圖鑑
      await addUserMonster(uid, userMonster);
    }
  }
}