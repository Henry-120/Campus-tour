class CryptographyLevel {
  CryptographyLevel({
    required this.questionSet,
    required this.choiceSet,
    required this.answerSet,
  });

  final List<String> questionSet;
  final List<List<String>> choiceSet;
  final List<String> answerSet;

  static const String introduction = "請根據介紹牌選出正確的選項";
  static const String battleTitle = "密碼鎖破解";
  static const String battleSubtitle = "每答對一題就能解開一位數密碼，答錯會扣除自己的血量";
  static const String enemyHpLabel = "精靈血量";
  static const String playerHpLabel = "你的血量";
  static const String lockLabel = "密碼鎖";
  static const String questionLabel = "目前題目";
  static const String correctMessage = "答對了，對其造成1點傷害";
  static const String wrongMessage = "答錯了，自己受到 1 點傷害";
  static const String finishMessage = "精靈被成功擊倒";
  static const String loseMessage = "血量歸零，挑戰失敗";
  static const String nextQuestionButton = "下一題";
  static const String finishButton = "完成戰鬥";
  static const String retryHint = "請重新觀察題目後再作答";
  static const int playerMaxHp = 3;
  static const int playerDamageOnWrong = 1;
  static const int enemyDamageOnCorrect = 1;
  static const Duration feedbackDuration = Duration(milliseconds: 900);
}
