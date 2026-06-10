import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/firestore_service.dart';
import '../models/monster_model.dart';
import '../models/architecture_model.dart';
import '../models/qa_model.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_monster_model.dart';
import "../services/monster_service.dart";

class MonsterController extends GetxController {
  final FirestoreService _service = FirestoreService();
  final MonsterService _monsterService = MonsterService();
  int _stateVersion = 0;

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
    await Future.wait([
      getQAByMonster(monsterModel),
      getArchitectureByMonster(monsterModel),
    ]);
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
        final qaData = QAModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
        qa.value = qaData;
        return qaData;
      }
    } catch (e) {
      debugPrint('[MonsterController] 獲取 QA 失敗: $e');
    }
    return null;
  }

  /// 傳入 MonsterModel 取得對應的 Architecture 資料
  Future<ArchitectureModel?> getArchitectureByMonster(
    MonsterModel monsterModel,
  ) async {
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
        architecture.value = architectureData;
        return architectureData;
      }
    } catch (e) {
      debugPrint('[MonsterController] 獲取建築資料失敗: $e');
    }
    return null;
  }

  // 載入使用者的圖鑑（例如從 Firestore）
  Future<void> loadUserCollection(String userId) async {
    final requestVersion = _stateVersion;
    final result = await _service.getUserMonsters(userId);
    if (requestVersion != _stateVersion) return;

    userMonsterCollection.value = result;
  }

  // 抓到怪物時更新圖鑑
  Future<void> addUserMonster(
    String userId,
    UserMonsterModel userMonster,
  ) async {
    await _service.addUserMonster(userId, userMonster);
    await loadUserCollection(userId);
  }

  // 捕捉怪物 - 從 nearbyMonsters 中選擇要捕捉的怪物
  Future<bool> captureMonster(MonsterModel monsterObj, String userId) async {
    final requestVersion = _stateVersion;
    try {
      final alreadyCaptured = userMonsterCollection.any(
        (m) => m.monsterRef.id == monsterObj.id,
      );

      if (alreadyCaptured) {
        debugPrint('[MonsterController] 怪物 ${monsterObj.name} 已經被捕捉過');
        return false;
      }

      final userMonster = UserMonsterModel(
        monsterRef: FirebaseFirestore.instance
            .collection("monsters")
            .doc(monsterObj.id),
        name: monsterObj.name,
        type: monsterObj.type,
        imageURL: monsterObj.imageURL,
        arRef: monsterObj.arRef ?? '',
        videoRef: monsterObj.videoRef ?? '',
        caughtAt: DateTime.now(),
      );

      await addUserMonster(userId, userMonster);

      if (requestVersion != _stateVersion) return false;

      await loadMonsterWithRelations(monsterObj);
      nearbyMonsters.removeWhere((m) => m.id == monsterObj.id);

      debugPrint(
        '[MonsterController] 成功捕捉怪物: ${monsterObj.name} 並已同步更新 QA 與建築資料',
      );
      return true;
    } catch (e) {
      debugPrint('[MonsterController] 捕捉怪物時出錯: $e');
      return false;
    }
  }

  Future<int> captureAllMonstersForTesting(String userId) async {
    final requestVersion = _stateVersion;
    final monsters = await _service.getAllMonsters();
    if (requestVersion != _stateVersion) return 0;

    final capturedIds = userMonsterCollection
        .map((captured) => captured.monsterRef.id)
        .toSet();
    final missingMonsters = monsters
        .where((monster) => !capturedIds.contains(monster.id))
        .toList();
    final caughtAt = DateTime.now();

    for (final monsterObj in missingMonsters) {
      final userMonster = UserMonsterModel(
        monsterRef: FirebaseFirestore.instance
            .collection("monsters")
            .doc(monsterObj.id),
        name: monsterObj.name,
        type: monsterObj.type,
        imageURL: monsterObj.imageURL,
        arRef: monsterObj.arRef ?? '',
        videoRef: monsterObj.videoRef ?? '',
        caughtAt: caughtAt,
      );

      await _service.setUserMonster(userId, monsterObj.id, userMonster);
    }

    if (requestVersion != _stateVersion) return 0;

    await loadUserCollection(userId);
    final missingIds = missingMonsters.map((monster) => monster.id).toSet();
    nearbyMonsters.removeWhere((monster) => missingIds.contains(monster.id));
    nearestMonster.value = null;
    nearestDistance.value = null;

    debugPrint('[MonsterController] 測試功能捕捉全部精靈: ${missingMonsters.length}');
    return missingMonsters.length;
  }

  Future<int> deleteAllUserMonstersForTesting(String userId) async {
    final requestVersion = _stateVersion;
    final deletedCount = userMonsterCollection.length;

    await _service.deleteAllUserMonsters(userId);
    if (requestVersion != _stateVersion) return 0;

    userMonsterCollection.clear();
    nearbyMonsters.clear();
    nearestMonster.value = null;
    nearestDistance.value = null;

    final currentPosition = playerPosition.value;
    if (currentPosition != null) {
      await updateLocationMonsters(currentPosition);
    }

    debugPrint('[MonsterController] 測試功能刪除全部精靈: $deletedCount');
    return deletedCount;
  }

  Future<void> updateLocationMonsters(Position userPosition) async {
    final requestVersion = _stateVersion;
    playerPosition.value = userPosition;

    final monsters = await _service.getAllMonsters();
    if (requestVersion != _stateVersion) return;

    final capturedIds = userMonsterCollection
        .map((captured) => captured.monsterRef.id)
        .toSet();
    final uncaught = monsters
        .where((monster) => !capturedIds.contains(monster.id))
        .toList();

    nearbyMonsters.value = uncaught
        .where(
          (monster) =>
              _monsterService.isWithinRange(userPosition, monster.location),
        )
        .toList();

    if (uncaught.isEmpty) {
      nearestMonster.value = null;
      nearestDistance.value = null;
      return;
    }

    final nearest = uncaught.reduce((a, b) {
      final da = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        a.location.latitude,
        a.location.longitude,
      );
      final db = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        b.location.latitude,
        b.location.longitude,
      );
      return da < db ? a : b;
    });

    nearestMonster.value = nearest;
    nearestDistance.value = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      nearest.location.latitude,
      nearest.location.longitude,
    );
    debugPrint(
      '[MonsterController] 最近精靈: ${nearestMonster.value?.name}, 距離: ${nearestDistance.value}',
    );
  }

  void resetForLogout() {
    _stateVersion++;
    monster.value = null;
    architecture.value = null;
    qa.value = null;
    nearbyMonsters.clear();
    nearestMonster.value = null;
    nearestDistance.value = null;
    userMonsterCollection.clear();
    playerPosition.value = null;
  }
}
