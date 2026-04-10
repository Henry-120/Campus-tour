import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelStyle {
  static const Color pageTopColor = Color(0xFFFFF4EC);
  static const Color pageBottomColor = Color(0xFFFFE1D6);
  static const Color frameColor = Colors.white;
  static const Color imagePlaceholderColor = Color(0xFFFFEDE2);
  static const Color textPanelColor = Color(0xFFFFFBF7);
  static const Color shadowColor = Color(0x1A8D5A4A);
  static const Color borderColor = Color(0xFFF4C8B8);
  static const Color imageIconColor = Color(0xFFD99A84);

  static const double pageHorizontalPadding = 24;
  static const double pageVerticalPadding = 20;
  static const double bodySpacing = 18;
  static const double panelSpacing = 16;
  static const double nfcButtonTopSpacing = 18;
  static const double cardRadius = 28;
  static const double innerRadius = 22;
  static const double sectionMinHeight = 220;

  static const BorderRadius mainCardRadius = BorderRadius.all(
    Radius.circular(cardRadius),
  );
  static const BorderRadius innerCardRadius = BorderRadius.all(
    Radius.circular(innerRadius),
  );

  static BoxDecoration pageDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [pageTopColor, pageBottomColor],
    ),
  );

  static List<BoxShadow> softShadow = const [
    BoxShadow(color: shadowColor, blurRadius: 24, offset: Offset(0, 12)),
  ];

  static BoxDecoration mainCardDecoration = BoxDecoration(
    color: frameColor.withValues(alpha: 0.86),
    borderRadius: mainCardRadius,
    border: Border.all(color: borderColor, width: 1.4),
    boxShadow: softShadow,
  );

  static BoxDecoration imageCardDecoration = BoxDecoration(
    color: frameColor,
    borderRadius: innerCardRadius,
    boxShadow: softShadow,
  );

  static BoxDecoration textCardDecoration = BoxDecoration(
    color: textPanelColor,
    borderRadius: innerCardRadius,
    border: Border.all(color: borderColor.withValues(alpha: 0.9), width: 1.2),
  );

  static BoxDecoration imagePlaceholderDecoration = BoxDecoration(
    color: imagePlaceholderColor,
    borderRadius: innerCardRadius,
    border: Border.all(color: borderColor.withValues(alpha: 0.75)),
  );

  static TextStyle titleStyle = GoogleFonts.itim(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppTheme.textColor,
    letterSpacing: 0.8,
  );

  static TextStyle hintStyle = GoogleFonts.itim(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppTheme.textColor.withValues(alpha: 0.72),
    letterSpacing: 0.4,
  );

  static TextStyle descriptionStyle = GoogleFonts.itim(
    fontSize: 25,
    fontWeight: FontWeight.w400,
    color: AppTheme.textColor,
    height: 1.6,
  );

  static TextStyle placeholderStyle = GoogleFonts.itim(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppTheme.textColor.withValues(alpha: 0.75),
  );
}
