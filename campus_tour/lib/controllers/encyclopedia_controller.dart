import 'package:campus_tour/models/architecture_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_monster_model.dart';
import '../controllers/monster_controller.dart';
import 'package:get/get.dart';
import '../models/monster_model.dart';
class EncyclopediaController {
  final int itemsPerPage = 9; // 假設一頁顯示 9 個 (3x3)
  final MonsterController _monsterController = Get.find<MonsterController>();

  List<UserMonsterModel> getPageItems(int pageNumber) {
    // 計算這一頁應該從哪裡開始，到哪裡結束
    // 舉例：第一頁 (pageNumber=1) 從 index 0 開始到 9
    int startIndex = (pageNumber - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    RxList<UserMonsterModel> allItems = _monsterController.userMonsterCollection;
    // 防止超出陣列範圍
    if (startIndex >= allItems.length) return [];
    if (endIndex > allItems.length) endIndex = allItems.length;

    return allItems.sublist(startIndex, endIndex);
  }

  Future<MonsterModel?> getMonster (DocumentReference ref) async {
    final snapshot = await ref.get(); // 取出文件內容
    if (!snapshot.exists) return null;

    // 假設你有 MonsterModel.fromJson(Map<String, dynamic>)
    return MonsterModel.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<String?> getStory (DocumentReference ref) async{
    final snapshot = await ref.get(); // 取出文件內容
    if (!snapshot.exists) return null;

    return ArchitectureModel.fromMap(snapshot.data() as Map<String, dynamic>).story;
  }
}


