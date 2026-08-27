import 'dart:ui';

import 'package:campus_tour/features/station_hardware/models/sakura_card_draft.dart';
import 'package:campus_tour/models/user_monster_model.dart';
import 'package:flutter/foundation.dart';

class SakuraCardDraftViewModel extends ChangeNotifier {
  static const int maxStrokes = 50;
  static const int maxPoints = 1500;
  static const int maxMessageCharacters = 60;
  static const int _maxHistoryEntries = 60;

  List<SakuraStroke> _strokes = <SakuraStroke>[];
  final List<Offset> _activePoints = <Offset>[];
  final List<List<SakuraStroke>> _undoHistory = <List<SakuraStroke>>[];
  final List<List<SakuraStroke>> _redoHistory = <List<SakuraStroke>>[];
  UserMonsterModel? _selectedMonster;
  String _message = '';

  List<SakuraStroke> get strokes => List<SakuraStroke>.unmodifiable(_strokes);
  List<Offset> get activePoints => List<Offset>.unmodifiable(_activePoints);
  UserMonsterModel? get selectedMonster => _selectedMonster;
  String get message => _message;

  bool get hasHandwriting => _strokes.isNotEmpty || _activePoints.isNotEmpty;
  bool get canUndo => _undoHistory.isNotEmpty && _activePoints.isEmpty;
  bool get canRedo => _redoHistory.isNotEmpty && _activePoints.isEmpty;
  bool get canClear => hasHandwriting;

  int get pointCount =>
      _strokes.fold<int>(0, (count, stroke) => count + stroke.points.length) +
      _activePoints.length;

  bool beginStroke(Offset normalizedPoint) {
    if (_activePoints.isNotEmpty ||
        _strokes.length >= maxStrokes ||
        pointCount >= maxPoints) {
      return false;
    }

    _activePoints.add(_clamp(normalizedPoint));
    notifyListeners();
    return true;
  }

  bool appendPoint(Offset normalizedPoint) {
    if (_activePoints.isEmpty || pointCount >= maxPoints) return false;

    _activePoints.add(_clamp(normalizedPoint));
    notifyListeners();
    return true;
  }

  void endStroke() {
    if (_activePoints.isEmpty) return;

    _saveUndoState();
    _strokes.add(SakuraStroke(_activePoints));
    _activePoints.clear();
    _redoHistory.clear();
    notifyListeners();
  }

  void cancelStroke() {
    if (_activePoints.isEmpty) return;
    _activePoints.clear();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;

    _redoHistory.add(List<SakuraStroke>.of(_strokes));
    _strokes = List<SakuraStroke>.of(_undoHistory.removeLast());
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;

    _pushBounded(_undoHistory, List<SakuraStroke>.of(_strokes));
    _strokes = List<SakuraStroke>.of(_redoHistory.removeLast());
    notifyListeners();
  }

  void clearDrawing() {
    if (!canClear) return;

    _activePoints.clear();
    _saveUndoState();
    _strokes = <SakuraStroke>[];
    _redoHistory.clear();
    notifyListeners();
  }

  void selectMonster(UserMonsterModel monster) {
    if (identical(_selectedMonster, monster)) return;
    _selectedMonster = monster;
    notifyListeners();
  }

  void updateMessage(String value) {
    if (_message == value) return;
    _message = value;
    notifyListeners();
  }

  void clearDraft() {
    _strokes = <SakuraStroke>[];
    _activePoints.clear();
    _undoHistory.clear();
    _redoHistory.clear();
    _selectedMonster = null;
    _message = '';
    notifyListeners();
  }

  void _saveUndoState() {
    _pushBounded(_undoHistory, List<SakuraStroke>.of(_strokes));
  }

  void _pushBounded(
    List<List<SakuraStroke>> history,
    List<SakuraStroke> state,
  ) {
    history.add(state);
    if (history.length > _maxHistoryEntries) history.removeAt(0);
  }

  Offset _clamp(Offset point) {
    return Offset(
      point.dx.clamp(0.0, 1.0).toDouble(),
      point.dy.clamp(0.0, 1.0).toDouble(),
    );
  }
}
