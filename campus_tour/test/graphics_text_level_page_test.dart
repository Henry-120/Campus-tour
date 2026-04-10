import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_tour/controllers/NFC_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_tour/styles/level_style.dart';

// Deferred imports: delay loading the page/level libraries until after we've
// configured HTTP overrides so google_fonts network requests (for fonts)
// can be intercepted in tests.
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level_page.dart' deferred as page_lib;
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart' deferred as level_lib;

void main() {
  testWidgets('GraphicsTextLevelPage golden test', (WidgetTester tester) async {
    // Fix the test window size so the golden is deterministic.
    const testSize = Size(1080, 1920);
    final binding = tester.binding;
    binding.window.physicalSizeTestValue = testSize;
    binding.window.devicePixelRatioTestValue = 1.0;

  // Prevent google_fonts from trying to fetch fonts over the network during tests.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Load a local font and register it under the family name 'Itim'
  // so that google_fonts will find a local font instead of trying to
  // fetch from the network. We use the bundled CupertinoIcons font as a
  // harmless stand-in.
  final fontData = await rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf');
  final fontLoader = FontLoader('Itim')..addFont(Future.value(fontData));
  await fontLoader.load();

  // Prevent google_fonts from fetching at runtime since we've registered
  // a local 'Itim' font.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Override LevelStyle text styles to avoid GoogleFonts where possible.
  LevelStyle.titleStyle = const TextStyle(fontSize: 30, fontWeight: FontWeight.w700);
  LevelStyle.hintStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
  LevelStyle.descriptionStyle = const TextStyle(fontSize: 25, fontWeight: FontWeight.w400);
  LevelStyle.placeholderStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.w400);

  // Now load the deferred libraries (this triggers LevelStyle/google_fonts
  // code inside the page library). Because we registered a local 'Itim'
  // font and disabled runtime fetching, font-loading inside google_fonts
  // should succeed synchronously.
  await level_lib.loadLibrary();
  await page_lib.loadLibrary();

  // Arrange: create a GraphicsTextLevel with obvious test data
    final level = level_lib.GraphicsTextLevel(
      firstTracePhoto: 'assets/images/nonexistent_test_image.png',
      descriptionText: '這是一段用於測試的說明文字，應該會顯示在畫面上。',
      nfcId: 'TEST_NFC_ID',
    );

    // nextFunction is required; provide a noop that accepts NfcScanResult
    void onNext(NfcScanResult result) {}

    // Act: pump the page inside a MaterialApp with deterministic theme
    await tester.pumpWidget(
      MaterialApp(
        home: page_lib.GraphicsTextLevelPage(level: level, nextFunction: onNext),
        theme: ThemeData.light(),
      ),
    );

    // Wait for images/fallback to settle
    await tester.pumpAndSettle();

    // Assert: take a golden snapshot. The golden file will be created/updated
    // when running tests with `--update-goldens`.
    await expectLater(
      find.byType(page_lib.GraphicsTextLevelPage),
      matchesGoldenFile('goldens/graphics_text_level_page.png'),
    );

    // Clean up the test window override
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();

    // Nothing to restore for HttpOverrides in this flow.
  });
}

