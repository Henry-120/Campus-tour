import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

class PlayerSymbolController {
  //自訂玩家位置
  bool _runtimeStarted = false;
  bool _attachedToCurrentStyle = false;
  Symbol? _playerSymbol;
  MapLibreMapController? _mapController;

  StreamSubscription<CompassEvent>? _compassSub;
  double? _deviceHeading;
  double _cameraBearing = 0;
  int _walkFrame = 0;
  static const int _defaultWalkSpeed = 140;
  static const double _defaultIconSize = 0.6;

  Timer? _walkAnimationTimer;
  String _currentDirection = 'right';
  LatLng? _latestPlayerLatLng;
  int _styleRevision = 0;
  bool _isDisposed = false;

  //更新鎖狀態列
  bool _isUpdatingPlayerSymbol = false;
  bool _needsPlayerSymbolUpdate = false;

  PlayerSymbolController();
  String get _currentPlayerIcon {
    return 'squirrel_${_currentDirection}_$_walkFrame';
  }

  void attachMapController(MapLibreMapController controller) {
    if (_isDisposed) return;
    if (identical(_mapController, controller)) return;

    _mapController = controller;
    _cameraBearing = _normalizeBearing(controller.cameraPosition?.bearing ?? 0);
    _attachedToCurrentStyle = false;
    _playerSymbol = null;
    _updateDirectionFromCurrentBearings();
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
      if (heading == null || !heading.isFinite) return;

      _deviceHeading = _normalizeBearing(heading);
      _updateDirectionFromCurrentBearings();
    });
  }

  /// 可直接由主地圖的 MapLibreMap.onCameraMove 呼叫。
  void handleCameraMove(CameraPosition cameraPosition) {
    if (_isDisposed || !cameraPosition.bearing.isFinite) return;

    final nextBearing = _normalizeBearing(cameraPosition.bearing);
    if (_shortestBearingDelta(_cameraBearing, nextBearing).abs() < 0.01) {
      return;
    }

    _cameraBearing = nextBearing;
    _updateDirectionFromCurrentBearings();
  }

  void _updateDirectionFromCurrentBearings() {
    final deviceHeading = _deviceHeading;
    if (deviceHeading == null) return;

    final relativeHeading = _normalizeBearing(deviceHeading - _cameraBearing);
    final nextDirection = _directionFromHeading(relativeHeading);

    if (nextDirection == _currentDirection) return;

    _currentDirection = nextDirection;
    unawaited(_updatePlayerSymbol());
  }

  String _directionFromHeading(double heading) {
    final normalized = _normalizeBearing(heading);

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

  double _normalizeBearing(double bearing) {
    return (bearing % 360 + 360) % 360;
  }

  double _shortestBearingDelta(double from, double to) {
    return (to - from + 540) % 360 - 180;
  }

  //以附帶更新鎖的方式再最後再執行一次最新更新
  Future<void> _updatePlayerSymbol() async {
    if (_isDisposed) return;
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
    if (_isDisposed || !_attachedToCurrentStyle) return;
    final revision = _styleRevision;

    final controller = _mapController;
    final position = _latestPlayerLatLng;

    if (controller == null || position == null) return;

    final iconName = _currentPlayerIcon;

    if (_playerSymbol == null) {
      try {
        final newSymbol = await controller.addSymbol(
          SymbolOptions(
            geometry: position,
            iconImage: iconName,
            iconSize: _defaultIconSize,
            iconAnchor: 'center',
            zIndex: 999,
          ),
        );
        if (revision != _styleRevision ||
            !identical(controller, _mapController)) {
          return;
        }
        _playerSymbol = newSymbol;
      } catch (error) {
        final operationIsStale =
            _isDisposed ||
            revision != _styleRevision ||
            !identical(controller, _mapController);

        if (operationIsStale) return;

        rethrow;
      }
    } else {
      try {
        await controller.updateSymbol(
          _playerSymbol!,
          SymbolOptions(geometry: position, iconImage: iconName),
        );
      } catch (error) {
        final operationIsStale =
            _isDisposed ||
            revision != _styleRevision ||
            !identical(controller, _mapController);

        if (operationIsStale) return;

        rethrow;
      }
    }
  }

  Future<void> updatePosition(LatLng position) async {
    if (_isDisposed) return;
    _latestPlayerLatLng = position;
    await _updatePlayerSymbol();
  }

  Future<void> initialize() async {
    if (_isDisposed) return;
    final mapController = _mapController;
    if (mapController == null) {
      throw StateError('SymbolController 尚未取得 MapLibreMapController');
    }
    final revision = _styleRevision;
    // 1. 先把玩家動畫圖片註冊進 MapLibre style
    if (!_attachedToCurrentStyle) {
      try {
        await _addPlayerAnimationImages(mapController);
        if (_isDisposed ||
            revision != _styleRevision ||
            !identical(mapController, _mapController)) {
          return;
        }
        _attachedToCurrentStyle = true;
      } catch (error) {
        final operationIsStale =
            _isDisposed ||
            revision != _styleRevision ||
            !identical(mapController, _mapController);

        if (operationIsStale) return;

        rethrow;
      }
    }
    // 2. 開始走路動畫
    // 3. 開始監聽指南針方向
    if (!_runtimeStarted) {
      _startWalkAnimation();
      _startCompassStream();
      _runtimeStarted = true;
    }
    await _updatePlayerSymbol();
  }

  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _styleRevision++;

    _walkAnimationTimer?.cancel();
    _walkAnimationTimer = null;

    unawaited(_compassSub?.cancel());
    _compassSub = null;

    _attachedToCurrentStyle = false;
    _playerSymbol = null;
    _mapController = null;
    _deviceHeading = null;
    _cameraBearing = 0;
    _needsPlayerSymbolUpdate = false;
  }

  //預留用
  void resetAfterStyleReload() {
    if (_isDisposed) return;

    _styleRevision++;
    _attachedToCurrentStyle = false;
    _playerSymbol = null;
  }
}
