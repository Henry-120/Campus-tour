import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';

class SettingPageStyles {
  // Breakpoints & constraints
  static const double maxContentWidth = 720;
  static const double statePanelMaxWidth = 420;
  static const double heroCompactBreakpoint = 520;
  static const double settingCardCompactBreakpoint = 500;
  static const BoxConstraints pageContentConstraints = BoxConstraints(
    maxWidth: maxContentWidth,
  );
  static const BoxConstraints statePanelConstraints = BoxConstraints(
    maxWidth: statePanelMaxWidth,
  );

  // Shape & motion
  static const double sectionSpacing = 24;
  static const double panelRadius = 28;
  static const double pillRadius = 999;
  static const double cardSpacing = gapXl;
  static const double heroIconSize = 76;
  static const double settingIconSize = 54;
  static const Duration animationDuration = Duration(milliseconds: 220);

  // Sizing
  static const double heroIconGlyphSize = 36;
  static const double settingIconGlyphSize = 28;
  static const double stateIconGlyphSize = 34;
  static const double badgeIconSize = 16;
  static const double sliderTrackHeight = 6;

  // Spacing scale
  static const double gap2xs = 6;
  static const double gapXs = 8;
  static const double gapSm = 10;
  static const double gapMd = 14;
  static const double gapLg = 16;
  static const double gapXl = 18;
  static const double gap2xl = 20;

  // Insets
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(20, 12, 20, 24);
  static const EdgeInsets heroPadding = EdgeInsets.all(
    AppTheme.cardPadding * 1.25,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(
    AppTheme.cardPadding * 1.25,
  );
  static const EdgeInsets toggleShellPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );
  static const EdgeInsets statusChipPadding = EdgeInsets.symmetric(
    horizontal: gapMd,
    vertical: gapXs,
  );
  static const EdgeInsets infoBadgePadding = EdgeInsets.symmetric(
    horizontal: gapMd,
    vertical: gapSm,
  );

  // Colors
  static const Color loadingIndicatorColor = AppTheme.primaryColor;
  static const Color surfaceIconColor = Colors.white;
  static const Color mutedIconColor = AppTheme.linkColor;
  static const Color switchActiveThumbColor = AppTheme.cardColor;
  static const Color switchActiveTrackColor = Color.fromARGB(
    255,
    104,
    164,
    255,
  );
  static const Color switchInactiveThumbColor = mutedIconColor;
  static const Color switchInactiveTrackColor = AppTheme.primaryColor;

  // Border radius
  static const BorderRadius panelBorderRadius = BorderRadius.all(
    Radius.circular(panelRadius),
  );
  static const BorderRadius navigationButtonBorderRadius = BorderRadius.all(
    Radius.circular(18),
  );
  static const BorderRadius heroIconBorderRadius = BorderRadius.all(
    Radius.circular(24),
  );
  static const BorderRadius settingIconBorderRadius = BorderRadius.all(
    Radius.circular(18),
  );
  static const BorderRadius toggleShellBorderRadius = BorderRadius.all(
    Radius.circular(22),
  );

  // Decorations
  static const BoxDecoration pageBackgroundDecoration = BoxDecoration(
    gradient: AppTheme.warmGradient,
  );

