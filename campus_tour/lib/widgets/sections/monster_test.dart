import 'package:campus_tour/view/full_mission_page.dart';
import 'package:campus_tour/widgets/buttons/LHF_drawer_button.dart';
import 'package:campus_tour/widgets/game/catching_pages/camara_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/full_mission.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';
import 'package:campus_tour/widgets/game/catching_pages/trace_levle.dart';
import 'package:flutter/material.dart';

// Temporary FullMissionPage test entries.
// Remove this file and the FullMissionTestButtonGroup usage in
// drawer_button_group.dart when the real monster mission data is connected.
class FullMissionTestButtonGroup extends StatelessWidget {
  const FullMissionTestButtonGroup({super.key});

  static const MonsterModelCry _fireMonster = MonsterModelCry(
    name: '測試火精靈',
    type: '火',
    imageUrl: 'assets/images/Arcana.jpg',
  );

  static const MonsterModelCry _waterMonster = MonsterModelCry(
    name: '測試水精靈',
    type: '水',
    imageUrl: 'assets/images/campus_map_2.jpg',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FullMissionTestButton(
          text: 'full mission 1',
          missions: _graphicsOnlyMissions(),
          monsterModelCry: _fireMonster,
        ),
        _FullMissionTestButton(
          text: 'full mission 2',
          missions: _cryptographyOnlyMissions(),
          monsterModelCry: _fireMonster,
        ),
        _FullMissionTestButton(
          text: 'full mission 3',
          missions: _mixedPlayableMissions(),
          monsterModelCry: _waterMonster,
        ),
        _FullMissionTestButton(
          text: 'full mission disabled',
          missions: _disabledMissions(),
          monsterModelCry: _waterMonster,
        ),
      ],
    );
  }

  List<FullMission> _graphicsOnlyMissions() {
    return [
      FullMission(
        levelType: 'graphics_text',
        graphicsTextLevel: GraphicsTextLevel(
          firstTracePhoto: 'assets/images/campus_map_2.jpg',
          descriptionText: '測試圖文關卡 1：觀察地圖後掃描 TEST_NFC_ID。',
          nfcId: '04:9E:69:D2:2E:61:80',
        ),
      ),
      FullMission(
        levelType: 'graphics_text',
        graphicsTextLevel: GraphicsTextLevel(
          descriptionText: '測試圖文關卡 2：純文字線索。',
          nfcId: '04:9E:69:D2:2E:61:80',
        ),
      ),
    ];
  }

  List<FullMission> _cryptographyOnlyMissions() {
    return [
      FullMission(
        levelType: 'cryptography',
        cryptographyLevel: CryptographyLevel(
          questionSet: ['第一題：1+1 = ?', '第二題：首字母是 A 的單字？'],
          choiceSet: [
            ['1', '2', '3'],
            ['Apple', 'Banana', 'Cat'],
          ],
          answerSet: ['2', 'Apple'],
        ),
      ),
    ];
  }

  List<FullMission> _mixedPlayableMissions() {
    return [
      FullMission(
        levelType: 'graphics_text',
        graphicsTextLevel: GraphicsTextLevel(
          firstTracePhoto: 'assets/images/campus_map_2.jpg',
          descriptionText: '混合測試第 1 關：先掃 NFC。',
          nfcId: '04:9E:69:D2:2E:61:80',
        ),
      ),
      FullMission(
        levelType: 'cryptography',
        cryptographyLevel: CryptographyLevel(
          questionSet: ['校園英文是？', 'Flutter 使用哪個語言？'],
          choiceSet: [
            ['Campus', 'Camera', 'Capture'],
            ['Dart', 'Java', 'Swift'],
          ],
          answerSet: ['Campus', 'Dart'],
        ),
      ),
      FullMission(
        levelType: 'graphics_text',
        graphicsTextLevel: GraphicsTextLevel(
          firstTracePhoto: 'assets/images/Arcana.jpg',
          descriptionText: '混合測試第 3 關：最後再掃一次 NFC。',
          nfcId: '04:A7:5A:4B:57:59:80',
        ),
      ),
    ];
  }

  List<FullMission> _disabledMissions() {
    return [
      FullMission(
        levelType: 'camara',
        camaraLevel: CamaraLevel(
          recognitionFunction: (value) => value == 'TEST_CAMERA_TARGET',
        ),
      ),
      FullMission(
        levelType: 'trace',
        traceLevel: TraceLevle(
          tracePhoto: 'assets/images/campus_map_2.jpg',
          nfcId: 'TEST_TRACE_NFC_ID',
          arInformation: '測試 VR/AR 關卡資料，現在應該被 FullMissionPage 禁用。',
        ),
      ),
    ];
  }
}

class _FullMissionTestButton extends StatelessWidget {
  const _FullMissionTestButton({
    required this.text,
    required this.missions,
    required this.monsterModelCry,
  });

  final String text;
  final List<FullMission> missions;
  final MonsterModelCry monsterModelCry;

  void _onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullMissionPage(
          missions: missions,
          monsterModelCry: monsterModelCry,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: text,
      onPressedToDo: () => _onPress(context),
    );
  }
}
