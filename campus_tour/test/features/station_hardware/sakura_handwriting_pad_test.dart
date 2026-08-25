import 'package:campus_tour/features/station_hardware/view_models/sakura_card_draft_view_model.dart';
import 'package:campus_tour/features/station_hardware/widgets/sakura_handwriting_pad.dart';
import 'package:campus_tour/l10n/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('prompts follow drawing undo and redo state', (tester) async {
    final draft = SakuraCardDraftViewModel();
    var isDrawingInteractionActive = false;
    addTearDown(draft.dispose);
    addTearDown(Get.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh'),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: SakuraHandwritingCard(
                draft: draft,
                isCollectionComplete: false,
                isLocked: false,
                onSelectMonster: () {},
                onDrawingInteractionChanged: (isActive) {
                  isDrawingInteractionActive = isActive;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_promptOpacity(tester), 1);

    final surface = find.byKey(const ValueKey('sakura-handwriting-surface'));
    final rect = tester.getRect(surface);
    final monsterRect = tester.getRect(
      find.byKey(const ValueKey('sakura-monster-selection-target')),
    );
    final cardRect = tester.getRect(
      find.byKey(const ValueKey('sakura-card-canvas')),
    );
    expect(monsterRect.right, greaterThan(rect.right));
    expect(monsterRect.bottom, greaterThan(rect.bottom));
    expect(monsterRect.right, closeTo(cardRect.right, 0.01));
    expect(monsterRect.bottom, closeTo(cardRect.bottom, 0.01));
    expect(
      find.byKey(const ValueKey('sakura-empty-monster-frame')),
      findsOneWidget,
    );

    final gesture = await tester.startGesture(
      rect.topLeft + Offset(rect.width * 0.16, rect.height * 0.30),
    );
    await tester.pump();
    expect(isDrawingInteractionActive, isTrue);
    await gesture.moveBy(Offset(rect.width * 0.24, rect.height * 0.18));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(isDrawingInteractionActive, isFalse);

    expect(draft.strokes, isNotEmpty);
    expect(_promptOpacity(tester), 0);

    await tester.tap(find.byTooltip('復原上一筆'));
    await tester.pumpAndSettle();
    expect(draft.strokes, isEmpty);
    expect(_promptOpacity(tester), 1);

    await tester.tap(find.byTooltip('重做下一筆'));
    await tester.pumpAndSettle();
    expect(draft.strokes, isNotEmpty);
    expect(_promptOpacity(tester), 0);
  });
}

double _promptOpacity(WidgetTester tester) {
  final widget = tester.widget<AnimatedOpacity>(
    find.byKey(const ValueKey('sakura-writing-prompts')),
  );
  return widget.opacity;
}
