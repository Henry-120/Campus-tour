import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';

class NoviceLeadingStyle {
  static const Color backgroundColor = Color(0xFF17120F);
  static const Color imageOverlayTopColor = Color(0x33000000);
  static const Color imageOverlayBottomColor = Color(0x99000000);
  static const Color textPanelColor = Color(0xB3000000);
  static const Color plotBackgroundTopColor = Color(0xFF2B2520);
  static const Color plotBackgroundBottomColor = Color(0xFF0F0C0A);
  static const Color finishBackgroundTopColor = Color(0xFFFFF4EC);
  static const Color finishBackgroundBottomColor = Color(0xFFFFD8C8);

  static const Duration pageTurnDuration = Duration(milliseconds: 420);
  static const Curve pageTurnCurve = Curves.easeOutCubic;

  static const EdgeInsets safeAreaPadding = EdgeInsets.fromLTRB(20, 12, 20, 24);
  static const EdgeInsets textPanelMargin = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 92,
  );
  static const EdgeInsets textPanelPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 14,
  );
  static const EdgeInsets navigationPadding = EdgeInsets.fromLTRB(
    18,
    0,
    18,
    22,
  );
  static const EdgeInsets skipPadding = EdgeInsets.only(top: 8, right: 10);
  static const EdgeInsets finishButtonPadding = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 14,
  );

  static BorderRadius textPanelRadius = BorderRadius.circular(8);
  static BorderRadius finishButtonRadius = BorderRadius.circular(8);

  static const LinearGradient imageShadeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [imageOverlayTopColor, Colors.transparent, imageOverlayBottomColor],
    stops: [0, 0.46, 1],
  );

  static const LinearGradient plotGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [plotBackgroundTopColor, plotBackgroundBottomColor],
  );

  static const LinearGradient finishGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [finishBackgroundTopColor, finishBackgroundBottomColor],
  );

  static TextStyle get instructionTextStyle =>
      AppTheme.buttonTextStyle.copyWith(
        fontSize: 22,
        height: 1.45,
        letterSpacing: 0,
        color: Colors.white,
        shadows: const [
          Shadow(color: Color(0xCC000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      );

  static TextStyle get actionTextStyle => AppTheme.buttonTextStyle.copyWith(
    fontSize: 18,
    letterSpacing: 0,
    color: Colors.white,
    shadows: const [
      Shadow(color: Color(0xCC000000), blurRadius: 6, offset: Offset(0, 1)),
    ],
  );

  static TextStyle get disabledActionTextStyle =>
      actionTextStyle.copyWith(color: const Color(0x80FFFFFF));

  static TextStyle get plotTextStyle => AppTheme.titleStyle.copyWith(
    fontSize: 30,
    height: 1.45,
    letterSpacing: 0,
    color: Colors.white,
    shadows: const [
      Shadow(color: Color(0xCC000000), blurRadius: 10, offset: Offset(0, 2)),
    ],
  );

  static TextStyle get finishTextStyle => AppTheme.titleStyle.copyWith(
    fontSize: 30,
    height: 1.35,
    letterSpacing: 0,
    color: AppTheme.textColor,
  );

  static TextStyle get finishButtonTextStyle => AppTheme.buttonTextStyle
      .copyWith(fontSize: 20, letterSpacing: 0, color: Colors.white);

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    overlayColor: Colors.white.withValues(alpha: 0.12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );

  static ButtonStyle get finishButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: finishButtonPadding,
    shape: RoundedRectangleBorder(borderRadius: finishButtonRadius),
    textStyle: finishButtonTextStyle,
  );
}
