import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../common/elf_card.dart';

class ElfGrid extends StatelessWidget {
  final List<ElfItem> items;
  final Function(ElfItem) onItemTap;

  const ElfGrid({super.key, required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8, // 調整比例讓卡片更好看
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => ElfCard(
        item: items[index],
        onTap: () => onItemTap(items[index]),
      ),
    );
  }
}