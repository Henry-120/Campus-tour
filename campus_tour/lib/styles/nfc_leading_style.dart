import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class NfcLeadingStyle {
  //color
  static const Color buttonBgColor1 = Color.fromARGB(255, 124, 0, 196);
  static Color get buttonBgColor2 => Color(0xFF5D5D5D);
  static const Color buttonFgColor = Colors.white;
  //icon
  static Icon get nfcIcon => Icon(Icons.nfc);
  //
  //對應的String
  static String get primaryButtonString => 'styles.nfc.leading.style.s001'.tr;
  static String get nfcIngString => 'styles.nfc.leading.style.s002'.tr;
  //button style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonBgColor1,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    textStyle: AppTheme.titleStyle.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
    ),
  );

  static ButtonStyle nfcIngStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonBgColor2,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    textStyle: AppTheme.titleStyle.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
    ),
  );
  //Text style
  static TextStyle primaryButtonText = AppTheme.buttonTextStyle;

  static TextStyle missionStyle = AppTheme.titleStyle.copyWith(
    fontSize: 50,
    letterSpacing: 0,
  );
}
