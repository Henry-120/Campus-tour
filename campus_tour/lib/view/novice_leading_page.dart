import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/controllers/key_of_novice_teaching.dart';
import 'package:campus_tour/styles/app_theme.dart';

class NoviceLeadingPage {
  static const String mainCharacterDescription = "這是遊戲的主角，代表你在校園中的位置。";
  static const String avatarDescription = "點擊查看你的個人資訊。";

  void showStep1(BuildContext context) {
    List<TargetFocus> targets;
    late TutorialCoachMark tutorial;
    // 定義教學內容
    targets = [
      TargetFocus(
        identify: "mainCharacter",
        keyTarget: KeyOfNoviceTeaching.mainCharacter,
        contents: [
          //第一教學
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Text(
                NoviceLeadingPage.mainCharacterDescription,
                style: AppTheme.detailBodyStyle,
              ),
            ),
          ),
        ],
      ),
      // 第二教學
      TargetFocus(
        identify: "avatar",
        keyTarget: KeyOfNoviceTeaching.avatar,
        enableOverlayTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Text(
                NoviceLeadingPage.avatarDescription,
                style: AppTheme.detailBodyStyle,
              ),
            ),
          ),
        ],
      ),
    ];
    tutorial = TutorialCoachMark(
      targets: targets,
      onClickTarget: (target) {
        // 只有當使用者點擊的是「avatar」時，才標記進度
        if (target.identify == "avatar") {
          NoviceManager.currentStep = 1; // 標記：第一頁的跨頁任務已發送
          tutorial.finish(); // 關閉教學層，讓底層按鈕帶你起飛
        }
      },
      onFinish: () {
        // 如果使用者點完第一個任務就直接按系統返回鍵或其他方式關閉
        // 這裡可以做保險處理
      },
    )..show(context: context);
  }

  void checkAndShow(BuildContext context) {
    // 只有在「教學進行中」且「剛完成第一步」時才觸發
    if (NoviceManager.isTutorialActive && NoviceManager.currentStep == 1) {
      // 延遲一點點，確保頁面轉場動畫（Slide/Fade）完成，GlobalKey 座標才準
      Future.delayed(const Duration(milliseconds: 600), () {
        showStep2(context);
      });
    }
  }

  void showStep2(BuildContext context) {}
}

class NoviceManager {
  // 記錄教學進度：0=還沒開始, 1=第一頁完成, 2=第二頁完成
  static int currentStep = 0;

  // 標記是否正在教學模式中
  static bool isTutorialActive = false;

  static void reset() {
    currentStep = 0;
    isTutorialActive = false;
  }
}
