import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';

import 'package:get/get.dart';

class DefaultPlot {
  static List<PlotDialogueStep> get magicStonePlotDialogueSteps => [
    PlotDialogueStep(
      speakerSlot: PlotSpeakerSlot.right,
      speakerName: 'widgets.game.catching.pages.default.plot.s001'.tr,
      text: 'widgets.game.catching.pages.default.plot.s002'.tr,
    ),
    PlotDialogueStep(
      speakerSlot: PlotSpeakerSlot.left,
      speakerName: 'widgets.game.catching.pages.default.plot.s003'.tr,
      text: 'widgets.game.catching.pages.default.plot.s004'.tr,
    ),
  ];

  static List<PlotDialogueStep> battlePlotDialogueSteps({
    required String fairyName,
    required String fairyImagePath,
  }) {
    return [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: 'widgets.game.catching.pages.default.plot.s001'.tr,
        text: 'widgets.game.catching.pages.default.plot.s006'.tr,
      ),
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.left,
        speakerName: 'widgets.game.catching.pages.default.plot.s007'.tr,
        text: 'widgets.game.catching.pages.default.plot.s008'.tr,
      ),
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: fairyName,
        text: 'widgets.game.catching.pages.default.plot.s009'.tr,
        centerSpritePath: fairyImagePath,
      ),
    ];
  }
}
