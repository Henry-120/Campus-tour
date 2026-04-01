import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 💡 少女風的核心配色
  static const Color primaryColor = Color(0xFFFF8C94);    // 嫩粉色
  static const Color secondaryColor = Color(0xFFA8E6CF);  // 嫩綠色
  static const Color accentColor = Color(0xFFFFD3B6);     // 奶油色
  static const Color textColor = Color(0xFF5D5D5D);       // 深灰色 (取代純黑)
  static const Color linkColor = Color(0xFF9B9B9B);       // 中灰色

  // 間距
  static const double horizontalPadding = 40.0;
  static const double elementSpacing = 20.0;
  static const double sectionSpacing = 60.0;

  // 文字樣式
  static TextStyle titleStyle = GoogleFonts.itim(
    fontSize: 48,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color:accentColor.withValues(alpha: 0.3),
        offset: Offset(3, 3),
        blurRadius: 6,
      ),
    ],
  );
  static TextStyle buttonTextStyle = GoogleFonts.itim(
    fontSize: 26,
    color: primaryColor,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  // static const TextStyle buttonTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  static const TextStyle linkTextStyle = TextStyle(
    color: linkColor,
    fontSize: 16,
    decoration: TextDecoration.underline,
    decorationColor: linkColor,
  );
}