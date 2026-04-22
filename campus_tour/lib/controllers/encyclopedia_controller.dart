import 'package:campus_tour/models/architecture_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_monster_model.dart';
import '../controllers/monster_controller.dart';
import 'package:get/get.dart';
import '../models/monster_model.dart';

class EncyclopediaController {
  final int itemsPerPage = 9; // 一頁顯示 9 個 (3x3)
  final MonsterController _monsterController = Get.find<MonsterController>();

  // 取得特定頁面的資料
  List<UserMonsterModel> getPageItems(int pageNumber) {
    int startIndex = (pageNumber - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    // 使用 .toList() 確保我們操作的是當前快照
    List<UserMonsterModel> allItems = _monsterController.userMonsterCollection.toList();

    if (startIndex >= allItems.length) return [];
    if (endIndex > allItems.length) endIndex = allItems.length;

    return allItems.sublist(startIndex, endIndex);
  }

  // 計算總頁數
  int getTotalPages() {
    int totalItems = _monsterController.userMonsterCollection.length;
    if (totalItems == 0) return 1;
    return (totalItems / itemsPerPage).ceil();
  }

  Future<MonsterModel?> getMonster (DocumentReference ref) async {
    final snapshot = await ref.get();
    if (!snapshot.exists) return null;
    return MonsterModel.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<String?> getStory (DocumentReference ref) async {
    final snapshot = await ref.get();
    if (!snapshot.exists) return null;
    return ArchitectureModel.fromMap(snapshot.data() as Map<String, dynamic>).story;
  }
}
