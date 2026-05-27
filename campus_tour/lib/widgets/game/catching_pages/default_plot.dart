import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';

class DefaultPlot {
  static const List<PlotDialogueStep> magicStonePlotDialogueSteps = [
    PlotDialogueStep(
      speakerSlot: PlotSpeakerSlot.right,
      speakerName: "我",
      text: "這是什麼？",
    ),
    PlotDialogueStep(
      speakerSlot: PlotSpeakerSlot.left,
      speakerName: "神秘石頭",
      text: "（散發獨特的氣息）",
    ),
  ];

  static List<PlotDialogueStep> battlePlotDialogueSteps({
    required String fairyName,
    required String fairyImagePath,
  }) {
    return [
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: "我",
        text: "(放上魔法石)",
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.left,
        speakerName: "魔法陣",
        text: "精靈召喚！",
      ),
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: fairyName,
        text: "（怒）",
        centerSpritePath: fairyImagePath,
      ),
    ];
  }
}