  static BoxDecoration get navigationButtonDecoration => BoxDecoration(
    color: AppTheme.cardColor.withValues(alpha: 0.82),
    borderRadius: navigationButtonBorderRadius,
    border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.9)),
    boxShadow: AppTheme.softShadow,
  );

  static BoxDecoration get heroCardDecoration => BoxDecoration(
    color: AppTheme.cardColor.withValues(alpha: 0.76),
    borderRadius: panelBorderRadius,
    border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.95)),
    boxShadow: AppTheme.softShadow,
  );

  static BoxDecoration get settingCardDecoration => BoxDecoration(
    color: AppTheme.cardColor.withValues(alpha: 0.9),
    borderRadius: panelBorderRadius,
    border: Border.all(
      color: AppTheme.secondaryColor.withValues(alpha: 0.24),
      width: 1.2,
    ),
    boxShadow: AppTheme.softShadow,
  );

  static BoxDecoration get heroIconDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
    ),
    borderRadius: heroIconBorderRadius,
    boxShadow: [
      BoxShadow(
        color: AppTheme.primaryColor.withValues(alpha: 0.22),
        blurRadius: 22,
        offset: const Offset(0, 12),
      ),
    ],
  );

  static BoxDecoration get settingIconDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
    ),
    borderRadius: settingIconBorderRadius,
  );

  static BoxDecoration infoBadgeDecoration({required bool highlighted}) =>
      BoxDecoration(
        color: (highlighted ? AppTheme.secondaryColor : AppTheme.accentColor)
            .withValues(alpha: highlighted ? 0.2 : 0.78),
        borderRadius: BorderRadius.circular(pillRadius),
        border: Border.all(
          color: (highlighted ? AppTheme.secondaryColor : AppTheme.primaryColor)
              .withValues(alpha: 0.34),
        ),
      );

  static BoxDecoration toggleShellDecoration(bool enabled) => BoxDecoration(
    color: (enabled ? AppTheme.accentColor : AppTheme.cardColor).withValues(
      alpha: enabled ? 0.88 : 0.72,
    ),
    borderRadius: toggleShellBorderRadius,
    border: Border.all(
      color: (enabled ? AppTheme.primaryColor : AppTheme.linkColor).withValues(
        alpha: 0.24,
      ),
      width: 1.2,
    ),
  );

  // Typography
  static TextStyle get pageTitleStyle =>
      AppTheme.titleStyle.copyWith(fontSize: 34, color: AppTheme.primaryColor);

  static TextStyle get pageSubtitleStyle => AppTheme.detailBodyStyle.copyWith(
    fontSize: 14,
    height: 1.5,
    color: AppTheme.textColor.withValues(alpha: 0.75),
  );

  static TextStyle get heroTitleStyle =>
      AppTheme.hudNameStyle.copyWith(fontSize: 24, color: AppTheme.textColor);

  static TextStyle get cardTitleStyle =>
      AppTheme.cardTitleStyle.copyWith(fontSize: 20, color: AppTheme.textColor);

  static TextStyle get bodyTextStyle => AppTheme.detailBodyStyle.copyWith(
    fontSize: 14,
    height: 1.55,
    color: AppTheme.textColor.withValues(alpha: 0.76),
  );

  static TextStyle get badgeTextStyle => AppTheme.cardTitleStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppTheme.textColor,
  );

  static TextStyle statusChipStyle(bool enabled) =>
      AppTheme.cardTitleStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: enabled ? AppTheme.textColor : AppTheme.linkColor,
      );

  static TextStyle toggleTitleStyle(bool enabled) =>
      AppTheme.cardTitleStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: enabled ? AppTheme.textColor : AppTheme.linkColor,
      );

  static TextStyle get scaleHintStyle => AppTheme.cardTitleStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppTheme.textColor.withValues(alpha: 0.62),
  );

  // Controls
  static SliderThemeData sliderTheme(BuildContext context) {
    return Theme.of(context).sliderTheme.copyWith(
      trackHeight: sliderTrackHeight,
      activeTrackColor: AppTheme.primaryColor,
      inactiveTrackColor: AppTheme.accentColor,
      thumbColor: AppTheme.secondaryColor,
      overlayColor: AppTheme.secondaryColor.withValues(alpha: 0.16),
      activeTickMarkColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      inactiveTickMarkColor: Colors.transparent,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      valueIndicatorColor: AppTheme.primaryColor,
      valueIndicatorTextStyle: AppTheme.buttonTextStyle.copyWith(
        fontSize: 14,
        letterSpacing: 0,
      ),
    );
  }
}
