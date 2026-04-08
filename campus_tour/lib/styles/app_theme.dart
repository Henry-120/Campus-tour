import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 💡 暖色系的核心配色
  static const Color primaryColor = Color(0xFFF28482);    // 溫暖珊瑚粉
  static const Color secondaryColor = Color(0xFFF6BD60);  // 暖金色
  static const Color accentColor = Color(0xFFF7EDE2);     // 杏仁色
  static const Color textColor = Color(0xFF5D4037);       // 暖深啡色 (取代深灰色)
  static const Color linkColor = Color(0xFF8D6E63);       // 淺啡色

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
        color: primaryColor.withValues(alpha: 0.4),
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

  static const TextStyle linkTextStyle = TextStyle(
    color: linkColor,
    fontSize: 16,
    decoration: TextDecoration.underline,
    decorationColor: linkColor,
  );
}