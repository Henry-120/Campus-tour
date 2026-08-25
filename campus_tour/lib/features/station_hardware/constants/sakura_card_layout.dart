import 'dart:ui';

/// Relative geometry measured against each complete card image canvas.
///
/// Keeping this geometry normalized lets the interactive layers follow the
/// artwork on every screen size. The normal and completed card assets have
/// different source aspect ratios, so they deliberately use separate specs.
class SakuraCardLayout {
  const SakuraCardLayout({
    required this.aspectRatio,
    required this.writingArea,
    required this.monsterArea,
  });

  static const SakuraCardLayout normal = SakuraCardLayout(
    aspectRatio: 1086 / 1448,
    writingArea: Rect.fromLTWH(0.205, 0.466, 0.630, 0.350),
    monsterArea: Rect.fromLTWH(0.585, 0.500, 0.390, 0.440),
  );

  static const SakuraCardLayout completed = SakuraCardLayout(
    aspectRatio: 1122 / 1402,
    writingArea: Rect.fromLTWH(0.210, 0.475, 0.625, 0.365),
    monsterArea: Rect.fromLTWH(0.585, 0.500, 0.390, 0.440),
  );

  final double aspectRatio;
  final Rect writingArea;

  /// Relative to the full card image.
  final Rect monsterArea;

  Rect writingRectFor(Size cardSize) {
    return Rect.fromLTWH(
      writingArea.left * cardSize.width,
      writingArea.top * cardSize.height,
      writingArea.width * cardSize.width,
      writingArea.height * cardSize.height,
    );
  }

  Rect monsterRectFor(Size cardSize) {
    return Rect.fromLTWH(
      monsterArea.left * cardSize.width,
      monsterArea.top * cardSize.height,
      monsterArea.width * cardSize.width,
      monsterArea.height * cardSize.height,
    );
  }
}
