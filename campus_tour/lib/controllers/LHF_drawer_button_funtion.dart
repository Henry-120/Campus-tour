import 'package:flutter/material.dart';
import 'package:campus_tour/view/LHF_setting_page.dart';

class DrawerButtonFuntion {
  static void onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingPage()),
    );
  }
}
