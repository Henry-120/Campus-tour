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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userMonsters = _monsterController.userMonsterCollection;

      if (userMonsters.isEmpty) {
        return const Center(child: Text("尚未捕捉任何怪物"));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: userMonsters.length,
        itemBuilder: (context, index) {
          final userMonster = userMonsters[index];
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
      );
    });
  }
}
