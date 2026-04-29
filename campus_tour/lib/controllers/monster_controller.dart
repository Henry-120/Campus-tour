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
  var nearestMonster = Rxn<MonsterModel>();
  var nearestDistance = RxnDouble();

  // 使用者已捕捉的怪物（圖鑑）
  var userMonsterCollection = <UserMonsterModel>[].obs;

  // 玩家當前位置 
  var playerPosition = Rxn<Position>();

  Future<void> loadMonsterWithRelations(MonsterModel monsterModel) async {
    monster.value = monsterModel;
    getQAByMonster(monsterModel);
    getArchitectureByMonster(monsterModel);
  }

  /// 傳入 MonsterModel 取得對應的 QA 資料
  Future<QAModel?> getQAByMonster(MonsterModel monsterModel) async {
    if (monsterModel.qaRef == null) {
      debugPrint('[MonsterController] 此怪物沒有關聯的 QA');
      return null;
    }
    
    try {
      final doc = await monsterModel.qaRef!.get();
      if (doc.exists) {
        final qaData = QAModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        qa.value = qaData; // 更新 Rxn 狀態供 UI 監聽
        return qaData;
      }
    } catch (e) {
      debugPrint('[MonsterController] 獲取 QA 失敗: $e');
    }
    return null;
  }

  /// 傳入 MonsterModel 取得對應的 Architecture 資料
  Future<ArchitectureModel?> getArchitectureByMonster(MonsterModel monsterModel) async {
    if (monsterModel.architectureRef == null) {
      debugPrint('[MonsterController] 此怪物沒有關聯的建築資料');
      return null;
    }

    try {
      final doc = await monsterModel.architectureRef!.get();
      if (doc.exists) {
        final architectureData = ArchitectureModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
        architecture.value = architectureData; // 更新 Rxn 狀態供 UI 監聽
        return architectureData;
      }
    } catch (e) {
      debugPrint('[MonsterController] 獲取建築資料失敗: $e');
    }
    return null;
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
  Future<bool> captureMonster(MonsterModel monsterObj, String userId) async {
    try {
      // 建立 UserMonsterModel
      final userMonster = UserMonsterModel(
        monsterRef: FirebaseFirestore.instance.collection("monsters").doc(monsterObj.id),
        name: monsterObj.name,
        imageURL: monsterObj.imageURL,
        caughtAt: DateTime.now(),
      );

      // 新增到 Firestore
      await addUserMonster(userId, userMonster);

      // ✅ 捕捉成功後，自動更新對應怪物的 QA 資料與建築資料
      await loadMonsterWithRelations(monsterObj);

      // ✅ 捕捉後從 nearbyMonsters 移除 → 地圖上的 Marker 也會消失
      nearbyMonsters.removeWhere((m) => m.id == monsterObj.id);
      
      debugPrint('[MonsterController] 成功捕捉怪物: ${monsterObj.name} 並已同步更新 QA 與建築資料');
      return true;
    } catch (e) {
      debugPrint('[MonsterController] 捕捉怪物時出錯: $e');
      return false;
    }
  }

  Future<void> updateNearbyMonsters(Position userPosition) async {
    final monsters = await _service.getAllMonsters(); // 從資料庫抓全部
    
    // 💡 篩選：只加入「在範圍內」且「使用者尚未捕捉」的怪物
    nearbyMonsters.value = monsters.where((m) {
      // 1. 檢查是否已在收藏中 (根據 monster id 判斷)
      final isAlreadyCaptured = userMonsterCollection.any(
        (captured) => captured.monsterRef.id == m.id
      );
      
      // 2. 必須在距離內 且 尚未捕捉
      return _monsterService.isWithinRange(userPosition, m.location) && !isAlreadyCaptured;
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

  void updateNearestGlobal(Position userPosition) async{
    playerPosition.value = userPosition;
    debugPrint('[updateNearestGlobal] playerPosition 已更新: ${playerPosition.value?.latitude}, ${playerPosition.value?.longitude}');
    final all = await _service.getAllMonsters();
    if (all.isEmpty) {
      nearestMonster.value = null;
      nearestDistance.value = null;
      return;
    }

    final nearest = all.reduce((a, b) {
      final da = Geolocator.distanceBetween(
        userPosition.latitude, userPosition.longitude,
        a.location.latitude, a.location.longitude,
      );
      final db = Geolocator.distanceBetween(
        userPosition.latitude, userPosition.longitude,
        b.location.latitude, b.location.longitude,
      );
      return da < db ? a : b;
    });

    nearestMonster.value = nearest;
    nearestDistance.value = Geolocator.distanceBetween(
      userPosition.latitude, userPosition.longitude,
      nearest.location.latitude, nearest.location.longitude,
    );
    debugPrint('[updateNearestGlobal] 最近精靈: ${nearestMonster.value?.name}, 距離: ${nearestDistance.value}');
  }
}
