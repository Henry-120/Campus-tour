import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> updateNearbyMonsters(Position userPosition) async {
    final monsters = await _service.getAllMonsters(); // 從資料庫抓全部
    nearbyMonsters.value = monsters.where((m) {
      return _monsterService.isWithinRange(userPosition, m.location);
    }).toList();
  }


//
  // //之後要拿掉，用來建立user monster collection 的假資料
  // Future<void> seedUserMonsters(String uid) async {
  //   final db = FirebaseFirestore.instance;
  //
  //   // 假設怪物文件已經存在
  //   final m1Ref = db.collection("monsters").doc("m1");
  //   final m2Ref = db.collection("monsters").doc("m2");
  //   final m3Ref = db.collection("monsters").doc("m3");
  //
  //   // 建立三筆測試資料
  //   await addUserMonster(uid, UserMonsterModel(
  //     monsterRef: m1Ref,
  //     caughtAt: DateTime.now().subtract(const Duration(days: 2)),
  //     name: "m1",
  //     imageURL: "assets/images/fairy_img/中大湖.jpg"
  //   ));
  //
  //   await addUserMonster(uid, UserMonsterModel(
  //     monsterRef: m2Ref,
  //     caughtAt: DateTime.now().subtract(const Duration(days: 1)),
  //     name: "m2",
  //     imageURL: "assets/images/fairy_img/客家學院.jpg"
  //   ));
  //
  //   await addUserMonster(uid, UserMonsterModel(
  //     monsterRef: m3Ref,
  //     caughtAt: DateTime.now(),
  //     name: "m3",
  //     imageURL: "assets/images/fairy_img/傑尼龜.jpg"
  //   ));
  // }


}