import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Abc for class
// a_b_c for var
// aBc for funtion

class DrawerStyles {
  //左拉選單的樣式設定
  // color
  static const Color drawerBgTopColor = Color(0xFF14213D);
  static const Color drawerBgMiddleColor = Color(0xFF1F7A8C);
  static const Color drawerBgBottomColor = Color(0xFFF6F1D1);
  static const Color drawerPanelBorderColor = Color(0x33FFFFFF);
  static const Color drawerTextColor = Colors.white;
  static const Color drawerSubtitleColor = Color(0xD9FFFFFF);
  static const Color logoutBgColor = Color(0xFFE85D75);
  static const Color logoutFontColor = Colors.white;
  static const Color sbuttonFontColor = Colors.white;
  static const Color sbuttonSideColor = Color(0x33FFFFFF);
  static const Color sbuttonBgColor = Color(0x1AFFFFFF);

  //animate time
  static const int drawerAnimTime = 450;

  //對齊格式
  static const drawerMainAlignment = MainAxisAlignment.center;
  static const drawerCrossAlignment = CrossAxisAlignment.stretch;

  //side width
  static const double sbuttonSideWidth = 0;

  //size
  static const Size drawerButtonMinSize = Size(0, drawerButtonHeight);
  static const Size drawerButtonMaxSize = Size(
    double.infinity,
    drawerButtonHeight,
  );
  static const EdgeInsets drawerPadding = EdgeInsets.fromLTRB(22, 18, 22, 22);
  static const EdgeInsets drawerHeaderPadding = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 10,
  );
  static const EdgeInsets drawerButtonPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 3,
  );
  static const EdgeInsets drawerLogoutPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 14,
  );
  static const double drawerButtonRadius = 16;
  static const double drawerButtonHeight = 54;
  static const double drawerButtonWidth = 232;
  static const double drawerAvatarSize = 58;
  static const double drawerDividerHeight = 28;

  static const BoxDecoration drawerBackgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [drawerBgTopColor, drawerBgMiddleColor, drawerBgBottomColor],
      stops: [0, 0.56, 1],
    ),
  );

  static const BoxDecoration drawerGlowDecoration = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(-0.85, -0.75),
      radius: 1.05,
      colors: [Color(0x40FFFFFF), Color(0x00FFFFFF)],
    ),
  );

  static const BoxDecoration avatarDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFD166), Color(0xFFEF476F)],
    ),
    boxShadow: [
      BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8)),
    ],
  );

  //button style
  static ButtonStyle drawer_button_style = OutlinedButton.styleFrom(
    foregroundColor: sbuttonFontColor,
    backgroundColor: sbuttonBgColor,
    side: const BorderSide(color: sbuttonSideColor, width: sbuttonSideWidth),
    minimumSize: drawerButtonMinSize,
    maximumSize: drawerButtonMaxSize,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(drawerButtonRadius),
    ),
    padding: drawerButtonPadding,
  );

  static ButtonStyle logoutButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: logoutFontColor,
    backgroundColor: logoutBgColor,
    elevation: 0,
    minimumSize: drawerButtonMinSize,
    maximumSize: drawerButtonMaxSize,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(drawerButtonRadius),
    ),
    padding: drawerButtonPadding,
  );

  //Text Style
  static final TextStyle second_button_text = GoogleFonts.zcoolQingKeHuangYou(
    fontSize: 22,
    color: drawerTextColor,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  static final TextStyle userNameText = GoogleFonts.zcoolQingKeHuangYou(
    fontSize: 24,
    color: drawerTextColor,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  static final TextStyle userSubtitleText = GoogleFonts.zcoolQingKeHuangYou(
    fontSize: 15,
    color: drawerSubtitleColor,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static final TextStyle logoutButtonText = GoogleFonts.zcoolQingKeHuangYou(
    fontSize: 22,
    color: logoutFontColor,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );
}
