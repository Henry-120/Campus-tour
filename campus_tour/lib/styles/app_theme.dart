import 'package:flutter/material.dart';

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
  static const TextStyle buttonTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  static const TextStyle linkTextStyle = TextStyle(
    color: linkColor,
    fontSize: 16,
    decoration: TextDecoration.underline,
  );
}