import 'package:campus_tour/styles/level_style.dart';
import 'package:campus_tour/widgets/game/catching_pages/discovered_item.dart';
import 'package:flutter/material.dart';

class PlotLevel {
  static const String traceType = "trace";
  static const String battleType = "battle";
  static const Duration titleFadeDuration = Duration(seconds: 1);
  static const Duration descriptionFadeDuration = Duration(seconds: 1);
  static const Duration pressBlinkDuration = Duration(milliseconds: 1200);
  static const Duration sequenceDelay = Duration(milliseconds: 250);
  static const Duration dialogueSwitchDuration = Duration(milliseconds: 260);
  static const Duration spriteSwitchDuration = Duration(milliseconds: 360);
  final String type; // "trace" or "battle"
  final bool isPassed;
  final String title;
  final String description;
  final PlotSceneCharacter leftCharacter;
  final PlotSceneCharacter rightCharacter;
  final List<PlotDialogueStep> dialogueSteps;
  // [L-01]
  final DiscoveredItem? discoveredItem;
  static const String traceImageUrl = "assets/images/elf_trail.png";
  static const String battleImageUrl = "assets/images/elf_battle.png";
  static const String magicStoneSpritePath = "assets/images/magicStone.PNG";
  static const String squirrelSpritePath = "assets/images/squirrel_front.png";
  static const String magicCircleSpritePath = "assets/images/icon_remove_bg.png";
  static const String defaultLeftSpritePath =
      "assets/images/squirrel_front.png";
  static const String defaultRightSpritePath =
      "assets/images/fairy_img/qmark.png";
  static const String traceTitle = "你找到了一塊魔法石";
  static const String traceDescription = "找到對應的法陣，將魔法石放上去吧！";
  static const String battleTitle = "你召喚了精靈";
  static const String battleDescription = "但它好像很有攻擊性的看著你......";
  static const String press = "點擊任意位置繼續";
  static const String pressBattle = "點擊任意位置開始戰鬥";
  static const String passLevel = "跳過>>";

  static String backgroundImageForType(String type) {
    return type == battleType ? battleImageUrl : traceImageUrl;
  }

  // [L-02]
  PlotLevel({
    required this.type,
    required this.isPassed,
    required this.title,
    required this.description,
    this.leftCharacter = const PlotSceneCharacter(
      spritePath: defaultLeftSpritePath,
    ),
    this.rightCharacter = const PlotSceneCharacter(
      spritePath: defaultRightSpritePath,
    ),
    List<PlotDialogueStep>? dialogueSteps,
    this.discoveredItem,
  }) : dialogueSteps = dialogueSteps == null || dialogueSteps.isEmpty
           ? [
               PlotDialogueStep(
                 speakerSlot: PlotSpeakerSlot.left,
                 speakerName: "玩家",
                 text: title,
               ),
               PlotDialogueStep(
                 speakerSlot: PlotSpeakerSlot.right,
                 speakerName: "夥伴",
                 text: description,
               ),
             ]
           : dialogueSteps;
}

enum PlotSpeakerSlot { left, right, center, narrator }

class PlotSceneCharacter {
  final String spritePath;

  const PlotSceneCharacter({required this.spritePath});
}

class PlotDialogueStep {
  final PlotSpeakerSlot speakerSlot;
  final String speakerName;
  final String text;
  final String? centerSpritePath;
  final bool showLeftSprite;
  final bool showRightSprite;

  const PlotDialogueStep({
    required this.speakerSlot,
    required this.speakerName,
    required this.text,
    this.centerSpritePath,
    this.showLeftSprite = true,
    this.showRightSprite = true,
  });

  bool get showsCenterSprite {
    return centerSpritePath != null && centerSpritePath!.trim().isNotEmpty;
  }
}

class PlotLevelPageStyle {
  static const Color overlayColor = Color(0x66000000);
  static const Color fallbackBackgroundColor = Color(0xFF20252C);
  static const EdgeInsets skipPadding = EdgeInsets.only(top: 8, right: 12);
  static const EdgeInsets dialoguePadding = EdgeInsets.fromLTRB(20, 12, 20, 22);
  static const EdgeInsets dialogueContentPadding = EdgeInsets.fromLTRB(
    20,
    18,
    20,
    16,
  );
  static const double dialogueMaxWidth = 720;
  static const double dialogueMinHeight = 150;
  static const double speakerNameBottomSpacing = 8;
  static const double descriptionTopSpacing = 18;
  static const double sideSpriteWidthFactor = 0.42;
  static const double centerSpriteWidthFactor = 0.46;
  static const double sideSpriteHeightFactor = 0.72;
  static const double centerSpriteHeightFactor = 0.76;
  static const EdgeInsets spriteBottomPadding = EdgeInsets.only(bottom: 128);
  static const double inactiveSpriteOpacity = 0.48;
  static const double activeSpriteOpacity = 1;

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

  static BoxDecoration get dialogueBoxDecoration => BoxDecoration(
    color: Colors.black.withValues(alpha: 0.68),
    border: Border.all(color: Colors.white.withValues(alpha: 0.78), width: 1.4),
    borderRadius: const BorderRadius.all(Radius.circular(18)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x99000000),
        blurRadius: 22,
        offset: Offset(0, 10),
      ),
    ],
  );

  static TextStyle get skipTextStyle => LevelStyle.plotSkipTextStyle;

  static TextStyle get titleStyle => LevelStyle.plotTitleStyle;

  static TextStyle get descriptionStyle => LevelStyle.plotDescriptionStyle;

  static TextStyle get pressTextStyle => LevelStyle.plotPressTextStyle;

  static TextStyle get speakerNameStyle => LevelStyle.plotTitleStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
}
