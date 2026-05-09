import 'package:flutter/material.dart';
import 'package:campus_tour/widgets/constants/asset_paths.dart';
import 'package:campus_tour/widgets/game/catching_pages/battle_start_transition.dart';
import 'package:campus_tour/widgets/game/catching_pages/catching_faild.dart';
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/full_mission.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';
import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/plot_level_page.dart';

class FullMissionPage extends StatefulWidget {
  final List<FullMission> missions; //任務列表
  final MonsterModelCry monsterModelCry; //精靈資料
  final Future<void> Function()? onMissionFinished;
  final VoidCallback? onMissionFailed;

  //建構子
  const FullMissionPage({
    super.key,
    required this.missions,
    required this.monsterModelCry,
    this.onMissionFinished,
    this.onMissionFailed,
  });

  @override
  State<FullMissionPage> createState() => _FullMissionPageState();
}

class _FullMissionPageState extends State<FullMissionPage> {
  int _missionIndex = 0;
  bool _isFinishing = false;
  bool _showBattleTransition = false;
  bool _isTransitioning = false;

  void nextFunction() {
    // [L-01]
    if (_isTransitioning) {
      return;
    }

    // [L-02]
    if (_missionIndex >= widget.missions.length - 1) {
      finishFunction();
      return;
    }

    // [L-03]
    if (_shouldPlayBattleTransition(widget.missions[_missionIndex])) {
      // [L-04]
      setState(() {
        _showBattleTransition = true;
        _isTransitioning = true;
      });
      return;
    }

    // [L-05]
    _advanceMission();
  }

  void _advanceMission() {
    // [L-06]
    setState(() {
      _missionIndex += 1;
    });
  }

  void loseingFunction() {
    // [L-07]
    widget.onMissionFailed?.call();
    // [L-08]
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CatchingFaildPage()),
    );
  }

  Future<void> finishFunction() async {
    // [L-09]
    if (_isFinishing) return;
    // [L-10]
    _isFinishing = true;
    // [L-11]
    debugPrint('成功捕捉精靈: ${widget.monsterModelCry.name}');
    // [L-12]
    await widget.onMissionFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    // [L-13]
    if (widget.missions.isEmpty) {
      // [L-14]
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // [L-15]
        if (mounted) {
          finishFunction();
        }
      });

      // [L-16]
      return const PopScope(
        canPop: false,
        child: Scaffold(body: Center(child: Text('沒有關卡'))),
      );
    }

    // [L-17]
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          // [L-18]
          _buildMissionPage(widget.missions[_missionIndex]),
          // [L-19]
          if (_showBattleTransition)
            BattleStartTransition(
              monsterImagePath: widget.monsterModelCry.imageUrl,
              monsterType: widget.monsterModelCry.type,
              playerImagePath: AssetPaths.squirrel,
              // [L-20]
              onClosed: _advanceMission,
              // [L-21]
              onFinished: () {
                setState(() {
                  _showBattleTransition = false;
                  _isTransitioning = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMissionPage(FullMission mission) {
    // [L-22]
    if (_isCryptographyMission(mission)) {
      return CryptographyLevelPage(
        level: mission.cryptography,
        monsterModel: widget.monsterModelCry,
        nextFunction: () {
          debugPrint('Cryptography question completed');
        },
        finishFunction: nextFunction,
        loseingFunction: loseingFunction,
      );
    }

    // [L-23]
    if (_isGraphicsTextMission(mission)) {
      return GraphicsTextLevelPage(
        level: mission.graphicsText,
        nextFunction: nextFunction,
        loseingFunction: loseingFunction,
      );
    }

    // [L-24]
    if (_isPlotMission(mission)) {
      return PlotLevelPage(plotLevel: mission.plot, nextFunction: nextFunction);
    }

    // [L-25]
    if (_isCamaraMission(mission) || _isTraceMission(mission)) {
      return _buildDisabledPage(mission);
    }

    // [L-26]
    return ErrorWidget('未知關卡類型: ${mission.levelType}');
  }

  bool _isCryptographyMission(FullMission mission) {
    // [L-27]
    return mission.isCryptography ||
        mission.levelType.toLowerCase() == 'cryptography';
  }

  bool _isGraphicsTextMission(FullMission mission) {
    // [L-28]
    final levelType = mission.levelType.toLowerCase();
    return mission.isGraphicsText ||
        levelType == 'graphics_text' ||
        levelType == 'graphicstext';
  }

  bool _isPlotMission(FullMission mission) {
    // [L-29]
    final levelType = mission.levelType.toLowerCase();
    return mission.isPlot || levelType == 'plot' || levelType == 'plotlevel';
  }

  bool _isCamaraMission(FullMission mission) {
    // [L-30]
    final levelType = mission.levelType.toLowerCase();
    return mission.isCamara || levelType == 'camara' || levelType == 'camera';
  }

  bool _isTraceMission(FullMission mission) {
    // [L-31]
    final levelType = mission.levelType.toLowerCase();
    return mission.isTrace ||
        levelType == 'trace' ||
        levelType == 'vr' ||
        levelType == 'ar';
  }

  bool _shouldPlayBattleTransition(FullMission mission) {
    // [L-32]
    final nextMission = widget.missions[_missionIndex + 1];
    // [L-33]
    return mission.isPlot &&
        mission.plot.type == PlotLevel.battleType &&
        _isCryptographyMission(nextMission);
  }

  Widget _buildDisabledPage(FullMission mission) {
    // [L-34]
    debugPrint('禁用頁面');
    // [L-35]
    return ErrorWidget('禁用頁面: ${mission.levelType}');
  }
}
