import 'dart:async';
import 'dart:math' as math;

import 'package:campus_tour/features/campus_map/models/map_viewport_config.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class CampusMapCameraController {
  static const Duration _playerReturnAnimationDuration = Duration(
    milliseconds: 400,
  );

  CampusMapCameraController({required MapViewportConfig config})
    : initialCenter = config.initialCenter,
      cameraBounds = config.cameraBounds,
      maxZoom = config.maxZoom,
      padding = config.padding,
      fallbackMinZoom = config.fallbackMinZoom,
      playerFocusZoom = config.playerFocusZoom,
      keepViewportInsideBounds = config.keepViewportInsideBounds,
      edgeBufferPixels = config.edgeBufferPixels,
      _cameraTargetBounds = config.cameraBounds,
      _minZoom = config.fallbackMinZoom,
      _currentZoom = config.fallbackMinZoom,
      _cameraTargetBoundsZoom = config.fallbackMinZoom,
      _pendingCameraTargetBoundsZoom = config.fallbackMinZoom;

  final LatLng initialCenter;
  final LatLngBounds cameraBounds;
  final double maxZoom;
  final double padding;
  final double fallbackMinZoom;
  final double playerFocusZoom;
  final bool keepViewportInsideBounds;
  final double edgeBufferPixels;

  MapLibreMapController? _mapController;

  Size? _viewportSize;
  LatLngBounds _cameraTargetBounds;
  LatLngBounds? _pendingCameraTargetBounds;
  double _minZoom;
  double _currentZoom;
  double _cameraTargetBoundsZoom;
  double _pendingCameraTargetBoundsZoom;
  bool _isViewportReady = false;
  bool _isCorrectingCamera = false;
  int _programmaticCameraMoveDepth = 0;

  double get minZoom => _minZoom;

  bool get isViewportReady => _isViewportReady;

  MinMaxZoomPreference get zoomPreference {
    return MinMaxZoomPreference(_minZoom, maxZoom);
  }

  CameraTargetBounds get cameraTargetBounds {
    // Android 原生 API 只限制鏡頭中心，所以要使用向內縮過的安全範圍；
    // iOS 的 maximumScreenBounds 已限制整個可見畫面，使用原始圖片範圍即可。
    final nativeBounds =
        keepViewportInsideBounds && defaultTargetPlatform == TargetPlatform.iOS
        ? cameraBounds
        : _cameraTargetBounds;
    return CameraTargetBounds(nativeBounds);
  }

  CameraPosition getInitialCameraPosition(LatLng initialCenter) {
    return CameraPosition(
      target: initialCenter,
      zoom: _minZoom,
      bearing: 0,
      tilt: 0,
    );
  }

  void attachMapController(MapLibreMapController controller) {
    _mapController = controller;
  }

  void prepareViewport(BuildContext context) {
    prepareViewportForSize(MediaQuery.sizeOf(context));
  }

  /// 依照實際地圖畫面尺寸計算最低縮放與安全鏡頭中心範圍。
  ///
  /// 主地圖採用 cover 邏輯，確保拖曳與縮放時不會露出圖片邊界；
  /// 其他地圖維持原本完整顯示整張圖片的 contain 邏輯。
  @visibleForTesting
  void prepareViewportForSize(Size screenSize) {
    final wasViewportReady = _isViewportReady;
    _viewportSize = screenSize;

    if (keepViewportInsideBounds) {
      _minZoom = _calculateCoverMinZoom(
        screenSize: screenSize,
        bounds: cameraBounds,
        edgeBufferPixels: edgeBufferPixels,
      );
      _currentZoom = wasViewportReady ? _normalizeZoom(_currentZoom) : _minZoom;
      _cameraTargetBounds = _calculateSafeCameraTargetBounds(
        screenSize: screenSize,
        bounds: cameraBounds,
        zoom: _currentZoom,
        edgeBufferPixels: edgeBufferPixels,
      );
      _pendingCameraTargetBounds = _cameraTargetBounds;
      _cameraTargetBoundsZoom = _currentZoom;
      _pendingCameraTargetBoundsZoom = _currentZoom;
    } else {
      _minZoom = _calculateContainMinZoom(
        screenSize: screenSize,
        bounds: cameraBounds,
        padding: padding,
      );
      _currentZoom = wasViewportReady ? _normalizeZoom(_currentZoom) : _minZoom;
      _cameraTargetBounds = cameraBounds;
      _pendingCameraTargetBounds = cameraBounds;
      _cameraTargetBoundsZoom = _currentZoom;
      _pendingCameraTargetBoundsZoom = _currentZoom;
    }

    _isViewportReady = true;
  }

  /// 根據目前 zoom 準備新的安全邊界。
  ///
  /// Android 的原生邊界只限制鏡頭中心，因此縮小時還會立即修正已超界的
  /// target；正式邊界等相機停止後再提交，避免縮放中頻繁重建 MapLibre。
  void handleCameraMove(
    CameraPosition cameraPosition, {
    required bool constrainToBounds,
  }) {
    if (!cameraPosition.zoom.isFinite) return;

    _currentZoom = _normalizeZoom(cameraPosition.zoom);
    if (!keepViewportInsideBounds) return;

    final screenSize = _viewportSize;
    if (screenSize == null) return;

    final nextBounds = _calculateSafeCameraTargetBounds(
      screenSize: screenSize,
      bounds: cameraBounds,
      zoom: _currentZoom,
      edgeBufferPixels: edgeBufferPixels,
    );
    _pendingCameraTargetBounds = nextBounds;
    _pendingCameraTargetBoundsZoom = _currentZoom;

    if (!constrainToBounds || defaultTargetPlatform == TargetPlatform.iOS) {
      return;
    }

    // 程式已經依目標 zoom 算好合法位置，避免動態修正打斷定位動畫。
    if (_programmaticCameraMoveDepth > 0) return;

    final correctedTarget = _clampTargetToBounds(
      cameraPosition.target,
      nextBounds,
    );
    if (_samePosition(correctedTarget, cameraPosition.target)) return;

    unawaited(_correctCameraTarget(cameraPosition, correctedTarget));
  }

  /// 相機停止後才更新傳給 MapLibre 的原生邊界。
  ///
  /// 回傳 true 代表 Canvas 需要重建一次，將新的 cameraTargetBounds 套用到原生地圖。
  bool commitPendingCameraTargetBounds({required bool constrainToBounds}) {
    if (!keepViewportInsideBounds ||
        !constrainToBounds ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return false;
    }

    final pendingBounds = _pendingCameraTargetBounds;
    if (pendingBounds == null ||
        (_cameraTargetBoundsZoom - _pendingCameraTargetBoundsZoom).abs() <
            0.001) {
      return false;
    }

    _cameraTargetBounds = pendingBounds;
    _cameraTargetBoundsZoom = _pendingCameraTargetBoundsZoom;
    return true;
  }

  Future<void> fitCameraBounds() async {
    final controller = _mapController;
    if (controller == null) return;

    if (keepViewportInsideBounds) {
      // 主地圖不能再使用顯示完整圖片的 fit，否則長寬比不同時會露出邊界。
      await controller.moveCamera(
        CameraUpdate.newLatLngZoom(
          _resolveTarget(
            initialCenter,
            constrainToBounds: true,
            zoom: _minZoom,
          ),
          _minZoom,
        ),
      );
      return;
    }

    await controller.moveCamera(
      CameraUpdate.newLatLngBounds(
        cameraBounds,
        left: padding,
        top: padding,
        right: padding,
        bottom: padding,
      ),
    );
  }

  Future<void> zoomIn() async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> zoomOut() async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> moveTo(
    LatLng target, {
    double zoom = 18,
    bool constrainToBounds = true,
  }) async {
    final controller = _mapController;
    if (controller == null) return;
    final effectiveZoom = _normalizeZoom(zoom);

    await _runProgrammaticCameraMove(() async {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          _resolveTarget(
            target,
            constrainToBounds: constrainToBounds,
            zoom: effectiveZoom,
          ),
          effectiveZoom,
        ),
      );
    });
  }

  Future<void> followPlayer(
    LatLng position, {
    bool constrainToBounds = true,
  }) async {
    final controller = _mapController;
    if (controller == null) return;

    await _runProgrammaticCameraMove(() async {
      await controller.animateCamera(
        CameraUpdate.newLatLng(
          _resolveTarget(
            position,
            constrainToBounds: constrainToBounds,
            zoom: _currentZoom,
          ),
        ),
      );
    });
  }

  Future<void> returnToPlayer(
    LatLng position, {
    bool constrainToBounds = true,
    bool animated = true,
  }) async {
    final controller = _mapController;
    if (controller == null) return;
    final effectiveZoom = _normalizeZoom(playerFocusZoom);

    final cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _resolveTarget(
          position,
          constrainToBounds: constrainToBounds,
          zoom: effectiveZoom,
        ),
        zoom: effectiveZoom,
        bearing: 0,
        tilt: 0,
      ),
    );

    await _runProgrammaticCameraMove(() async {
      if (!animated) {
        // 動態邊界套用後立即做最後校正，不再播放第二次動畫。
        await controller.moveCamera(cameraUpdate);
        return;
      }

      final result = await controller.animateCamera(
        cameraUpdate,
        duration: _playerReturnAnimationDuration,
      );

      if (result == null && defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS 會立即回傳 null，等待指定動畫時間後才允許其他相機操作接手。
        await Future<void>.delayed(_playerReturnAnimationDuration);
      }
    });
  }

  Future<void> _runProgrammaticCameraMove(Future<void> Function() move) async {
    _programmaticCameraMoveDepth++;
    try {
      await move();
    } finally {
      // 即使原生地圖取消動畫或發生例外，也一定解除動態修正鎖定。
      _programmaticCameraMoveDepth--;
    }
  }

  LatLng _resolveTarget(
    LatLng target, {
    required bool constrainToBounds,
    required double zoom,
  }) {
    if (!keepViewportInsideBounds || !constrainToBounds) return target;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _clampTargetToBounds(target, cameraBounds);
    }

    final screenSize = _viewportSize;
    if (screenSize == null) {
      return _clampTargetToBounds(target, _cameraTargetBounds);
    }

    final zoomBounds = _calculateSafeCameraTargetBounds(
      screenSize: screenSize,
      bounds: cameraBounds,
      zoom: _normalizeZoom(zoom),
      edgeBufferPixels: edgeBufferPixels,
    );
    return _clampTargetToBounds(target, zoomBounds);
  }

  LatLng _clampTargetToBounds(LatLng target, LatLngBounds targetBounds) {
    return LatLng(
      target.latitude
          .clamp(
            targetBounds.southwest.latitude,
            targetBounds.northeast.latitude,
          )
          .toDouble(),
      target.longitude
          .clamp(
            targetBounds.southwest.longitude,
            targetBounds.northeast.longitude,
          )
          .toDouble(),
    );
  }

  Future<void> _correctCameraTarget(
    CameraPosition cameraPosition,
    LatLng correctedTarget,
  ) async {
    final controller = _mapController;
    if (controller == null || _isCorrectingCamera) return;

    _isCorrectingCamera = true;
    try {
      // 使用 moveCamera 立即拉回合法位置，避免縮小過程短暫停在圖片外側。
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: correctedTarget,
            zoom: _normalizeZoom(cameraPosition.zoom),
            bearing: cameraPosition.bearing,
            tilt: cameraPosition.tilt,
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('[CampusMapCameraController] 修正動態鏡頭邊界失敗：$error\n$stackTrace');
    } finally {
      _isCorrectingCamera = false;
    }
  }

  double _normalizeZoom(double zoom) {
    return zoom.clamp(_minZoom, maxZoom).toDouble();
  }

  bool _samePosition(LatLng first, LatLng second) {
    const tolerance = 0.000000001;
    return (first.latitude - second.latitude).abs() <= tolerance &&
        (first.longitude - second.longitude).abs() <= tolerance;
  }

  double _calculateContainMinZoom({
    required Size screenSize,
    required LatLngBounds bounds,
    required double padding,
  }) {
    final usableWidth = screenSize.width - padding * 2;
    final usableHeight = screenSize.height - padding * 2;

    if (usableWidth <= 0 || usableHeight <= 0) {
      return fallbackMinZoom;
    }

    final fractions = _projectedBoundsFractions(bounds);
    if (fractions.width <= 0 || fractions.height <= 0) {
      return fallbackMinZoom;
    }

    const tileSize = 512.0;
    final zoomX = math.log(usableWidth / tileSize / fractions.width) / math.ln2;
    final zoomY =
        math.log(usableHeight / tileSize / fractions.height) / math.ln2;

    return math.min(zoomX, zoomY) - 0.05;
  }

  double _calculateCoverMinZoom({
    required Size screenSize,
    required LatLngBounds bounds,
    required double edgeBufferPixels,
  }) {
    final requiredWidth = screenSize.width + edgeBufferPixels * 2;
    final requiredHeight = screenSize.height + edgeBufferPixels * 2;

    if (requiredWidth <= 0 || requiredHeight <= 0) {
      return fallbackMinZoom;
    }

    final fractions = _projectedBoundsFractions(bounds);
    if (fractions.width <= 0 || fractions.height <= 0) {
      return fallbackMinZoom;
    }

    const tileSize = 512.0;
    final zoomX =
        math.log(requiredWidth / tileSize / fractions.width) / math.ln2;
    final zoomY =
        math.log(requiredHeight / tileSize / fractions.height) / math.ln2;

    // cover 必須選擇較大的倍率，才能讓地圖寬、高都覆蓋手機畫面。
    return math.max(zoomX, zoomY);
  }

  LatLngBounds _calculateSafeCameraTargetBounds({
    required Size screenSize,
    required LatLngBounds bounds,
    required double zoom,
    required double edgeBufferPixels,
  }) {
    const tileSize = 512.0;
    final worldSize = tileSize * math.pow(2, zoom);
    final halfViewportWidth =
        (screenSize.width / 2 + edgeBufferPixels) / worldSize;
    final halfViewportHeight =
        (screenSize.height / 2 + edgeBufferPixels) / worldSize;

    final westX = _longitudeToWorldX(bounds.southwest.longitude);
    final eastX = _longitudeToWorldX(bounds.northeast.longitude);
    final northY = _latitudeToWorldY(bounds.northeast.latitude);
    final southY = _latitudeToWorldY(bounds.southwest.latitude);

    var minimumX = westX + halfViewportWidth;
    var maximumX = eastX - halfViewportWidth;
    var minimumY = northY + halfViewportHeight;
    var maximumY = southY - halfViewportHeight;

    // 理論上 cover 倍率會保證範圍有效；此防護避免極端尺寸或浮點誤差造成反轉。
    if (minimumX > maximumX) {
      minimumX = maximumX = (westX + eastX) / 2;
    }
    if (minimumY > maximumY) {
      minimumY = maximumY = (northY + southY) / 2;
    }

    return LatLngBounds(
      southwest: LatLng(
        _worldYToLatitude(maximumY),
        _worldXToLongitude(minimumX),
      ),
      northeast: LatLng(
        _worldYToLatitude(minimumY),
        _worldXToLongitude(maximumX),
      ),
    );
  }

  ({double width, double height}) _projectedBoundsFractions(
    LatLngBounds bounds,
  ) {
    final westX = _longitudeToWorldX(bounds.southwest.longitude);
    final eastX = _longitudeToWorldX(bounds.northeast.longitude);
    final northY = _latitudeToWorldY(bounds.northeast.latitude);
    final southY = _latitudeToWorldY(bounds.southwest.latitude);

    return (width: (eastX - westX).abs(), height: (southY - northY).abs());
  }

  double _longitudeToWorldX(double longitude) {
    return (longitude + 180.0) / 360.0;
  }

  double _latitudeToWorldY(double latitude) {
    final latitudeRadians = latitude * math.pi / 180.0;
    return (1.0 -
            math.log(
                  math.tan(latitudeRadians) + 1.0 / math.cos(latitudeRadians),
                ) /
                math.pi) /
        2.0;
  }

  double _worldXToLongitude(double worldX) {
    return worldX * 360.0 - 180.0;
  }

  double _worldYToLatitude(double worldY) {
    final mercator = math.pi * (1.0 - 2.0 * worldY);
    final hyperbolicSine = (math.exp(mercator) - math.exp(-mercator)) / 2.0;
    return math.atan(hyperbolicSine) * 180.0 / math.pi;
  }
}
