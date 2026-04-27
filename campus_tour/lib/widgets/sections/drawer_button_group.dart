import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:campus_tour/controllers/user_controller.dart';
import 'package:campus_tour/styles/LHF_drawer_styles.dart';
import 'package:campus_tour/widgets/buttons/LHF_drawer_button.dart';
import 'package:campus_tour/widgets/common/user_head.dart';
import 'package:campus_tour/view/full_mission_page.dart';
import 'package:campus_tour/view/LHF_setting_page.dart';
import 'package:campus_tour/view/leading_nfc_page.dart';
import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/models/monster_model.dart';
import 'package:campus_tour/models/qa_model.dart';
// game1
import 'package:campus_tour/widgets/game/catching_pages/camara_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';
//game2
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/full_mission.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';
import 'package:campus_tour/widgets/game/catching_pages/trace_levle.dart';

class DrawerButtonGroup extends StatelessWidget {
  const DrawerButtonGroup({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: DrawerStyles.drawerPadding,
        child: Column(
          crossAxisAlignment: DrawerStyles.drawerCrossAlignment,
          children: [
            const _DrawerUserHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buttonWidth = constraints.maxWidth.clamp(
                    0.0,
                    DrawerStyles.drawerButtonWidth,
                  );

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: buttonWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: DrawerStyles.drawerMainAlignment,
                            crossAxisAlignment:
                                DrawerStyles.drawerCrossAlignment,
                            //填滿格式設定
                            children: [
                              _SettingButton(),
                              // _NfcgButton(),
                              // _GraphicsTextButton(),
                              // _CryptographyButton(),
                              _QaValueDebugButton(),
                              _FullMissionOneButton(),
                              _FullMissionTwoButton(),
                              _FullMissionThreeButton(),
                              // _FullMissionDisabledButton(),
                            ], //左選單按鈕列,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final buttonWidth = constraints.maxWidth.clamp(
                  0.0,
                  DrawerStyles.drawerButtonWidth,
                );

                return Center(
                  child: SizedBox(
                    width: buttonWidth,
                    child: const _LogoutButton(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerUserHeader extends StatelessWidget {
  const _DrawerUserHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: DrawerStyles.drawerHeaderPadding,
          child: Row(
            children: [
              const _DrawerUserAvatar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _DrawerUserName(),
                      // Text('Campus Tour', style: DrawerStyles.userSubtitleText),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: DrawerStyles.drawerDividerHeight,
          color: DrawerStyles.drawerPanelBorderColor,
        ),
      ],
    );
  }
}

class _DrawerUserAvatar extends StatelessWidget {
  const _DrawerUserAvatar();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserController>()) {
      return const _DefaultDrawerAvatar();
    }

    return const UserHead(size: DrawerStyles.drawerAvatarSize);
  }
}

class _DefaultDrawerAvatar extends StatelessWidget {
  const _DefaultDrawerAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DrawerStyles.drawerAvatarSize,
      height: DrawerStyles.drawerAvatarSize,
      decoration: DrawerStyles.avatarDecoration,
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 34),
    );
  }
}

class _DrawerUserName extends StatelessWidget {
  const _DrawerUserName();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserController>()) {
      return Text('使用者名稱', style: DrawerStyles.userNameText);
    }

    final userController = Get.find<UserController>();

    return Obx(() {
      final nickname = userController.userModel.value?.nickname.trim();
      final displayName = nickname == null || nickname.isEmpty
          ? '使用者名稱'
          : nickname;

      return Text(displayName, style: DrawerStyles.userNameText);
    });
  }
}

class _SettingButton extends StatelessWidget {
  const _SettingButton();

  //設定按鈕實體化
  void onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: '設定',
      onPressedToDo: () => onPress(context),
    );
  }
}

//測試用
class _NfcgButton extends StatelessWidget {
  //NFC按鈕實體化
  final List<String> Idtest = ["85:45:BE:17", "21"];
  final List<String> Tex = ["mission 1", "mission 2"];
  void onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LeadingNfcPage(treasureID: Idtest, treasureText: Tex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: 'nfc',
      onPressedToDo: () => onPress(context),
    );
  }
}

//測試graphics_text_
class _GraphicsTextButton extends StatelessWidget {
  //GT按鈕實體化
  void nextFunction() {
    // Called when the NFC tag matched the expected ans.
    debugPrint('NFC matched');
  }

  void loseingFunction() {
    debugPrint('GraphicsText loseingFunction called');
  }

  final GraphicsTextLevel level = GraphicsTextLevel(
    firstTracePhoto: 'assets/images/campus_map_2.jpg',
    descriptionText: 'This is a description for testing.',
    nfcId: 'TEST_NFC_ID',
  );

  void onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GraphicsTextLevelPage(
          level: level,
          nextFunction: nextFunction,
          loseingFunction: loseingFunction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: 'graphics_text',
      onPressedToDo: () => onPress(context),
    );
  }
}

class _CryptographyButton extends StatelessWidget {
  //測試 cryptography 頁面的按鈕

  // 假資料：一組簡單的題目、選項與答案
  final CryptographyLevel level = CryptographyLevel(
    questionSet: ['第一題：1+1 = ?', '第二題：首字母是 A 的單字？'],
    choiceSet: [
      ['1', '2', '3'],
      ['Apple', 'Banana', 'Cat'],
    ],
    answerSet: ['2', 'Apple'],
  );

