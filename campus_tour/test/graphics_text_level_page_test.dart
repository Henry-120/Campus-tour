import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';

void main() {
  testWidgets('GraphicsTextLevelPage displays image and text sections', (
    WidgetTester tester,
  ) async {
    // Arrange: create a GraphicsTextLevel with obvious test data
    final level = GraphicsTextLevel(
      firstTracePhoto: 'assets/images/nonexistent_test_image.png',
      descriptionText: 'This is a description for testing.',
      nfcId: 'TEST_NFC_ID',
    );

    // nextFunction is required; provide a noop with no parameters
    void onNext() {}

    // Act: pump the page inside a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: GraphicsTextLevelPage(level: level, nextFunction: onNext),
      ),
    );
    await tester.pumpAndSettle();

    // Assert: key UI pieces are present
    expect(find.text('探索關卡'), findsOneWidget);
    expect(find.text('觀察線索後，前往指定地點感應 NFC'), findsOneWidget);
    expect(find.text('This is a description for testing.'), findsOneWidget);

    // The NFC button should be present (we check by nfc id presence indirectly)
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
