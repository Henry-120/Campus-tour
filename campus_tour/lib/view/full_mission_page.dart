import 'package:flutter/material.dart';
import 'package:campus_tour/widgets/game/catching_pages/catching_faild.dart';
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/full_mission.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';

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

  void nextFunction() {
    if (_missionIndex >= widget.missions.length - 1) {
      finishFunction();
      return;
    }

    setState(() {
      _missionIndex += 1;
    });
  }

  void loseingFunction() {
    widget.onMissionFailed?.call();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CatchingFaildPage()),
    );
  }

  Future<void> finishFunction() async {
    if (_isFinishing) return;
    _isFinishing = true;
    debugPrint('成功捕捉精靈: ${widget.monsterModelCry.name}');
    await widget.onMissionFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.missions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          finishFunction();
        }
      });

      return const PopScope(
        canPop: false,
        child: Scaffold(body: Center(child: Text('沒有關卡'))),
      );
    }

    return PopScope(
      canPop: false,
      child: _buildMissionPage(widget.missions[_missionIndex]),
    );
  }

  Widget _buildMissionPage(FullMission mission) {
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

    if (_isGraphicsTextMission(mission)) {
      return GraphicsTextLevelPage(
        level: mission.graphicsText,
        nextFunction: nextFunction,
        loseingFunction: loseingFunction,
      );
    }

    if (_isCamaraMission(mission) || _isTraceMission(mission)) {
      return _buildDisabledPage(mission);
    }

    return ErrorWidget('未知關卡類型: ${mission.levelType}');
  }

  bool _isCryptographyMission(FullMission mission) {
    return mission.isCryptography ||
        mission.levelType.toLowerCase() == 'cryptography';
  }

  bool _isGraphicsTextMission(FullMission mission) {
    final levelType = mission.levelType.toLowerCase();
    return mission.isGraphicsText ||
        levelType == 'graphics_text' ||
        levelType == 'graphicstext';
  }

  bool _isCamaraMission(FullMission mission) {
    final levelType = mission.levelType.toLowerCase();
    return mission.isCamara || levelType == 'camara' || levelType == 'camera';
  }

  bool _isTraceMission(FullMission mission) {
    final levelType = mission.levelType.toLowerCase();
    return mission.isTrace ||
        levelType == 'trace' ||
        levelType == 'vr' ||
        levelType == 'ar';
  }

  Widget _buildDisabledPage(FullMission mission) {
    debugPrint('禁用頁面');
    return ErrorWidget('禁用頁面: ${mission.levelType}');
  }
}
