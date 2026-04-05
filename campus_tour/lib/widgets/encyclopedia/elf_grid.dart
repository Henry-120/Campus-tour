import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../common/elf_card.dart';
import '../../view/elf_detail_page.dart';
import '../../controllers/encyclopedia_controller.dart';
import '../../models/monster_model.dart';

class ElfGrid extends StatefulWidget {
  final List<ElfItem> items;
  const ElfGrid({super.key, required this.items});

  @override
  State<ElfGrid> createState() => _ElfGridState();
}

class _ElfGridState extends State<ElfGrid> {
  final EncyclopediaController _controller = EncyclopediaController();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return ElfCard(
          item: item,
          onTap: () async {
            // 先透過 controller 取得 MonsterModel
            final monster = await _controller.getMonster(item.monsterRef);
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
  }
}
