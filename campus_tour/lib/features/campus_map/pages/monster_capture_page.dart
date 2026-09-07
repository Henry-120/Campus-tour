import 'package:campus_tour/local_information/local_setting.dart';
import 'package:campus_tour/models/architecture_model.dart';
import 'package:campus_tour/models/monster_model.dart';
import 'package:campus_tour/models/qa_model.dart';
import 'package:campus_tour/utils/monster_image_path.dart';
import 'package:campus_tour/view/full_mission_page.dart';
import 'package:campus_tour/widgets/encyclopedia/all_the_monster/monster_graphics.dart';
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/default_plot.dart';
import 'package:campus_tour/widgets/game/catching_pages/discovered_item.dart';
import 'package:campus_tour/widgets/game/catching_pages/full_mission.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_plot.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_trace_plot.dart';
import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';
import 'package:flutter/material.dart';

class MonsterCapturePage extends StatelessWidget {
  MonsterCapturePage({
    super.key,
    required this.monster,
    required this.qa,
    required this.architectureType,
    this.onMissionFinished,
    this.onMissionFailed,
  }) : monsterModelCry = MonsterModelCry(
         name: monster.name,
         type: monster.canonicalType,
         imageUrl: MonsterImagePath.staticImage(monster.imageURL),
       ),
       tracePlotMission = PlotLevel(
         type: PlotLevel.traceType,
         isPassed: LocalSettingService.autoSkipStory.isEnabled,
         title: PlotLevel.traceTitle,
         description: PlotLevel.traceDescription,
         dialogueSteps: MonsterTracePlot.steps(monsterId: monster.id),
         leftCharacter: const PlotSceneCharacter(spritePath: ''),
         rightCharacter: PlotSceneCharacter(
           spritePath: PlotLevel.squirrelSpritePath,
         ),
       ),
       mission1 = GraphicsTextLevel(
         firstTracePhoto: MonsterGraphics.graphics[monster.id] ?? '',
         storyReviewSteps:
             MonsterTracePlot.steps(monsterId: monster.id) ?? const [],
         discoveredItem: DiscoveredItem.strategyBook,
         nfcId: monster.nfcAns ?? '',
       ),
       battlePlotMission = PlotLevel(
         type: PlotLevel.battleType,
         isPassed: LocalSettingService.autoSkipStory.isEnabled,
         title: PlotLevel.battleTitle,
         description: PlotLevel.battleDescription,
         // 優先使用專屬台詞，若未設定則 fallback 到通用版。
         dialogueSteps:
             MonsterPlot.battleSteps(
               monsterId: monster.id,
               fairyImagePath: MonsterImagePath.staticImage(monster.imageURL),
             ) ??
             DefaultPlot.battlePlotDialogueSteps(
               fairyName: monster.name,
               fairyImagePath: MonsterImagePath.staticImage(monster.imageURL),
             ),
         leftCharacter: PlotSceneCharacter(
           spritePath: PlotLevel.magicCircleSpritePath,
         ),
         rightCharacter: PlotSceneCharacter(
           spritePath: PlotLevel.squirrelSpritePath,
         ),
       ),
       mission2 = CryptographyLevel(
         questionSet: [qa.question],
         choiceSet: [qa.options],
         answerSet: [qa.answer],
       );

  final MonsterModel monster;
  final QAModel qa;
  final String architectureType;
  final Future<void> Function()? onMissionFinished;
  final VoidCallback? onMissionFailed;
  final MonsterModelCry monsterModelCry;
  final PlotLevel tracePlotMission;
  final GraphicsTextLevel mission1;
  final PlotLevel battlePlotMission;
  final CryptographyLevel mission2;

  List<FullMission> get missions {
    return switch (architectureType) {
      ArchitectureModel.departmentBuilding => systemManagementMissions,
      ArchitectureModel.installationArt => installationArtMissions,
      ArchitectureModel.scenicSpot => scenicSpotMissions,
      _ => installationArtMissions,
    };
  }

  List<FullMission> get systemManagementMissions => [
    FullMission(levelType: 'plotLevel', plotLevel: battlePlotMission),
    FullMission(levelType: 'cryptographyLevel', cryptographyLevel: mission2),
  ];

  List<FullMission> get installationArtMissions => [
    FullMission(levelType: 'plotLevel', plotLevel: tracePlotMission),
    if (monster.nfcAns != null)
      FullMission(levelType: 'graphicsTextLevel', graphicsTextLevel: mission1),
    FullMission(levelType: 'plotLevel', plotLevel: battlePlotMission),
    FullMission(levelType: 'cryptographyLevel', cryptographyLevel: mission2),
  ];

  List<FullMission> get scenicSpotMissions => [
    FullMission(levelType: 'plotLevel', plotLevel: battlePlotMission),
    FullMission(levelType: 'cryptographyLevel', cryptographyLevel: mission2),
  ];

  @override
  Widget build(BuildContext context) {
    return FullMissionPage(
      missions: missions,
      monsterModelCry: monsterModelCry,
      onMissionFinished: onMissionFinished,
      onMissionFailed: onMissionFailed,
    );
  }
}
