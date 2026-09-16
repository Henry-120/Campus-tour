import 'dart:math' as math;

import 'package:campus_tour/features/campus_map/controllers/campus_map_camera_controller.dart';
import 'package:campus_tour/features/campus_map/models/map_viewport_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

void main() {
  group('CampusMapCameraController 主地圖畫面限制', () {
    late CampusMapCameraController controller;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      controller = CampusMapCameraController(
        config: CampusMapViewports.mainMap,
      );
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('最低倍率足以讓地圖寬高都覆蓋直向手機畫面', () {
      const viewportSize = Size(390, 844);
      const edgeBuffer = 4.0;

      controller.prepareViewportForSize(viewportSize);

      final mapPixelSize = _projectedPixelSize(
        bounds: CampusMapViewports.mainMap.cameraBounds,
        zoom: controller.minZoom,
      );

      expect(
        mapPixelSize.width,
        greaterThanOrEqualTo(viewportSize.width + edgeBuffer * 2 - 0.001),
      );
      expect(
        mapPixelSize.height,
        greaterThanOrEqualTo(viewportSize.height + edgeBuffer * 2 - 0.001),
      );
    });

    test('安全鏡頭中心範圍會從圖片四邊向內縮', () {
      controller.prepareViewportForSize(const Size(390, 844));

      final imageBounds = CampusMapViewports.mainMap.cameraBounds;
      final safeBounds = controller.cameraTargetBounds.bounds!;

      expect(
        safeBounds.southwest.latitude,
        greaterThan(imageBounds.southwest.latitude),
      );
      expect(
        safeBounds.southwest.longitude,
        greaterThan(imageBounds.southwest.longitude),
      );
      expect(
        safeBounds.northeast.latitude,
        lessThan(imageBounds.northeast.latitude),
      );
      expect(
        safeBounds.northeast.longitude,
        lessThan(imageBounds.northeast.longitude),
      );
    });

    test('放大後安全鏡頭中心範圍會向圖片四邊擴張', () {
      controller.prepareViewportForSize(const Size(390, 844));
      final minimumZoom = controller.minZoom;
      final minimumZoomBounds = controller.cameraTargetBounds.bounds!;

      controller.handleCameraMove(
        CameraPosition(
          target: CampusMapViewports.mainMap.initialCenter,
          zoom: minimumZoom + 1,
        ),
        constrainToBounds: true,
      );

      expect(
        controller.commitPendingCameraTargetBounds(constrainToBounds: true),
        isTrue,
      );
      final zoomedInBounds = controller.cameraTargetBounds.bounds!;

      expect(
        zoomedInBounds.southwest.latitude,
        lessThan(minimumZoomBounds.southwest.latitude),
      );
      expect(
        zoomedInBounds.southwest.longitude,
        lessThan(minimumZoomBounds.southwest.longitude),
      );
      expect(
        zoomedInBounds.northeast.latitude,
        greaterThan(minimumZoomBounds.northeast.latitude),
      );
      expect(
        zoomedInBounds.northeast.longitude,
        greaterThan(minimumZoomBounds.northeast.longitude),
      );

      controller.handleCameraMove(
        CameraPosition(
          target: CampusMapViewports.mainMap.initialCenter,
          zoom: minimumZoom,
        ),
        constrainToBounds: true,
      );
      expect(
        controller.commitPendingCameraTargetBounds(constrainToBounds: true),
        isTrue,
      );

      final zoomedOutBounds = controller.cameraTargetBounds.bounds!;
      expect(zoomedOutBounds.southwest, minimumZoomBounds.southwest);
      expect(zoomedOutBounds.northeast, minimumZoomBounds.northeast);
    });

    test('程式定位期間不會被動態邊界修正打斷', () async {
      final mapController = _FakeMapLibreMapController();
      controller
        ..prepareViewportForSize(const Size(390, 844))
        ..attachMapController(mapController);

      final invalidCameraPosition = CameraPosition(
        target: const LatLng(0, 0),
        zoom: controller.playerFocusZoom,
      );
      mapController.onAnimateCamera = () {
        controller.handleCameraMove(
          invalidCameraPosition,
          constrainToBounds: true,
        );
      };

      await controller.returnToPlayer(CampusMapViewports.mainMap.initialCenter);
      expect(mapController.moveCameraCalls, 0);

      controller.handleCameraMove(
        invalidCameraPosition,
        constrainToBounds: true,
      );
      await Future<void>.delayed(Duration.zero);
      expect(mapController.moveCameraCalls, 1);
    });

    test('定位動畫發生例外後仍會解除動態修正鎖定', () async {
      final mapController = _FakeMapLibreMapController(
        animateCameraError: StateError('測試動畫失敗'),
      );
      controller
        ..prepareViewportForSize(const Size(390, 844))
        ..attachMapController(mapController);

      await expectLater(
        controller.returnToPlayer(CampusMapViewports.mainMap.initialCenter),
        throwsStateError,
      );

      controller.handleCameraMove(
        CameraPosition(
          target: const LatLng(0, 0),
          zoom: controller.playerFocusZoom,
        ),
        constrainToBounds: true,
      );
      await Future<void>.delayed(Duration.zero);
      expect(mapController.moveCameraCalls, 1);
    });

    test('最後定位校正使用立即移動，不會再播放第二次動畫', () async {
      final mapController = _FakeMapLibreMapController();
      controller
        ..prepareViewportForSize(const Size(390, 844))
        ..attachMapController(mapController);

      await controller.returnToPlayer(
        CampusMapViewports.mainMap.initialCenter,
        animated: false,
      );

      expect(mapController.animateCameraCalls, 0);
      expect(mapController.moveCameraCalls, 1);
    });

    test('防災地圖維持原本完整顯示圖片的模式', () {
      final emergencyController = CampusMapCameraController(
        config: CampusMapViewports.emergency,
      );

      emergencyController.prepareViewportForSize(const Size(844, 390));

      final imageBounds = CampusMapViewports.emergency.cameraBounds;
      final targetBounds = emergencyController.cameraTargetBounds.bounds!;
      expect(targetBounds.southwest, imageBounds.southwest);
      expect(targetBounds.northeast, imageBounds.northeast);
    });

    test('iOS 使用原生可見畫面邊界，避免重複內縮', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      try {
        controller.prepareViewportForSize(const Size(390, 844));

        final imageBounds = CampusMapViewports.mainMap.cameraBounds;
        final targetBounds = controller.cameraTargetBounds.bounds!;
        expect(targetBounds.southwest, imageBounds.southwest);
        expect(targetBounds.northeast, imageBounds.northeast);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}

class _FakeMapLibreMapController extends Fake implements MapLibreMapController {
  _FakeMapLibreMapController({this.animateCameraError});

  final Object? animateCameraError;
  VoidCallback? onAnimateCamera;
  int animateCameraCalls = 0;
  int moveCameraCalls = 0;

  @override
  Future<bool?> animateCamera(
    CameraUpdate cameraUpdate, {
    Duration? duration,
  }) async {
    animateCameraCalls++;
    final error = animateCameraError;
    if (error != null) throw error;
    onAnimateCamera?.call();
    return true;
  }

  @override
  Future<bool?> moveCamera(CameraUpdate cameraUpdate) async {
    moveCameraCalls++;
    return true;
  }
}

Size _projectedPixelSize({required LatLngBounds bounds, required double zoom}) {
  const tileSize = 512.0;
  final worldSize = tileSize * math.pow(2, zoom);
  final westX = (bounds.southwest.longitude + 180.0) / 360.0;
  final eastX = (bounds.northeast.longitude + 180.0) / 360.0;
  final northY = _latitudeToWorldY(bounds.northeast.latitude);
  final southY = _latitudeToWorldY(bounds.southwest.latitude);

  return Size(
    (eastX - westX).abs() * worldSize,
    (southY - northY).abs() * worldSize,
  );
}

double _latitudeToWorldY(double latitude) {
  final radians = latitude * math.pi / 180.0;
  return (1.0 -
          math.log(math.tan(radians) + 1.0 / math.cos(radians)) / math.pi) /
      2.0;
}
