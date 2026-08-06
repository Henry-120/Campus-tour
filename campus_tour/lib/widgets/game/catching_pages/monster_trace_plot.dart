import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';
import 'package:get/get.dart';

/// NFC 精靈的專屬蹤跡劇情。
///
/// 共用的開場與結尾由 [steps] 統一建立；需要撰寫劇情時，只要修改
/// [_introductions] 中對應 monster.id 的文字即可。
class MonsterTracePlot {
  MonsterTracePlot._();

  /// 回傳指定精靈的蹤跡劇情。
  ///
  /// 尚未設定專屬介紹文的精靈會回傳 null，方便呼叫端決定 fallback。
  static List<PlotDialogueStep>? steps({required String monsterId}) {
    final introductionKey = _introductionKeys[monsterId];
    if (introductionKey == null) return null;

    return [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: 'widgets.game.catching.pages.monster.trace.plot.s001'.tr,
        text: 'widgets.game.catching.pages.monster.trace.plot.s002'.tr,
      ),
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.narrator,
        speakerName: '',
        text: 'widgets.game.catching.pages.monster.trace.plot.s003'.tr,
      ),
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.narrator,
        speakerName: '',
        text: introductionKey.tr,
      ),
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: 'widgets.game.catching.pages.monster.trace.plot.s001'.tr,
        text: 'widgets.game.catching.pages.monster.trace.plot.s004'.tr,
      ),
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.narrator,
        speakerName: '',
        text: 'widgets.game.catching.pages.monster.trace.plot.s005'.tr,
      ),
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.narrator,
        speakerName: '',
        text: 'widgets.game.catching.pages.monster.trace.plot.s006'.tr,
      ),
    ];
  }

  // ── 每隻 NFC 精靈的專屬介紹文 ─────────────────────────────────────────
  // 每隻精靈使用獨立翻譯鍵，之後可直接在 app_translations.dart 修改。
  static const Map<String, String> _introductionKeys = {
    // 大象五形
    'm4': 'widgets.game.catching.pages.monster.trace.plot.s007',

    // 太極銅雕
    'm5': 'widgets.game.catching.pages.monster.trace.plot.s008',

    // DNA
    'm15': 'widgets.game.catching.pages.monster.trace.plot.s009',

    // 90 度的翅膀
    'm16': 'widgets.game.catching.pages.monster.trace.plot.s010',

    // 坐想飛雲
    'm17': 'widgets.game.catching.pages.monster.trace.plot.s011',

    // 聽松風
    'm18': 'widgets.game.catching.pages.monster.trace.plot.s012',

    // 問號
    'm19': 'widgets.game.catching.pages.monster.trace.plot.s013',

    // 雲
    'm20': 'widgets.game.catching.pages.monster.trace.plot.s014',

    // 90 度 II
    'm21': 'widgets.game.catching.pages.monster.trace.plot.s015',
  };
}
