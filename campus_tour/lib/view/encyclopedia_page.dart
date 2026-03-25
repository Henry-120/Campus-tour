import 'package:flutter/material.dart';

import '../controllers/encyclopedia_controller.dart';
import '../models/item_model.dart';
import '../widgets/encyclopedia/elf_grid.dart';
import '../widgets/encyclopedia/filter_bar.dart';


class EncyclopediaPage extends StatefulWidget {
  const EncyclopediaPage({super.key});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}


class _EncyclopediaPageState extends State<EncyclopediaPage> {
  int currentFilter = 1;
  final EncyclopediaController _controller = EncyclopediaController();

  // 原始資料 (get from database)
  final List<ElfItem> _allItems = List.generate(30, (i) {
    // 模擬一些隨機的解鎖狀態
    return ElfItem(
      id: i + 1,
      name: '精靈 ${i + 1}',
      isUnlocked: i % 3 == 0, // 每隔兩隻就有一隻是解鎖的
    );
  });

  @override
  Widget build(BuildContext context) {
    // 根據目前的篩選值計算要顯示的列表
    final displayItems = _controller.getPageItems(_allItems, currentFilter);

    return Scaffold(
      appBar: AppBar(title: const Text('圖鑑'), centerTitle: true),
      body: Column(
        children: [
          // 網格區塊被抽離了
          Expanded(
            child: ElfGrid(
              items: displayItems,
              onItemTap: (item) => debugPrint('_showDetail(item)'),
            ),
          ),
          // 篩選列
          FilterBar(
            selectedIndex: currentFilter,
            onSelect: (index) => setState(() => currentFilter = index),
          ),
        ],
      ),
    );
  }
}