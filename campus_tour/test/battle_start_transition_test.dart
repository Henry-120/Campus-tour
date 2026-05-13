import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/level_style.dart';
import 'package:campus_tour/widgets/game/catching_pages/battle_start_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const monsterImage = 'assets/images/elf_battle.png';
  const playerImage = 'assets/images/squirrel_walking_front.png';

  Widget buildHarness({
    String monsterImagePath = monsterImage,
    String monsterType = '火',
    String playerImagePath = playerImage,
    VoidCallback? onClosed,
    VoidCallback? onFinished,
    VoidCallback? onBackgroundPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: onBackgroundPressed,
                child: const Text('background action'),
              ),
            ),
            BattleStartTransition(
              monsterImagePath: monsterImagePath,
              monsterType: monsterType,
              playerImagePath: playerImagePath,
              onClosed: onClosed ?? () {},
              onFinished: onFinished ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  List<Offset> panelOffsets(WidgetTester tester) {
    return tester
        .widgetList<Transform>(find.byType(Transform))
        .map((widget) => widget.transform.getTranslation())
        .map((translation) => Offset(translation.x, translation.y))
        .where((offset) => offset.dx.abs() > 1 || offset.dy.abs() > 1)
        .toList();
  }

  List<List<Color>> panelGradientColors(WidgetTester tester) {
    return tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((widget) => widget.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.gradient)
        .whereType<LinearGradient>()
        .map((gradient) => gradient.colors)
        .toList();
  }

  bool hasGradient(List<List<Color>> gradients, Color first, Color second) {
    return gradients.any(
      (colors) =>
          colors.length == 2 && colors[0] == first && colors[1] == second,
    );
  }

  testWidgets('runs close, hold, and open callbacks on the documented timing', (
    tester,
  ) async {
    var closedCount = 0;
    var finishedCount = 0;

    await tester.pumpWidget(
      buildHarness(
        onClosed: () => closedCount++,
        onFinished: () => finishedCount++,
      ),
    );
    await tester.pump();

    expect(closedCount, 0);
    expect(finishedCount, 0);

    await tester.pump(const Duration(milliseconds: 619));
    expect(closedCount, 0);
    expect(finishedCount, 0);

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    expect(closedCount, 1);
    expect(finishedCount, 0);

    await tester.pump(const Duration(milliseconds: 199));
    expect(finishedCount, 0);

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 619));
    expect(finishedCount, 0);

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    expect(closedCount, 1);
    expect(finishedCount, 1);

    await tester.pump(const Duration(seconds: 1));
    expect(closedCount, 1);
    expect(finishedCount, 1);
  });

  testWidgets(
    'disposing during the closing animation cancels later callbacks',
    (tester) async {
      var closedCount = 0;
      var finishedCount = 0;

      await tester.pumpWidget(
        buildHarness(
          onClosed: () => closedCount++,
          onFinished: () => finishedCount++,
        ),
      );
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));

      expect(closedCount, 0);
      expect(finishedCount, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disposing during the opening animation skips onFinished', (
    tester,
  ) async {
    var closedCount = 0;
    var finishedCount = 0;

    await tester.pumpWidget(
      buildHarness(
        onClosed: () => closedCount++,
        onFinished: () => finishedCount++,
      ),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 820));
    expect(closedCount, 1);

    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));

    expect(closedCount, 1);
    expect(finishedCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('absorbs taps while the overlay is present', (tester) async {
    var backgroundTapCount = 0;

    await tester.pumpWidget(
      buildHarness(onBackgroundPressed: () => backgroundTapCount++),
    );

    await tester.tap(find.text('background action'), warnIfMissed: false);
    await tester.pump();

    expect(backgroundTapCount, 0);
  });

  testWidgets('slides panels from outside the screen and returns outside', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildHarness());
    await tester.pump();

    final initialOffsets = panelOffsets(tester);
    expect(initialOffsets, hasLength(2));
    expect(initialOffsets.any((offset) => offset.dx < -300), isTrue);
    expect(initialOffsets.any((offset) => offset.dx > 300), isTrue);

    await tester.pump(const Duration(milliseconds: 621));
    await tester.pump();
    expect(panelOffsets(tester), isEmpty);

    await tester.pump(const Duration(milliseconds: 202));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 621));
    await tester.pump();
    final finalOffsets = panelOffsets(tester);
    expect(finalOffsets, hasLength(2));
    expect(finalOffsets.any((offset) => offset.dx < -300), isTrue);
    expect(finalOffsets.any((offset) => offset.dx > 300), isTrue);
  });

  testWidgets(
    'uses monster type colors for the top panel and app colors below',
    (tester) async {
      await tester.pumpWidget(buildHarness(monsterType: '水'));

      final waterTheme = LevelStyle.battleThemeForType('水');
      final waterGradients = panelGradientColors(tester);
      expect(
        hasGradient(waterGradients, waterTheme.primary, waterTheme.secondary),
        isTrue,
      );
      expect(
        hasGradient(
          waterGradients,
          AppTheme.accentColor,
          AppTheme.primaryColor,
        ),
        isTrue,
      );

      await tester.pumpWidget(buildHarness(monsterType: '未知'));
      await tester.pump();

      final defaultTheme = LevelStyle.battleThemeForType('未知');
      expect(
        hasGradient(
          panelGradientColors(tester),
          defaultTheme.primary,
          defaultTheme.secondary,
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'trims empty image paths and shows fallback icons without arrows',
    (tester) async {
      await tester.pumpWidget(
        buildHarness(monsterImagePath: ' \n ', playerImagePath: '  '),
      );

      expect(find.byIcon(Icons.auto_awesome), findsWidgets);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_right), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_left), findsNothing);
    },
  );
}
