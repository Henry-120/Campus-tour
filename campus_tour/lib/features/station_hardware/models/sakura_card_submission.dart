import 'dart:ui';

import 'package:campus_tour/features/station_hardware/models/sakura_card_draft.dart';
import 'package:flutter/foundation.dart';

/// An immutable snapshot of the handwriting that will be written to Firestore.
///
/// Stroke boundaries are retained so lifting the pointer does not accidentally
/// connect two independent strokes when the drawing is reconstructed.
@immutable
class SakuraCardSubmission {
  SakuraCardSubmission({required Iterable<SakuraStroke> strokes})
    : strokes = List<SakuraStroke>.unmodifiable(
        strokes.map((stroke) => SakuraStroke(stroke.points)),
      ) {
    for (final stroke in this.strokes) {
      if (stroke.points.isEmpty) {
        throw ArgumentError.value(
          strokes,
          'strokes',
          'A submitted stroke cannot be empty.',
        );
      }

      for (final point in stroke.points) {
        _validateNormalizedPoint(point);
      }
    }
  }

  /// Completed strokes in the handwriting area's normalized coordinate space.
  final List<SakuraStroke> strokes;

  /// Converts the snapshot to the only application-owned Firestore field.
  ///
  /// Each stroke is wrapped in a map because a Firestore array cannot directly
  /// contain another array.
  Map<String, Object> toFirestore() => <String, Object>{
    'handwriting': strokes
        .map(
          (stroke) => <String, Object>{
            'points': stroke.points
                .map((point) => <String, double>{'x': point.dx, 'y': point.dy})
                .toList(growable: false),
          },
        )
        .toList(growable: false),
  };

  static void _validateNormalizedPoint(Offset point) {
    if (!point.dx.isFinite ||
        !point.dy.isFinite ||
        point.dx < 0 ||
        point.dx > 1 ||
        point.dy < 0 ||
        point.dy > 1) {
      throw ArgumentError.value(
        point,
        'strokes',
        'Every point must be finite and normalized to the 0.0-1.0 range.',
      );
    }
  }
}
