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

  static const double battleCardRadius = 30;
  static const double optionRadius = 20;
  static const double hpBarHeight = 14;
  static const double monsterImageSize = 128;
  static const double choiceSpacing = 12;
  static const double battleSectionSpacing = 18;

  static BattleLevelTheme battleThemeForType(String type) {
    switch (type.trim()) {
      case '火':
        return const BattleLevelTheme(
          topColor: Color(0xFFFFF0E5),
          bottomColor: Color(0xFFFFC7A1),
          primary: Color(0xFFF06B3F),
          secondary: Color(0xFFFF9E57),
          accent: Color(0xFFFFE2C6),
          panel: Color(0xFFFFFBF5),
          text: Color(0xFF6A2C17),
          hpFill: Color(0xFFE44F31),
          lockFill: Color(0xFFF0883E),
          glow: Color(0x33F06B3F),
        );
      case '水':
        return const BattleLevelTheme(
          topColor: Color(0xFFEAF7FF),
          bottomColor: Color(0xFFBFE2FF),
          primary: Color(0xFF3B82C9),
          secondary: Color(0xFF67B7F7),
          accent: Color(0xFFDDF2FF),
          panel: Color(0xFFF7FCFF),
          text: Color(0xFF18496D),
          hpFill: Color(0xFF2A78C0),
          lockFill: Color(0xFF58AEE8),
          glow: Color(0x3348A4E0),
        );
      case '電':
        return const BattleLevelTheme(
          topColor: Color(0xFFFFF8D9),
          bottomColor: Color(0xFFFFE788),
          primary: Color(0xFFE0A600),
          secondary: Color(0xFFFFCF33),
          accent: Color(0xFFFFF2B5),
          panel: Color(0xFFFFFDF3),
          text: Color(0xFF6E5500),
          hpFill: Color(0xFFE3B100),
          lockFill: Color(0xFFF6C938),
          glow: Color(0x33FFD54F),
        );
      default:
        return const BattleLevelTheme(
          topColor: Color(0xFFF7F0FF),
          bottomColor: Color(0xFFE3D5FF),
          primary: Color(0xFF7C63D7),
          secondary: Color(0xFFA28AF2),
          accent: Color(0xFFEDE6FF),
          panel: Color(0xFFFCFAFF),
          text: Color(0xFF43327B),
          hpFill: Color(0xFF7C63D7),
          lockFill: Color(0xFF9C86EE),
          glow: Color(0x337C63D7),
        );
    }
  }

  static BoxDecoration battlePageDecoration(BattleLevelTheme theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [theme.topColor, theme.bottomColor],
      ),
    );
  }

  static BoxDecoration battleShellDecoration(BattleLevelTheme theme) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.78),
      borderRadius: const BorderRadius.all(Radius.circular(battleCardRadius)),
      border: Border.all(
        color: theme.primary.withValues(alpha: 0.24),
        width: 1.4,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.glow,
          blurRadius: 30,
          offset: const Offset(0, 18),
        ),
      ],
    );
  }

  static BoxDecoration monsterPanelDecoration(BattleLevelTheme theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [theme.primary, theme.secondary],
      ),
      borderRadius: const BorderRadius.all(Radius.circular(26)),
      boxShadow: [
        BoxShadow(
          color: theme.glow,
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  static BoxDecoration infoCardDecoration(BattleLevelTheme theme) {
    return BoxDecoration(
      color: theme.panel,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      border: Border.all(color: theme.primary.withValues(alpha: 0.16)),
    );
  }

  static BoxDecoration questionCardDecoration(BattleLevelTheme theme) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.88),
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      border: Border.all(
        color: theme.secondary.withValues(alpha: 0.35),
        width: 1.2,
      ),
    );
  }

  static BoxDecoration lockCellDecoration(
    BattleLevelTheme theme, {
    required bool unlocked,
  }) {
    return BoxDecoration(
      color: unlocked ? theme.lockFill : theme.panel,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      border: Border.all(
        color: unlocked ? theme.primary : theme.primary.withValues(alpha: 0.2),
        width: 1.4,
      ),
      boxShadow: unlocked
          ? [
              BoxShadow(
                color: theme.glow,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration hpTrackDecoration(BattleLevelTheme theme) {
    return BoxDecoration(
      color: theme.accent,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
    );
  }

  static BoxDecoration hpFillDecoration(BattleLevelTheme theme) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [theme.primary, theme.hpFill]),
      borderRadius: const BorderRadius.all(Radius.circular(999)),
    );
  }

  static ButtonStyle answerButtonStyle(
    BattleLevelTheme theme, {
    required bool isSelected,
    required bool isCorrect,
    required bool isWrong,
  }) {
    Color background = Colors.white.withValues(alpha: 0.92);
    Color border = theme.primary.withValues(alpha: 0.16);
    Color foreground = theme.text;

    if (isCorrect) {
      background = const Color(0xFFE2F7E7);
      border = const Color(0xFF31A45B);
      foreground = const Color(0xFF1C6B39);
    } else if (isWrong) {
      background = const Color(0xFFFFE7E2);
      border = const Color(0xFFD85A48);
      foreground = const Color(0xFF8B2E24);
    } else if (isSelected) {
      background = theme.accent;
      border = theme.primary;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(optionRadius)),
        side: BorderSide(color: border, width: 1.4),
      ),
      textStyle: GoogleFonts.itim(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: foreground,
      ),
    );
  }

  static TextStyle battleTitleStyle(BattleLevelTheme theme) => GoogleFonts.itim(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: theme.text,
    letterSpacing: 0.8,
  );

  static TextStyle battleHintStyle(BattleLevelTheme theme) => GoogleFonts.itim(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: theme.text.withValues(alpha: 0.78),
    letterSpacing: 0.4,
  );

  static TextStyle battleNameStyle(BattleLevelTheme theme) => GoogleFonts.itim(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle battleTypeStyle(BattleLevelTheme theme) => GoogleFonts.itim(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white.withValues(alpha: 0.92),
    letterSpacing: 0.8,
  );

  static TextStyle sectionLabelStyle(BattleLevelTheme theme) =>
      GoogleFonts.itim(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: theme.text.withValues(alpha: 0.76),
      );

  static TextStyle questionStyle(BattleLevelTheme theme) => GoogleFonts.itim(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: theme.text,
    height: 1.45,
  );

  static TextStyle lockDigitStyle(
    BattleLevelTheme theme, {
    required bool unlocked,
  }) => GoogleFonts.itim(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: unlocked ? Colors.white : theme.primary.withValues(alpha: 0.34),
  );

  static TextStyle hpLabelStyle(BattleLevelTheme theme) => GoogleFonts.itim(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: theme.text,
  );

  static TextStyle hpValueStyle(BattleLevelTheme theme) => GoogleFonts.itim(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: theme.text,
  );

  static TextStyle feedbackStyle(
    BattleLevelTheme theme, {
    required bool success,
  }) => GoogleFonts.itim(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: success ? const Color(0xFF1E7A43) : const Color(0xFFA2382E),
  );

  static BoxDecoration monsterImageFrame(BattleLevelTheme theme) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
    );
  }
}

class BattleLevelTheme {
  const BattleLevelTheme({
    required this.topColor,
    required this.bottomColor,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.panel,
    required this.text,
    required this.hpFill,
    required this.lockFill,
    required this.glow,
  });

  final Color topColor;
  final Color bottomColor;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color panel;
  final Color text;
  final Color hpFill;
  final Color lockFill;
  final Color glow;
}
