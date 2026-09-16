import 'package:get/get.dart';

class CryptographyLevel {
  CryptographyLevel({
    required this.questionSet,
    required this.choiceSet,
    required this.answerSet,
  });

  final List<String> questionSet;
  final List<List<String>> choiceSet;
  final List<String> answerSet;

  static String get introduction =>
      'widgets.game.catching.pages.cryptography.level.s001'.tr;
  static String get battleTitle =>
      'widgets.game.catching.pages.cryptography.level.s002'.tr;
  static String get battleSubtitle =>
      'widgets.game.catching.pages.cryptography.level.s003'.tr;
  static String get enemyHpLabel =>
      'widgets.game.catching.pages.cryptography.level.s004'.tr;
  static String get playerHpLabel =>
      'widgets.game.catching.pages.cryptography.level.s005'.tr;
  static String get lockLabel =>
      'widgets.game.catching.pages.cryptography.level.s006'.tr;
  static String get questionLabel =>
      'widgets.game.catching.pages.cryptography.level.s007'.tr;
  static String get correctMessage =>
      'widgets.game.catching.pages.cryptography.level.s008'.tr;
  static String get wrongMessage =>
      'widgets.game.catching.pages.cryptography.level.s009'.tr;
  static String get finishMessage =>
      'widgets.game.catching.pages.cryptography.level.s010'.tr;
  static String get loseMessage =>
      'widgets.game.catching.pages.cryptography.level.s011'.tr;
  static String get nextQuestionButton =>
      'widgets.game.catching.pages.cryptography.level.s012'.tr;
  static String get finishButton =>
      'widgets.game.catching.pages.cryptography.level.s013'.tr;
  static String get retryHint =>
      'widgets.game.catching.pages.cryptography.level.s014'.tr;
  static const int playerMaxHp = 2;
  static const int playerDamageOnWrong = 1;
  static const int enemyDamageOnCorrect = 1;
  static Duration get feedbackDuration => Duration(milliseconds: 900);
}
