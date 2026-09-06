import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class NearestMonsterArrowController {
  static const String _arrowAssetPath = 'assets/images/arrow_global_3.png';
  static const String _arrowImageId = 'nearest-monster-arrow-image';
  static const double _earthRadiusMeters = 6371008.8;
  static const double _radiusMeters = 25;
  static const double _iconSize = 0.5;
  static const double _imageRotationOffset = 0;
  static const int _imageSize = 96;
  static const int _zIndex = 998;

  MapLibreMapController? _mapController;
  Symbol? _arrowSymbol;

  LatLng? _latestPlayerPosition;
  LatLng? _latestMonsterPosition;
  double _cameraBearing = 0;

  Uint8List? _preparedImageBytes;
  Future<Uint8List>? _prepareImageFuture;
  Future<void>? _initializeFuture;
  Future<void>? _arrowSyncFuture;

  bool _imageRegisteredToCurrentStyle = false;
  bool _styleReady = false;
  bool _needsArrowSync = false;
  bool _isDisposed = false;

  int _styleRevision = 0;

  void attachMapController(MapLibreMapController controller) {
    if (_isDisposed || identical(_mapController, controller)) return;

    _mapController = controller;
    _cameraBearing = _normalizedBearing(
      controller.cameraPosition?.bearing ?? 0,
    );
    _imageRegisteredToCurrentStyle = false;
    _arrowSymbol = null;
    _styleReady = false;
    _needsArrowSync = true;
    _initializeFuture = null;
  }

  Future<void> initialize() {
    if (_isDisposed) return Future<void>.value();

    final runningInitialization = _initializeFuture;
    if (runningInitialization != null) return runningInitialization;

    final initialization = _initializeCurrentStyle();
    _initializeFuture = initialization;

    return initialization.whenComplete(() {
      if (identical(_initializeFuture, initialization)) {
        _initializeFuture = null;
      }
    });
  }

  Future<void> _initializeCurrentStyle() async {
    final controller = _mapController;
    if (controller == null) {
      throw StateError(
        'NearestMonsterArrowController 尚未取得 MapLibreMapController',
      );
    }

    final revision = _styleRevision;

    try {
      final bytes = await _prepareArrowImage();
      if (!_isCurrentLifecycle(controller, revision)) return;

      if (!_imageRegisteredToCurrentStyle) {
        await _registerArrowImage(controller, bytes);
        if (!_isCurrentLifecycle(controller, revision)) return;

        _imageRegisteredToCurrentStyle = true;
      }

      _styleReady = true;

      // 如果 style 載入前已收到位置，現在立刻補上箭頭。
      await _requestArrowSync();
    } catch (_) {
      if (!_isCurrentLifecycle(controller, revision)) return;

      _styleReady = false;
      rethrow;
    }
  }

  Future<Uint8List> _prepareArrowImage() async {
    final cachedBytes = _preparedImageBytes;
    if (cachedBytes != null) return cachedBytes;

    final runningPreparation = _prepareImageFuture;
    if (runningPreparation != null) return runningPreparation;

    final preparation = _loadAndResizeArrowImage();
    _prepareImageFuture = preparation;

    try {
      final bytes = await preparation;
      if (!_isDisposed) {
        _preparedImageBytes = bytes;
      }
      return bytes;
    } finally {
      if (identical(_prepareImageFuture, preparation)) {
        _prepareImageFuture = null;
      }
    }
  }

  Future<Uint8List> _loadAndResizeArrowImage() async {
    final imageData = await rootBundle.load(_arrowAssetPath);
    final originalBytes = imageData.buffer.asUint8List(
      imageData.offsetInBytes,
      imageData.lengthInBytes,
    );
    final codec = await ui.instantiateImageCodec(
      originalBytes,
      targetWidth: _imageSize,
      targetHeight: _imageSize,
    );

    try {
      final frame = await codec.getNextFrame();

      try {
        final resizedData = await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (resizedData == null) {
          throw StateError('無法轉換最近怪物箭頭圖片');
        }

        return resizedData.buffer.asUint8List(
          resizedData.offsetInBytes,
          resizedData.lengthInBytes,
        );
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  Future<void> _registerArrowImage(
    MapLibreMapController controller,
    Uint8List bytes,
  ) async {
    try {
      await controller.addImage(_arrowImageId, bytes);
    } catch (error) {
      debugPrint('[NearestMonsterArrowController] 註冊箭頭圖片失敗：$error');
      rethrow;
    }
  }

  //更新位置
  Future<void> updateDirection({
    required LatLng playerPosition,
    required LatLng monsterPosition,
  }) async {
    if (_isDisposed) return;

    _latestPlayerPosition = playerPosition;
    _latestMonsterPosition = monsterPosition;
    await _requestArrowSync();
  }

  /// 可直接傳給 MapLibreMap.onCameraMove。
  void handleCameraMove(CameraPosition cameraPosition) {
    if (_isDisposed || !cameraPosition.bearing.isFinite) return;

    final nextBearing = _normalizedBearing(cameraPosition.bearing);
    if (_shortestBearingDelta(_cameraBearing, nextBearing).abs() < 0.01) {
      return;
    }

    _cameraBearing = nextBearing;
    unawaited(_syncAfterCameraMove());
  }

  Future<void> _syncAfterCameraMove() async {
    try {
      await _requestArrowSync();
    } catch (error, stackTrace) {
      debugPrint(
        '[NearestMonsterArrowController] 更新地圖旋轉後的箭頭失敗：'
        '$error\n$stackTrace',
      );
    }
  }

  Future<void> hide() async {
    if (_isDisposed) return;

    _latestMonsterPosition = null;
    await _requestArrowSync();
  }

  //重複非同步鎖
  Future<void> _requestArrowSync() {
    if (_isDisposed ||
        !_styleReady ||
        !_imageRegisteredToCurrentStyle ||
        _mapController == null) {
      return Future<void>.value();
    }

    _needsArrowSync = true;
    return _arrowSyncFuture ??= _runArrowSync();
  }

  //檢查重複要求
  Future<void> _runArrowSync() async {
    try {
      while (_needsArrowSync &&
          !_isDisposed &&
          _styleReady &&
          _imageRegisteredToCurrentStyle) {
        _needsArrowSync = false;
        await _syncArrow();
      }
    } finally {
      _arrowSyncFuture = null;
    }
  }

  Future<void> _syncArrow() async {
    final controller = _mapController;
    if (controller == null ||
        _isDisposed ||
        !_styleReady ||
        !_imageRegisteredToCurrentStyle) {
      return;
    }

    final revision = _styleRevision;
    final playerPosition = _latestPlayerPosition;
    final monsterPosition = _latestMonsterPosition;
    final cameraBearing = _cameraBearing;

    if (playerPosition == null || monsterPosition == null) {
      await _removeArrow(controller, revision);
      return;
    }

    // 1. 計算玩家到怪物的 bearing
    final monsterBearing = _bearingBetween(playerPosition, monsterPosition);
    if (!monsterBearing.isFinite) return;

    // 2. 計算固定半徑上的箭頭座標
    final arrowPosition = _destinationPoint(
      origin: playerPosition,
      bearingDegrees: monsterBearing,
      distanceMeters: _radiusMeters,
    );
    final iconRotation = _normalizedBearing(
      monsterBearing - cameraBearing + _imageRotationOffset,
    );

    if (!_isCurrentStyle(controller, revision)) return;

    final existingSymbol = _arrowSymbol;

    // 3-A. 尚未建立箭頭
    if (existingSymbol == null) {
      try {
        final newSymbol = await controller.addSymbol(
          SymbolOptions(
            geometry: arrowPosition,
            iconImage: _arrowImageId,
            iconRotate: iconRotation,
            iconSize: _iconSize,
            iconAnchor: 'center',
            zIndex: _zIndex,
          ),
          const {'kind': 'nearestMonsterArrow'},
        );
        if (!_isCurrentStyle(controller, revision)) return;

        _arrowSymbol = newSymbol;
      } catch (_) {
        if (!_isCurrentStyle(controller, revision)) return;
        rethrow;
      }
      return;
    }

    // 3-B. 箭頭已存在，只更新位置與旋轉角度
    try {
      await controller.updateSymbol(
        existingSymbol,
        SymbolOptions(geometry: arrowPosition, iconRotate: iconRotation),
      );
      if (!_isCurrentStyle(controller, revision)) return;
    } catch (_) {
      if (!_isCurrentStyle(controller, revision)) return;
      rethrow;
    }
  }

  Future<void> _removeArrow(
    MapLibreMapController controller,
    int revision,
  ) async {
    final existingSymbol = _arrowSymbol;
    if (existingSymbol == null) return;

    try {
      await controller.removeSymbol(existingSymbol);
      if (!_isCurrentStyle(controller, revision)) return;

      if (identical(_arrowSymbol, existingSymbol)) {
        _arrowSymbol = null;
      }
    } catch (_) {
      if (!_isCurrentStyle(controller, revision)) return;
      rethrow;
    }
  }

  double _bearingBetween(LatLng start, LatLng end) {
    final startLatitude = _toRadians(start.latitude);
    final endLatitude = _toRadians(end.latitude);
    final longitudeDifference = _toRadians(end.longitude - start.longitude);
    final y = math.sin(longitudeDifference) * math.cos(endLatitude);
    final x =
        math.cos(startLatitude) * math.sin(endLatitude) -
        math.sin(startLatitude) *
            math.cos(endLatitude) *
            math.cos(longitudeDifference);

    return _normalizedBearing(_toDegrees(math.atan2(y, x)));
  }

  LatLng _destinationPoint({
    required LatLng origin,
    required double bearingDegrees,
    required double distanceMeters,
  }) {
    final angularDistance = distanceMeters / _earthRadiusMeters;
    final bearing = _toRadians(bearingDegrees);
    final startLatitude = _toRadians(origin.latitude);
    final startLongitude = _toRadians(origin.longitude);
    final endLatitude = math.asin(
      math.sin(startLatitude) * math.cos(angularDistance) +
          math.cos(startLatitude) *
              math.sin(angularDistance) *
              math.cos(bearing),
    );
    final endLongitude =
        startLongitude +
        math.atan2(
          math.sin(bearing) *
              math.sin(angularDistance) *
              math.cos(startLatitude),
          math.cos(angularDistance) -
              math.sin(startLatitude) * math.sin(endLatitude),
        );
    final normalizedLongitude =
        (endLongitude + 3 * math.pi) % (2 * math.pi) - math.pi;

    return LatLng(_toDegrees(endLatitude), _toDegrees(normalizedLongitude));
  }

  bool _isCurrentLifecycle(MapLibreMapController controller, int revision) {
    return !_isDisposed &&
        revision == _styleRevision &&
        identical(controller, _mapController);
  }

  bool _isCurrentStyle(MapLibreMapController controller, int revision) {
    return _isCurrentLifecycle(controller, revision) &&
        _styleReady &&
        _imageRegisteredToCurrentStyle;
  }

  double _normalizedBearing(double bearing) {
    if (!bearing.isFinite) return 0;
    return (bearing % 360 + 360) % 360;
  }

  double _shortestBearingDelta(double from, double to) {
    return (to - from + 540) % 360 - 180;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  double _toDegrees(double radians) => radians * 180 / math.pi;

  void resetAfterStyleReload() {
    if (_isDisposed) return;

    _styleRevision++;
    _styleReady = false;
    _imageRegisteredToCurrentStyle = false;
    _arrowSymbol = null;
    _needsArrowSync = true;
    _initializeFuture = null;
  }

  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _styleRevision++;
    _styleReady = false;
    _imageRegisteredToCurrentStyle = false;
    _needsArrowSync = false;
    _arrowSymbol = null;
    _latestPlayerPosition = null;
    _latestMonsterPosition = null;
    _mapController = null;
    _preparedImageBytes = null;
    _prepareImageFuture = null;
    _initializeFuture = null;
    _arrowSyncFuture = null;
  }
}
