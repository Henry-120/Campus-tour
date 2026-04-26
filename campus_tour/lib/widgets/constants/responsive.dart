import 'package:flutter/material.dart';

class Responsive {
  // 你的目前基準裝置：width 411.42857142857144, height 914.2857142857143
  static const double designWidth = 411.42857142857144;
  static const double designHeight = 914.2857142857143;

  static double scaleWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width / designWidth;
  }

  static double scaleHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height / designHeight;
  }

  /// 使用寬高較小的縮放比例，避免短螢幕或窄螢幕爆版。
  /// clamp 可以避免小手機太小、平板太大。
  static double scale(BuildContext context) {
    final sw = scaleWidth(context);
    final sh = scaleHeight(context);
    final value = sw < sh ? sw : sh;
    return value.clamp(0.82, 1.12).toDouble();
  }

  static double w(BuildContext context, double value) {
    return value * scaleWidth(context);
  }

  static double h(BuildContext context, double value) {
    return value * scaleHeight(context);
  }

  static double s(BuildContext context, double value) {
    return value * scale(context);
  }
}
