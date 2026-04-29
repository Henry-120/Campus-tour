import 'package:campus_tour/widgets/encyclopedia/page_selector.dart';
import 'package:flutter/material.dart';
import '../common/elf_card.dart';
import '../../view/elf_detail_page.dart';
import '../../controllers/encyclopedia_controller.dart';
import '../../models/monster_model.dart';
import 'package:get/get.dart';
import '../../controllers/monster_controller.dart';

class ElfGrid extends StatefulWidget {
  const ElfGrid({super.key});

  @override
  State<ElfGrid> createState() => _ElfGridState();
}

class _ElfGridState extends State<ElfGrid> {
  final EncyclopediaController _controller = EncyclopediaController();
  final MonsterController _monsterController = Get.find<MonsterController>();
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allUserMonsters = _monsterController.userMonsterCollection;

      if (allUserMonsters.isEmpty) {
        return const Center(child: Text("尚未捕捉任何怪物"));
      }

      // 取得當前頁面的資料
      final pageItems = _controller.getPageItems(_currentPage);
      final totalPages = _controller.getTotalPages();

      // 如果當前頁面沒資料（可能因為刪除），自動跳回前一頁
      if (pageItems.isEmpty && _currentPage > 1) {
        Future.microtask(() => setState(() => _currentPage--));
      }

      return Column(
        children: [
          // 3x3 網格區域
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: pageItems.length,
              itemBuilder: (context, index) {
                final userMonster = pageItems[index];
                return ElfCard(
                  item: userMonster,
                  onTap: () async {
                    final monster = await _controller.getMonster(userMonster.monsterRef);
                    if (monster != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ElfDetailPage(monsterModel: monster),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),

      PageSelector(
        currentPage: _currentPage,
        totalPages: totalPages,
        onPrevious: _currentPage > 1
        ? () => setState(() => _currentPage--)
            : null,
        onNext: _currentPage < totalPages
        ? () => setState(() => _currentPage++)
            : null,
        ),
      ]
      );
    });
  }
}
