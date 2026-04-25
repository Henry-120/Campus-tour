import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 💡 依照「註冊背景圖」風格調整的核心配色
  static const Color primaryColor = Color(0xFFD99A84);    // 溫暖的黏土紅/棕，來自 LevelStyle.imageIconColor
  static const Color secondaryColor = Color(0xFFF4C8B8);  // 淺肉粉色，來自 LevelStyle.borderColor
  static const Color accentColor = Color(0xFFFFEDE2);     // 杏仁白/羊皮紙色，來自 LevelStyle.imagePlaceholderColor
  static const Color textColor = Color(0xFF5D4037);       // 暖深啡色，保持原有的穩重感
  static const Color linkColor = Color(0xFF8D6E63);       // 淺啡色
  static const Color cardColor = Color(0xFFFFFBF7);       // 紙張米白色，來自 LevelStyle.textPanelColor
  static const Color errorColor = Color(0xFFE57373);

  // 漸層背景 - 參考自 LevelStyle 的頁面背景
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF4EC), Color(0xFFFFE1D6)],
  );

  // 間距
  static const double horizontalPadding = 40.0;
  static const double elementSpacing = 20.0;
  static const double sectionSpacing = 60.0;
  static const double cardPadding = 16.0;

  // 陰影 - 使用更溫潤的咖啡色系陰影
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0x1A8D5A4A).withValues(alpha: 0.1), // 參考 LevelStyle.shadowColor
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  // 文字樣式 - 已依照圖片修改為深啡色、無陰影的手繪風格
  static TextStyle titleStyle = GoogleFonts.zenMaruGothic(
    fontSize: 40,
    color: textColor,
    fontWeight: FontWeight.w900, // 更加粗體
    letterSpacing: 2.0,
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

  static TextStyle buttonTextStyle = GoogleFonts.zenMaruGothic(
    fontSize: 22,
    color: Colors.white,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static TextStyle hudNameStyle = GoogleFonts.zenMaruGothic(
    fontSize: 30,
    color: textColor,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const TextStyle linkTextStyle = TextStyle(
    color: linkColor,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );

  // 輸入框樣式 - 已修改為手繪感底部線條樣式
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.zenMaruGothic(
        color: textColor,
        fontSize: 21,
        fontWeight: FontWeight.w700,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(icon, color: textColor, size: 40),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 50),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: textColor, width: 2.5),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: textColor, width: 4),
      ),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
    );
  }
}
