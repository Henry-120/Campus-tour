import 'package:campus_tour/features/station_hardware/view_models/sakura_card_draft_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SakuraCardDraftViewModel drawing history', () {
    late SakuraCardDraftViewModel viewModel;

    setUp(() {
      viewModel = SakuraCardDraftViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('a started stroke immediately counts as handwriting', () {
      expect(viewModel.hasHandwriting, isFalse);

      expect(viewModel.beginStroke(const Offset(0.2, 0.3)), isTrue);

      expect(viewModel.hasHandwriting, isTrue);
      expect(viewModel.activePoints, hasLength(1));
    });

    test('undo and redo operate on complete strokes', () {
      _drawStroke(viewModel, const [Offset(0.1, 0.2), Offset(0.4, 0.5)]);
      _drawStroke(viewModel, const [Offset(0.6, 0.7), Offset(0.8, 0.9)]);

      expect(viewModel.strokes, hasLength(2));
      expect(viewModel.canUndo, isTrue);

      viewModel.undo();
      expect(viewModel.strokes, hasLength(1));
      expect(viewModel.canRedo, isTrue);

      viewModel.redo();
      expect(viewModel.strokes, hasLength(2));
    });

    test('clear all is a single reversible action', () {
      _drawStroke(viewModel, const [Offset(0.1, 0.2), Offset(0.2, 0.3)]);
      _drawStroke(viewModel, const [Offset(0.3, 0.4), Offset(0.4, 0.5)]);

      viewModel.clearDrawing();
      expect(viewModel.hasHandwriting, isFalse);
      expect(viewModel.strokes, isEmpty);

      viewModel.undo();
      expect(viewModel.strokes, hasLength(2));

      viewModel.redo();
      expect(viewModel.strokes, isEmpty);
    });

    test('drawing after undo discards redo history', () {
      _drawStroke(viewModel, const [Offset(0.1, 0.1), Offset(0.2, 0.2)]);
      _drawStroke(viewModel, const [Offset(0.3, 0.3), Offset(0.4, 0.4)]);
      viewModel.undo();
      expect(viewModel.canRedo, isTrue);

      _drawStroke(viewModel, const [Offset(0.5, 0.5), Offset(0.6, 0.6)]);

      expect(viewModel.canRedo, isFalse);
      expect(viewModel.strokes, hasLength(2));
    });

    test('stored points are clamped to the normalized card area', () {
      _drawStroke(viewModel, const [Offset(-0.5, 1.4), Offset(2.0, -1.0)]);

      expect(viewModel.strokes.single.points, const [
        Offset(0, 1),
        Offset(1, 0),
      ]);
    });
  });
}

void _drawStroke(SakuraCardDraftViewModel viewModel, List<Offset> points) {
  expect(points, isNotEmpty);
  expect(viewModel.beginStroke(points.first), isTrue);
  for (final point in points.skip(1)) {
    expect(viewModel.appendPoint(point), isTrue);
  }
  viewModel.endStroke();
}
