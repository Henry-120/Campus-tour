import 'package:flutter/material.dart';

import 'app_theme.dart';

class MapSuggestionStyle {
  // [L-01]
  static const Color pageBackgroundColor = AppTheme.mapOverlayBackgroundColor;

  // [L-02]
  static const BoxFit mapImageFit = BoxFit.contain;

  // [L-03]
  static const double markerSize = 56;

  // [L-04]
  static const double landmarkDotSize = 10;

  // [L-05]
  static const double filterPanelInset = 12;

  // [L-06]
  static const double filterPanelWidthRatio = 1 / 3;

  // [L-07]
  static double filterPanelLength(double availableWidth) =>
      availableWidth * filterPanelWidthRatio;

  // [L-08]
  static BoxDecoration get filterPanelDecoration => BoxDecoration(
    color: AppTheme.mapOverlayBackgroundColor.withValues(alpha: 0.72),
    border: Border.all(color: AppTheme.mapOverlayBorderColor),
    borderRadius: BorderRadius.circular(8),
  );

  // [L-09]
  static const bool filterTileDense = true;

  // [L-10]
  static const ListTileControlAffinity filterTileControlAffinity =
      ListTileControlAffinity.leading;

  // [L-11]
  static const Color filterTileActiveColor =
      AppTheme.mapOverlayPrimaryTextColor;

  // [L-12]
  static const Color filterTileCheckColor = AppTheme.mapOverlayCheckColor;

  // [L-13]
  static TextStyle filterOptionTextStyle = AppTheme.buttonTextStyle;

  // [L-14]
  static const EdgeInsets loadMessagePadding = EdgeInsets.fromLTRB(
    12,
    0,
    12,
    12,
  );

  // [L-15]
  static const Alignment loadMessageAlignment = Alignment.centerLeft;

  // [L-16]
  static const TextStyle loadMessageTextStyle = TextStyle(
    color: AppTheme.mapOverlaySecondaryTextColor,
  );

  // [L-17]
  static const TextStyle locationMessageTextStyle = TextStyle(
    color: AppTheme.mapOverlayPrimaryTextColor,
  );

  // [L-18]
  static Offset landmarkLabelOffset(double dotSize) =>
      Offset(-dotSize / 2, -dotSize / 2);

  // [L-19]
  static const MainAxisSize landmarkLabelAxisSize = MainAxisSize.min;

  // [L-20]
  static const Color installationArtDotColor = Colors.blueAccent;

  // [L-23]
  static Color landmarkDotColor(String category) => category == '裝置藝術'
      ? installationArtDotColor
      : AppTheme.mapLandmarkDotColor;

  // [L-24]
  static BoxDecoration landmarkDotDecoration(String category) => BoxDecoration(
    color: landmarkDotColor(category),
    shape: BoxShape.circle,
    border: Border.all(color: AppTheme.mapLandmarkDotBorderColor, width: 1.5),
  );

  // [L-21]
  static const double landmarkLabelSpacing = 4;

  // [L-22]
  static const TextStyle landmarkNameTextStyle = TextStyle(
    color: AppTheme.mapOverlayPrimaryTextColor,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    shadows: [
      Shadow(color: AppTheme.mapLandmarkTextShadowColor, blurRadius: 4),
    ],
  );
}
