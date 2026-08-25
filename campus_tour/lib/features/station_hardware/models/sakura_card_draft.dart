import 'dart:ui';

import 'package:flutter/foundation.dart';

@immutable
class SakuraStroke {
  SakuraStroke(Iterable<Offset> points)
    : points = List<Offset>.unmodifiable(points);

  /// Points normalized to the handwriting area's 0.0–1.0 coordinate space.
  final List<Offset> points;
}