  // 假的怪物模型（使用指定的測試圖片）
  final MonsterModelCry monster = const MonsterModelCry(
    name: '測試小怪',
    type: '火',
    imageUrl: 'assets/images/Arcana.jpg',
  );

  // 三個回呼函式：next / finish / lose
  void nextFunction() {
    debugPrint('Cryptography nextFunction called');
  }

  void finishFunction() {
    debugPrint('Cryptography finishFunction called');
  }

  void loseingFunction() {
    debugPrint('Cryptography loseingFunction called');
  }

  void onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CryptographyLevelPage(
          level: level,
          monsterModel: monster,
          nextFunction: nextFunction,
          finishFunction: finishFunction,
          loseingFunction: loseingFunction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: 'cryptography',
      onPressedToDo: () => onPress(context),
    );
  }
}

class _QaValueDebugButton extends StatelessWidget {
  const _QaValueDebugButton();

  static const String _monsterJsonPath = 'assets/json/monster.json';
  static const String _targetMonsterName = 'SM獸';

  Future<void> _onPress(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final controller = Get.find<MonsterController>();
      final monster = await _loadTargetMonsterFromJson();
      final qa = await controller.getQAByMonster(monster);
      final qaValue = controller.qa.value;

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('QA 讀取測試'),
          content: SingleChildScrollView(
            child: Text(
              [
                '測試精靈：${monster.name} (${monster.id})',
                'qaRef：${monster.qaRef?.path ?? 'null'}',
                '',
                'getQAByMonster 回傳：',
                _formatQa(qa),
                '',
                'controller.qa.value：',
                _formatQa(qaValue),
              ].join('\n'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('關閉'),
            ),
          ],
        ),
      );
    } catch (e, st) {
      debugPrint('[QA Debug] 讀取失敗: $e');
      debugPrint('[QA Debug] stack trace: $st');

      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('QA 讀取失敗：$e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<MonsterModel> _loadTargetMonsterFromJson() async {
    final response = await rootBundle.loadString(_monsterJsonPath);
    final monsters = jsonDecode(response) as List<dynamic>;
    final targetMonsterData = monsters.cast<Map<dynamic, dynamic>>().firstWhere(
      (monster) => monster['name'] == _targetMonsterName,
    );
    return MonsterModel.fromMap(Map<String, dynamic>.from(targetMonsterData));
  }

  String _formatQa(QAModel? qa) {
    if (qa == null) {
      return 'null';
    }

    return [
      'id：${qa.id}',
      'question：${qa.question}',
      'options：${qa.options.join(' / ')}',
      'answer：${qa.answer}',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: 'qa debug',
      onPressedToDo: () => _onPress(context),
    );
  }
}

class _FullMissionOneButton extends StatelessWidget {
  const _FullMissionOneButton();

  @override
  Widget build(BuildContext context) {
    return _FullMissionButton(
      text: 'full mission 1',
      missions: _FullMissionData.graphicsOnlyMissions(),
      monsterModelCry: _FullMissionData.fireMonster,
    );
  }
}

class _FullMissionTwoButton extends StatelessWidget {
  const _FullMissionTwoButton();

  @override
  Widget build(BuildContext context) {
    return _FullMissionButton(
      text: 'full mission 2',
      missions: _FullMissionData.cryptographyOnlyMissions(),
      monsterModelCry: _FullMissionData.fireMonster,
    );
  }
}

class _FullMissionThreeButton extends StatelessWidget {
  const _FullMissionThreeButton();

  @override
  Widget build(BuildContext context) {
    return _FullMissionButton(
      text: 'full mission 3',
      missions: _FullMissionData.mixedPlayableMissions(),
      monsterModelCry: _FullMissionData.waterMonster,
    );
  }
}

// class _FullMissionDisabledButton extends StatelessWidget {
//   const _FullMissionDisabledButton();

//   @override
//   Widget build(BuildContext context) {
//     return _FullMissionButton(
//       text: 'full mission disabled',
//       missions: _FullMissionData.disabledMissions(),
//       monsterModelCry: _FullMissionData.waterMonster,
//     );
//   }
// }

class _FullMissionButton extends StatelessWidget {
  const _FullMissionButton({
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

class _FullMissionData {
  static const MonsterModelCry fireMonster = MonsterModelCry(
    name: '測試火精靈',
    type: '火',
    imageUrl: 'assets/images/Arcana.jpg',
  );

  static const MonsterModelCry waterMonster = MonsterModelCry(
    name: '測試水精靈',
    type: '水',
    imageUrl: 'assets/images/campus_map_2.jpg',
  );

  static List<FullMission> graphicsOnlyMissions() {
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

  static List<FullMission> cryptographyOnlyMissions() {
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

  static List<FullMission> mixedPlayableMissions() {
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

  static List<FullMission> disabledMissions() {
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

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  void _onPress() {
    debugPrint('[Drawer] logout pressed');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: DrawerStyles.logoutButtonStyle,
      onPressed: _onPress,
      icon: const Icon(Icons.logout_rounded),
      label: Text('登出', style: DrawerStyles.logoutButtonText),
    );
  }
}
