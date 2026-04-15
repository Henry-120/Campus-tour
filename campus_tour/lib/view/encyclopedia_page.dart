import 'package:flutter/material.dart';

import '../controllers/encyclopedia_controller.dart';
import '../models/user_monster_model.dart';
import '../widgets/encyclopedia/elf_grid.dart';
import '../widgets/encyclopedia/filter_bar.dart';
import '../controllers/monster_controller.dart';
import 'package:get/get.dart';


class EncyclopediaPage extends StatefulWidget {
  const EncyclopediaPage({super.key});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}


class _EncyclopediaPageState extends State<EncyclopediaPage> {
  int currentFilter = 1;
  final monsterController = Get.find<MonsterController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('圖鑑'), centerTitle: true),
      body: Column(
        children: [
          // 網格區塊被抽離了
          Expanded(
            child: ElfGrid()),

        ],
      ),
    );
  }
}