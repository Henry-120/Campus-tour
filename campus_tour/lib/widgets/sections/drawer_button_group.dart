import 'package:flutter/material.dart';
import 'package:campus_tour/styles/LHF_drawer_styles.dart';
import 'package:campus_tour/widgets/buttons/LHF_drawer_button.dart';
import 'package:campus_tour/view/LHF_setting_page.dart';
import 'package:campus_tour/view/leading_nfc_page.dart';
// game1
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';
//game2
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';

class DrawerButtonGroup extends StatelessWidget {
  const DrawerButtonGroup({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: DrawerStyles.drawer_main_alignment,
      crossAxisAlignment: DrawerStyles.drawer_cross_alignment,
      //填滿格式設定
      children: [
        _SettingButton(),
        _NfcgButton(),
        _GraphicsTextButton(),
        _CryptographyButton(),
      ], //左選單按鈕列,
    );
  }
}

class _SettingButton extends StatelessWidget {
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
