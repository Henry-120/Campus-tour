import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 顏色
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.grey;
  static const Color linkColor = Colors.black54;

  // 間距
  static const double horizontalPadding = 40.0;
  static const double elementSpacing = 20.0;
  static const double sectionSpacing = 60.0;

  // 文字樣式
  static TextStyle titleStyle = GoogleFonts.zcoolQingKeHuangYou(
    fontSize: 48,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    shadows: [
      const Shadow(
        color: Colors.black26,
        offset: Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );
  static TextStyle buttonTextStyle = GoogleFonts.zcoolQingKeHuangYou(
    fontSize: 26,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2, // 稍微拉開字距，更有質感
  );
  static TextStyle buttonTextStyle2 = GoogleFonts.zcoolQingKeHuangYou(
    fontSize: 26,
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2, // 稍微拉開字距，更有質感
  );
  // static const TextStyle buttonTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  static const TextStyle linkTextStyle = TextStyle(
    color: linkColor,
    fontSize: 16,
    decoration: TextDecoration.underline,
  );
}