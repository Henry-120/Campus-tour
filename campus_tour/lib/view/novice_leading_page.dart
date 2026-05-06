import 'dart:async';
import 'dart:math' as math;

import 'package:campus_tour/controllers/key_of_novice_teaching.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/view/full_mission_page.dart';
import 'package:campus_tour/view/game_main_page.dart';
import 'package:campus_tour/widgets/constants/asset_paths.dart';
import 'package:campus_tour/widgets/game/catching_pages/full_mission.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';
import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class NoviceLeadingPage {
  static const String mainCharacterDescription = "這是遊戲的主角，代表你在校園中的位置。";
  static const String avatarDescription = "點擊查看你的個人資訊。";
  static const String avatarSelectDescription = "選一個喜歡的頭像吧";
  static const String encyclopediaButtonDescription = "點擊圖鑑，看看你收集到的精靈吧。";
  static const String encyclopediaCardDescription = "你收集到的精靈都會出現在這裡";
  static const String encyclopediaTextDescription = "這裡可以查看關於這隻精靈的細節喔";
  static const String tutorialFinishedDescription = "教學到此結束，還有更多好玩與實用的功能等著你探索";

  static bool _isShowingCoachMark = false;
  static bool _isStartingMission = false;

  void showStep1(BuildContext context) {
    NoviceManager.start();
    _isShowingCoachMark = true;

    late TutorialCoachMark tutorial;
    tutorial = _buildTutorial(
      targets: [
        _targetByKey(
          identify: "mainCharacter",
          key: KeyOfNoviceTeaching.mainCharacter,
          description: mainCharacterDescription,
          align: ContentAlign.bottom,
        ),
        _targetByKey(
          identify: "avatar",
          key: KeyOfNoviceTeaching.avatar,
          description: avatarDescription,
          align: ContentAlign.bottom,
        ),
      ],
      onClickTarget: (target) {
        if (target.identify == "avatar") {
          NoviceManager.currentStep = NoviceManager.waitingAvatarPage;
          tutorial.finish();
        }
      },
    )..show(context: context);
  }

  void checkAndShow(BuildContext context) {
    if (!NoviceManager.isTutorialActive || _isShowingCoachMark) return;

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!context.mounted || !NoviceManager.isTutorialActive) return;

      switch (NoviceManager.currentStep) {
        case NoviceManager.waitingAvatarPage:
          if (_areTargetsMounted([
            KeyOfNoviceTeaching.avatarImage,
            KeyOfNoviceTeaching.avatarCheak,
          ])) {
            showStep2(context);
          } else {
            NoviceManager.currentStep = NoviceManager.avatarSelected;
            checkAndShow(context);
          }
          break;
        case NoviceManager.avatarSelected:
          _showTutorialFairyAndMission(context);
          break;
        case NoviceManager.waitingEncyclopediaButton:
          if (_isTargetMounted(KeyOfNoviceTeaching.encyclopediaButton)) {
            showStep3(context);
          } else if (_isTargetMounted(KeyOfNoviceTeaching.encyclopediaCard)) {
            NoviceManager.currentStep = NoviceManager.waitingEncyclopediaCard;
            checkAndShow(context);
          }
          break;
        case NoviceManager.waitingEncyclopediaCard:
          if (_isTargetMounted(KeyOfNoviceTeaching.encyclopediaCard)) {
            showStep4(context);
          } else if (_isTargetMounted(KeyOfNoviceTeaching.encyclopediaText)) {
            NoviceManager.currentStep = NoviceManager.waitingEncyclopediaText;
            checkAndShow(context);
          }
          break;
        case NoviceManager.waitingEncyclopediaText:
          if (_isTargetMounted(KeyOfNoviceTeaching.encyclopediaText)) {
            showStep5(context);
          }
          break;
      }
    });
  }

  void showStep2(BuildContext context) {
    final position = _targetPositionFromKeys([
      KeyOfNoviceTeaching.avatarImage,
      KeyOfNoviceTeaching.avatarCheak,
    ]);

    if (position == null) {
      _retryCheck(context);
      return;
    }

    _showTutorial(
      context: context,
      targets: [
        TargetFocus(
          identify: "avatarSelection",
          targetPosition: position,
          enableTargetTab: false,
          enableOverlayTab: false,
          shape: ShapeLightFocus.RRect,
          radius: 18,
          paddingFocus: 8,
          contents: [_content(avatarSelectDescription, ContentAlign.bottom)],
        ),
      ],
    );
  }

  void showStep3(BuildContext context) {
    _showTutorial(
      context: context,
      targets: [
        _targetByKey(
          identify: "encyclopediaButton",
          key: KeyOfNoviceTeaching.encyclopediaButton,
          description: encyclopediaButtonDescription,
          align: ContentAlign.top,
          enableTargetTab: false,
        ),
      ],
    );
  }

  void showStep4(BuildContext context) {
    _showTutorial(
      context: context,
      targets: [
        _targetByKey(
          identify: "encyclopediaCard",
          key: KeyOfNoviceTeaching.encyclopediaCard,
          description: encyclopediaCardDescription,
          align: ContentAlign.bottom,
          enableTargetTab: false,
        ),
      ],
    );
  }

  void showStep5(BuildContext context) {
    _isShowingCoachMark = true;
    late TutorialCoachMark tutorial;
    tutorial = _buildTutorial(
      targets: [
        _targetByKey(
          identify: "encyclopediaText",
          key: KeyOfNoviceTeaching.encyclopediaText,
          description: encyclopediaTextDescription,
          align: ContentAlign.top,
          enableOverlayTab: true,
        ),
      ],
      onClickTarget: (target) {
        if (target.identify == "encyclopediaText") {
          NoviceManager.currentStep = NoviceManager.finished;
          tutorial.finish();
        }
      },
      onClickOverlay: (target) {
        if (target.identify == "encyclopediaText") {
          NoviceManager.currentStep = NoviceManager.finished;
          tutorial.finish();
        }
      },
      onFinish: () {
        if (NoviceManager.currentStep == NoviceManager.finished) {
          _showFinishedDialog(context);
        }
      },
    )..show(context: context);
  }

  TutorialCoachMark _buildTutorial({
    required List<TargetFocus> targets,
    void Function(TargetFocus target)? onClickTarget,
    void Function(TargetFocus target)? onClickOverlay,
    VoidCallback? onFinish,
  }) {
    return TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.78,
      textSkip: "略過",
      paddingFocus: 10,
      hideSkip: false,
      onClickTarget: onClickTarget,
      onClickOverlay: onClickOverlay,
      onFinish: () {
        _isShowingCoachMark = false;
        onFinish?.call();
      },
      onSkip: () {
        _isShowingCoachMark = false;
        NoviceManager.reset();
        return true;
      },
    );
  }

  void _showTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
  }) {
    _isShowingCoachMark = true;
    _buildTutorial(targets: targets).show(context: context);
  }

  TargetFocus _targetByKey({
    required String identify,
    required GlobalKey key,
    required String description,
    required ContentAlign align,
    bool enableTargetTab = true,
    bool enableOverlayTab = false,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      enableTargetTab: enableTargetTab,
      enableOverlayTab: enableOverlayTab,
      shape: ShapeLightFocus.RRect,
      radius: 14,
      contents: [_content(description, align)],
    );
  }

  TargetContent _content(String text, ContentAlign align) {
    return TargetContent(
      align: align,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          text,
          style: AppTheme.detailBodyStyle.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _showTutorialFairyAndMission(BuildContext context) async {
    if (_isStartingMission) return;
    _isStartingMission = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF6EF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AssetPaths.squirrel,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                "發現一隻精靈！",
                style: AppTheme.detailBodyStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("前往捕捉"),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      _isStartingMission = false;
      return;
    }

    await _openTutorialMission(context);
    _isStartingMission = false;

    if (context.mounted) {
      checkAndShow(context);
    }
  }

  Future<void> _openTutorialMission(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (missionContext) {
          return FullMissionPage(
            missions: [
              FullMission(
                levelType: "plotLevel",
                plotLevel: PlotLevel(
                  type: PlotLevel.traceType,
                  isPassed: false,
                  title: "實際抓捕會更有趣",
                  description: "真正遇見精靈時，還會有更多有趣的關卡等著你挑戰。",
                ),
              ),
            ],
            monsterModelCry: const MonsterModelCry(
              name: "教學精靈",
              type: "tutorial",
              imageUrl: AssetPaths.squirrel,
            ),
            onMissionFinished: () async {
              NoviceManager.currentStep =
                  NoviceManager.waitingEncyclopediaButton;
              if (Navigator.of(missionContext).canPop()) {
                Navigator.of(missionContext).pop();
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _showFinishedDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF6EF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Text(
            tutorialFinishedDescription,
            style: AppTheme.detailBodyStyle,
          ),
          actions: [
            TextButton(
              onPressed: () {
                NoviceManager.reset();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const GameMainPage()),
                  (route) => false,
                );
              },
              child: const Text("回到主頁"),
            ),
          ],
        );
      },
    );
  }

  void _retryCheck(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) checkAndShow(context);
    });
  }

  bool _isTargetMounted(GlobalKey key) {
    return key.currentContext != null;
  }

  bool _areTargetsMounted(List<GlobalKey> keys) {
    return keys.every(_isTargetMounted);
  }

  TargetPosition? _targetPositionFromKeys(List<GlobalKey> keys) {
    final boxes = keys
        .map((key) => key.currentContext?.findRenderObject())
        .whereType<RenderBox>()
        .where((box) => box.hasSize)
        .toList();

    if (boxes.length != keys.length) return null;

    double left = double.infinity;
    double top = double.infinity;
    double right = -double.infinity;
    double bottom = -double.infinity;

    for (final box in boxes) {
      final offset = box.localToGlobal(Offset.zero);
      left = math.min(left, offset.dx);
      top = math.min(top, offset.dy);
      right = math.max(right, offset.dx + box.size.width);
      bottom = math.max(bottom, offset.dy + box.size.height);
    }

    return TargetPosition(Size(right - left, bottom - top), Offset(left, top));
  }
}

class NoviceManager {
  static const int notStarted = 0;
  static const int waitingAvatarPage = 1;
  static const int avatarSelected = 2;
  static const int waitingEncyclopediaButton = 3;
  static const int waitingEncyclopediaCard = 4;
  static const int waitingEncyclopediaText = 5;
  static const int finished = 6;

  static int currentStep = notStarted;
  static bool isTutorialActive = false;

  static void start() {
    currentStep = notStarted;
    isTutorialActive = true;
  }

  static void reset() {
    currentStep = notStarted;
    isTutorialActive = false;
  }
}
