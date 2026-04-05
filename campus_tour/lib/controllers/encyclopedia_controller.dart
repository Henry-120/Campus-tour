import '../models/item_model.dart';
import '../controllers/monster_controller.dart';
import 'package:get/get.dart';

class EncyclopediaController {
  final int itemsPerPage = 9; // 假設一頁顯示 9 個 (3x3)
  final MonsterController _monsterController = Get.find<MonsterController>();

  List<ElfItem> getPageItems(List<ElfItem> allItems, int pageNumber) {
    // 計算這一頁應該從哪裡開始，到哪裡結束
    // 舉例：第一頁 (pageNumber=1) 從 index 0 開始到 9
    int startIndex = (pageNumber - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    // 防止超出陣列範圍
    if (startIndex >= allItems.length) return [];
    if (endIndex > allItems.length) endIndex = allItems.length;

    return allItems.sublist(startIndex, endIndex);
  }

  List<ElfItem> getDisplayItems() {
    return _monsterController.userMonsterCollection.map((m) {
      return ElfItem(
        id: m.docId ?? "",
        name: m.name, // 取名字
        imageUrl: m.imageURL, // 取圖片
        isUnlocked: true,
      );
    }).toList();
  }
}
