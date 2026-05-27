import 'package:campus_tour/widgets/constants/asset_paths.dart';
import 'package:flutter/material.dart';

import '../styles/app_theme.dart';
import '../widgets/encyclopedia/elf_grid.dart';

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
        title: Text(
          '圖鑑',
          style: AppTheme.titleStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A3A32),
            letterSpacing: 0,
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
            child: Image.asset(AssetPaths.encyclopediaBg, fit: BoxFit.cover),
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
