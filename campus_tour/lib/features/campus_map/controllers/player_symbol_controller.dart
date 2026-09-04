import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

class PlayerSymbolController {
  //自訂玩家位置
  bool _runtimeStarted = false;
  bool _attachedToCurrentStyle = false;
  Symbol? _playerSymbol;
  MapLibreMapController? controller;

  StreamSubscription<CompassEvent>? _compassSub;
  int _walkFrame = 0;
  static const int _defaultWalkSpeed = 140;
  static const double _defaultIconSize = 0.6;

  Timer? _walkAnimationTimer;
  String _currentDirection = 'right';
  LatLng? _latestPlayerLatLng;

  //更新鎖狀態列
  bool _isUpdatingPlayerSymbol = false;
  bool _needsPlayerSymbolUpdate = false;

  PlayerSymbolController(this.controller);
  String get _currentPlayerIcon {
    return 'squirrel_${_currentDirection}_$_walkFrame';
  }

  //初始化
  Future<void> _addPlayerAnimationImages(
    MapLibreMapController controller,
  ) async {
    final directions = ['up', 'right', 'down', 'left'];

    for (final direction in directions) {
      for (int i = 0; i < 4; i++) {
        final imageBytes = await rootBundle.load(
          'assets/images/player/squirrel_${direction}_$i.png',
        );

        await controller.addImage(
          'squirrel_${direction}_$i',
          imageBytes.buffer.asUint8List(),
        );
      }
    }
  }

  //初始化
  void _startWalkAnimation() {
    _walkAnimationTimer?.cancel();

    _walkAnimationTimer = Timer.periodic(
      const Duration(milliseconds: _defaultWalkSpeed),
      (_) {
        _walkFrame = (_walkFrame + 1) % 4;
        _updatePlayerSymbol();
      },
    );
  }

  //初始化
  void _startCompassStream() {
    _compassSub = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null) return;

      final nextDirection = _directionFromHeading(heading);

      if (nextDirection == _currentDirection) return;

      _currentDirection = nextDirection;
      _updatePlayerSymbol();
    });
  }

  String _directionFromHeading(double heading) {
    final normalized = (heading + 360) % 360;

    if (normalized >= 315 || normalized < 45) {
      return 'up';
    } else if (normalized >= 45 && normalized < 135) {
      return 'right';
    } else if (normalized >= 135 && normalized < 225) {
      return 'down';
    } else {
      return 'left';
    }
  }

  //以附帶更新鎖的方式再最後再執行一次最新更新
  Future<void> _updatePlayerSymbol() async {
    if (_isUpdatingPlayerSymbol) {
      _needsPlayerSymbolUpdate = true;
      return;
    }

    _isUpdatingPlayerSymbol = true;

    try {
      await _performPlayerSymbolUpdate();
    } finally {
      _isUpdatingPlayerSymbol = false;
    }

    if (_needsPlayerSymbolUpdate) {
      _needsPlayerSymbolUpdate = false;

      unawaited(_updatePlayerSymbol());
    }
  }

  Future<void> _performPlayerSymbolUpdate() async {
    if (!_attachedToCurrentStyle) return;
    final controller = this.controller;
    final position = _latestPlayerLatLng;

    if (controller == null || position == null) return;

    final iconName = _currentPlayerIcon;

    if (_playerSymbol == null) {
      _playerSymbol = await controller.addSymbol(
        SymbolOptions(
          geometry: position,
          iconImage: iconName,
          iconSize: _defaultIconSize,
          iconAnchor: 'center',
          zIndex: 999,
        ),
      );
    } else {
      await controller.updateSymbol(
        _playerSymbol!,
        SymbolOptions(geometry: position, iconImage: iconName),
      );
    }
  }

  Future<void> updatePosition(LatLng position) async {
    _latestPlayerLatLng = position;
    await _updatePlayerSymbol();
  }

  Future<void> initialize() async {
    final mapController = controller;
    if (mapController == null) {
      throw StateError('SymbolController 尚未取得 MapLibreMapController');
    }

    // 1. 先把玩家動畫圖片註冊進 MapLibre style
    if (!_attachedToCurrentStyle) {
      await _addPlayerAnimationImages(mapController);
      _attachedToCurrentStyle = true;
    }
    // 2. 開始走路動畫
    // 3. 開始監聽指南針方向
    if (!_runtimeStarted) {
      _startWalkAnimation();
      _startCompassStream();
      _runtimeStarted = true;
    }

    _attachedToCurrentStyle = true;
    await _updatePlayerSymbol();
  }

  void dispose() {
    _walkAnimationTimer?.cancel();
    _compassSub?.cancel();
  }

  //預留用
  void resetAfterStyleReload() {
    _attachedToCurrentStyle = false;
    _playerSymbol = null;
  }
}
