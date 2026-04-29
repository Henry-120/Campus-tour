import 'package:flutter/material.dart';

class PlotLevel {
  static const String traceType = "trace";
  static const String battleType = "battle";
  static const Duration titleFadeDuration = Duration(seconds: 1);
  static const Duration descriptionFadeDuration = Duration(seconds: 1);
  static const Duration pressBlinkDuration = Duration(milliseconds: 1200);
  static const Duration sequenceDelay = Duration(milliseconds: 250);
  final String type; // "trace" or "battle"
  final bool isPassed;
  final String title;
  final String description;
  static const String traceImageUrl = "assets/images/elf_trail.png";
  static const String battleImageUrl = "assets/images/elf_battle.png";
  static const String traceTitle = "這裡好像有精靈的蹤跡";
  static const String traceDescription = "開啟你的探測器，掃描並追蹤它。";
  static const String battleTitle = "你找到了精靈";
  static const String battleDescription = "但它好像很有攻擊性的看著你......";
  static const String press = "點擊任意位置繼續";
  static const String pressBattle = "點擊任意位置開始戰鬥";
  static const String passLevel = "跳過>>";

  static String backgroundImageForType(String type) {
    return type == battleType ? battleImageUrl : traceImageUrl;
  }

  PlotLevel({
    required this.type,
    required this.isPassed,
    required this.title,
    required this.description,
  });
}

class PlotLevelPageStyle {
  static const Color overlayColor = Color(0x66000000);
  static const Color fallbackBackgroundColor = Color(0xFF20252C);
  static const EdgeInsets skipPadding = EdgeInsets.only(top: 8, right: 12);
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 28);
  static const EdgeInsets pressPadding = EdgeInsets.only(
    left: 24,
    right: 24,
    bottom: 64,
  );
  static const double descriptionTopSpacing = 18;

  static final ButtonStyle skipButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    backgroundColor: Colors.transparent,
    overlayColor: Colors.transparent,
    shadowColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
  );

  static const TextStyle skipTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    shadows: [
      Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    height: 1.25,
    shadows: [
      Shadow(color: Color(0xB3000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  static const TextStyle descriptionStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.55,
    shadows: [
      Shadow(color: Color(0xB3000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  static const TextStyle pressTextStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    shadows: [
      Shadow(color: Color(0xB3000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}
