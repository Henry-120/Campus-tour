import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 💡 暖色系的核心配色
  static const Color primaryColor = Color(0xFFF28482);    // 溫暖珊瑚粉
  static const Color secondaryColor = Color(0xFFF6BD60);  // 暖金色
  static const Color accentColor = Color(0xFFF7EDE2);     // 杏仁色
  static const Color textColor = Color(0xFF5D4037);       // 暖深啡色
  static const Color linkColor = Color(0xFF8D6E63);       // 淺啡色
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE57373);

  // 漸層背景
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7EDE2), Color(0xFFF5CAC3)],
  );

  // 間距
  static const double horizontalPadding = 40.0;
  static const double elementSpacing = 20.0;
  static const double sectionSpacing = 60.0;
  static const double cardPadding = 16.0;

  // 陰影
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  // 文字樣式
  static TextStyle titleStyle = GoogleFonts.itim(
    fontSize: 48,
    color: primaryColor,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: primaryColor.withOpacity(0.2),
        offset: const Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );

  static TextStyle cardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle pageIndicatorStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static TextStyle detailTitleStyle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle detailBodyStyle = const TextStyle(
    fontSize: 16,
    height: 1.6,
    color: Colors.black87,
  );

  static TextStyle buttonTextStyle = GoogleFonts.itim(
    fontSize: 22,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static TextStyle hudNameStyle = GoogleFonts.itim(
    fontSize: 30,
    color: textColor,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // static const TextStyle buttonTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  static const TextStyle linkTextStyle = TextStyle(
    color: linkColor,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );

  // 輸入框樣式
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
