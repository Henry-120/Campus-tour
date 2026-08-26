import 'dart:ui';

/// Relative geometry measured against each complete card image canvas.
///
/// Keeping this geometry normalized lets the interactive layers follow the
/// artwork on every screen size. The normal and completed card assets have
/// different source aspect ratios, so they deliberately use separate specs.
class SakuraCardLayout {
  const SakuraCardLayout({
    required this.aspectRatio,
    required this.contentArea,
    required this.monsterArea,
  });

  static const Rect _messageWithinContent = Rect.fromLTWH(
    0.04,
    0.00,
    0.92,
    0.34,
  );
  static const Rect _drawingWithinContent = Rect.fromLTWH(
    0.00,
    0.34,
    1.00,
    0.74,
  );

  static const SakuraCardLayout normal = SakuraCardLayout(
    aspectRatio: 1086 / 1448,
    contentArea: Rect.fromLTWH(0.205, 0.466, 0.630, 0.350),
    monsterArea: Rect.fromLTRB(0.585, 0.500, 1.000, 1.000),
  );

  static const SakuraCardLayout completed = SakuraCardLayout(
    aspectRatio: 1122 / 1402,
    contentArea: Rect.fromLTWH(0.210, 0.475, 0.625, 0.365),
    monsterArea: Rect.fromLTRB(0.585, 0.500, 1.000, 1.000),
  );

  final double aspectRatio;
  final Rect contentArea;

  /// Relative to the full card image.
  final Rect monsterArea;

  Rect contentRectFor(Size cardSize) {
    return Rect.fromLTWH(
      contentArea.left * cardSize.width,
      contentArea.top * cardSize.height,
      contentArea.width * cardSize.width,
      contentArea.height * cardSize.height,
    );
  }

  Rect messageRectFor(Size cardSize) => _rectWithin(
    outer: contentRectFor(cardSize),
    normalized: _messageWithinContent,
  );

  Rect drawingRectFor(Size cardSize) => _rectWithin(
    outer: contentRectFor(cardSize),
    normalized: _drawingWithinContent,
  );

  Rect monsterRectFor(Size cardSize) {
    return Rect.fromLTWH(
      monsterArea.left * cardSize.width,
      monsterArea.top * cardSize.height,
      monsterArea.width * cardSize.width,
      monsterArea.height * cardSize.height,
    );
  }

  Rect _rectWithin({required Rect outer, required Rect normalized}) {
    return Rect.fromLTWH(
      outer.left + normalized.left * outer.width,
      outer.top + normalized.top * outer.height,
      normalized.width * outer.width,
      normalized.height * outer.height,
    );
  }
}
