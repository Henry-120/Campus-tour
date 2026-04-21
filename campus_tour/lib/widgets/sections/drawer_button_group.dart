import 'package:flutter/material.dart';
import 'package:campus_tour/styles/LHF_drawer_styles.dart';
import 'package:campus_tour/widgets/buttons/LHF_drawer_button.dart';
import 'package:campus_tour/view/LHF_setting_page.dart';
import 'package:campus_tour/view/leading_nfc_page.dart';

class DrawerButtonGroup extends StatelessWidget {
  const DrawerButtonGroup({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: DrawerStyles.drawer_main_alignment,
      crossAxisAlignment: DrawerStyles.drawer_cross_alignment,
      //填滿格式設定
      children: [_SettingButton(), _NfcgButton()], //左選單按鈕列,
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
  //設定按鈕實體化
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
