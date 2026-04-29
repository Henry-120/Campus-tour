import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/widgets/buttons/nfc_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NfcLeadingStyle {
  //color
  static const Color buttonBgColor1 = AppTheme.secondaryColor;
  static const Color buttonBgColor2 = Color(0xFF5D5D5D);
  static const Color buttonFgColor = Colors.white;
  //icon
  static const Icon nfc_icon = Icon(Icons.nfc);
  //
  //對應的String
  static const primaryButtonString = "開始NFC掃描";
  static const NfcIngString = "掃描中";
  //button style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonBgColor1,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  static ButtonStyle NfcIngStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonBgColor2,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );
  //Text style
  static TextStyle primaryButtonText = AppTheme.buttonTextStyle;

  static TextStyle mission_style = TextStyle(fontSize: 50);
}
