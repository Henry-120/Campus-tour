import 'package:campus_tour/widgets/constants/asset_paths.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFFFF6EF),
      appBar: AppBar(
        title: const Text(
          '圖鑑',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A3A32),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF4A3A32),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AssetPaths.encyclopediaBg,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: const [
                SizedBox(height: 20),
                Expanded(child: ElfGrid()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}