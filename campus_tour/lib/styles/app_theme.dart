import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get themeData {
    final baseTheme = ThemeData();
    return baseTheme.copyWith(
      textTheme: GoogleFonts.zenMaruGothicTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.zenMaruGothicTextTheme(
        baseTheme.primaryTextTheme,
      ),
    );
  }

  // 💡 依照「註冊背景圖」風格調整的核心配色
  static const Color primaryColor = Color(0xFFD99A84); // 溫暖的黏土紅/棕
  static const Color secondaryColor = Color(0xFFF4C8B8); // 淺肉粉色
  static const Color accentColor = Color(0xFFFFEDE2); // 杏仁白/羊皮紙色
  static const Color textColor = Color(0xFF5D4037); // 暖深啡色
  static const Color linkColor = Color(0xFF8D6E63); // 淺啡色
  static const Color cardColor = Color(0xFFFFFBF7); // 紙張米白色
  static const Color errorColor = Color(0xFFE57373);
  static const Color gameTextColor = Color(0xFF3A2318);
  static const Color loginPanelColor = Color(0xFF3B1E12);
  static const Color loginPanelBorderColor = Color(0xFF1F100A);
  static const Color loginGlowColor = Color(0xFFB9F451);
  static const Color loginIconColor = Color(0xFFEEDCC8);
  static const Color gameTitleFillColor = Color(0xFFFFD36A);
  static const Color gameTitleStrokeColor = Color(0xFF6B3515);
  static const Color gameTitleShadowColor = Color(0xFF9A4F1D);
  static const Color gameButtonStrokeColor = Color(0xFF1D2A2F);
  static const Color arMenuTextColor = Color(0xFFFFE0B2);
  static const Color whiteTextColor = Colors.white;
  static const Color overlayBackgroundColor = Colors.black;
  static const Color arSelectedTileColor = Colors.white;
  static const Color arUnselectedTileColor = Colors.black38;
  static const Color cameraButtonIconColor = Colors.grey;
  static const Color transparentColor = Colors.transparent;
  static const Color mapOverlayBackgroundColor = Colors.black;
  static const Color mapOverlayBorderColor = Colors.white24;
  static const Color mapOverlayPrimaryTextColor = Colors.white;
  static const Color mapOverlaySecondaryTextColor = Colors.white70;
  static const Color mapOverlayCheckColor = Colors.black;
  static const Color mapLandmarkDotColor = Colors.amberAccent;
  static const Color mapLandmarkDotBorderColor = Colors.black;
  static const Color mapLandmarkTextShadowColor = Colors.black;

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
      color: const Color(
        0x1A8D5A4A,
      ).withValues(alpha: 0.1), // 參考 LevelStyle.shadowColor
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

  static TextStyle cardTitleStyle = titleStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 0,
  );

  static TextStyle pageIndicatorStyle = titleStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    letterSpacing: 0,
  );

  static TextStyle detailTitleStyle = titleStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 0,
  );

  static TextStyle detailBodyStyle = titleStyle.copyWith(
    fontSize: 16,
    height: 1.6,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static TextStyle buttonTextStyle = titleStyle.copyWith(
    fontSize: 22,
    color: whiteTextColor,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static TextStyle hudNameStyle = titleStyle.copyWith(
    fontSize: 30,
    color: textColor,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static TextStyle linkTextStyle = titleStyle.copyWith(
    color: linkColor,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
    letterSpacing: 0,
  );

  static TextStyle gameTitleFillStyle(double scale) => titleStyle.copyWith(
    fontSize: 52 * scale,
    fontWeight: FontWeight.w900,
    color: gameTitleFillColor,
    letterSpacing: 0,
    shadows: [
      Shadow(
        offset: Offset(0, 3 * scale),
        blurRadius: 2 * scale,
        color: gameTitleShadowColor,
      ),
    ],
  );

  static TextStyle gameTitleStrokeStyle(double scale) =>
      gameTitleFillStyle(scale).copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * scale
          ..color = gameTitleStrokeColor,
        color: null,
        shadows: const [],
      );

  static TextStyle loginLabelStyle(double scale) => titleStyle.copyWith(
    fontSize: 21 * scale,
    fontWeight: FontWeight.w900,
    color: whiteTextColor,
    letterSpacing: 0,
    shadows: [
      Shadow(
        offset: Offset(2 * scale, 2 * scale),
        blurRadius: 1 * scale,
        color: Colors.black.withValues(alpha: 0.75),
      ),
    ],
  );

  static TextStyle gameLinkStyle(double fontSize, Color color) =>
      titleStyle.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
        shadows: [
          Shadow(
            offset: Offset(fontSize * 0.11, fontSize * 0.11),
            blurRadius: fontSize * 0.055,
            color: Colors.black.withValues(alpha: 0.75),
          ),
        ],
      );

  static TextStyle loginInputStyle(double fontSize) => titleStyle.copyWith(
    color: whiteTextColor,
    fontWeight: FontWeight.bold,
    fontSize: fontSize,
    height: 1.15,
    letterSpacing: 0,
  );

  static TextStyle loginHintStyle(double fontSize) => titleStyle.copyWith(
    color: whiteTextColor.withValues(alpha: 0.45),
    fontWeight: FontWeight.bold,
    fontSize: fontSize,
    height: 1.15,
    letterSpacing: 0,
  );

  static TextStyle zeroErrorStyle = titleStyle.copyWith(
    height: 0,
    fontSize: 0,
    letterSpacing: 0,
  );

  static TextStyle gameButtonTextStyle(double fontSize) => titleStyle.copyWith(
    fontSize: fontSize,
    fontWeight: FontWeight.w900,
    color: whiteTextColor,
    letterSpacing: 0,
  );

  static TextStyle gameButtonStrokeStyle(double fontSize, double scale) =>
      gameButtonTextStyle(fontSize).copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * scale
          ..color = gameButtonStrokeColor,
        color: null,
      );

  static TextStyle gameTextStyle(
    double fontSize, {
    Color color = gameTextColor,
  }) => titleStyle.copyWith(
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.8,
  );

  static TextStyle overlayTextStyle(double fontSize) => titleStyle.copyWith(
    color: whiteTextColor,
    fontWeight: FontWeight.bold,
    fontSize: fontSize,
    letterSpacing: 0,
    shadows: const [Shadow(color: Colors.black, blurRadius: 10)],
  );

  static TextStyle emptyStateStyle(double fontSize) => titleStyle.copyWith(
    color: whiteTextColor,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  // 輸入框樣式 - 已修改為手繪感底部線條樣式
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: titleStyle.copyWith(
        color: textColor,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
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
