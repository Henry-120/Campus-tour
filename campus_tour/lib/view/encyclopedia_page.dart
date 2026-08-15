import 'package:campus_tour/widgets/constants/asset_paths.dart';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../styles/app_theme.dart';
import '../widgets/encyclopedia/elf_grid.dart';
import '../controllers/monster_controller.dart';
import 'package:get/get.dart';

class EncyclopediaPage extends StatefulWidget {
  const EncyclopediaPage({super.key});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends State<EncyclopediaPage> with WidgetsBindingObserver {
  void _playBgmByProgress() {
    final controller = Get.find<MonsterController>();
    final caughtCount = controller.userMonsterCollection.length;
    final totalCount = controller.totalMonsterCount.value;

    final isComplete =
        totalCount != null && totalCount > 0 && caughtCount >= totalCount;

    if (isComplete) {
      AudioService().playOverlayBgm(fileName: 'audio/M13_final_stage_BPM130.m4a');
    } else {
      AudioService().playOverlayBgm(fileName: 'audio/M11_encyclopedia.m4a');
    }
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playBgmByProgress();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService().pauseAllBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioService().resumeAllBgm();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AudioService().stopOverlayBgm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFF6EF),
      appBar: AppBar(
        title: Text(
          'view.encyclopedia.page.s001'.tr,
          style: AppTheme.titleStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A3A32),
            letterSpacing: 0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF4A3A32),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AssetPaths.encyclopediaBg, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
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
