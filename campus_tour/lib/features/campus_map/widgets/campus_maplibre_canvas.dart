import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:campus_tour/features/campus_map/styles/maplibre_styles.dart';
import 'package:campus_tour/features/campus_map/controllers/campus_map_camera_controller.dart';
import 'package:campus_tour/features/campus_map/models/map_viewport_config.dart';

class EmergencyCampusMaplibreCanvas extends StatelessWidget {
  const EmergencyCampusMaplibreCanvas({
    super.key,
    required this.cameraController,
    required MapCreatedCallback onMapCreated,
    required Future<void> Function() onStyleLoaded,
  }) : _onMapCreated = onMapCreated,
       _onStyleLoaded = onStyleLoaded;
  final CampusMapCameraController cameraController;
  final MapCreatedCallback _onMapCreated;
  final Future<void> Function() _onStyleLoaded;
  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: EmergencyMaplibreStyles.blankStyle,
      initialCameraPosition: cameraController.getInitialCameraPosition(
        CampusMapViewports.emergency.initialCenter,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,

      // 玩家定位
      myLocationEnabled: false,
      myLocationTrackingMode: MyLocationTrackingMode.none,

      compassEnabled: true,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: false,
      cameraTargetBounds: cameraController.cameraTargetBounds,
      minMaxZoomPreference: cameraController.zoomPreference,
      annotationOrder: const [
        AnnotationType.fill,
        AnnotationType.line,
        AnnotationType.circle,
        AnnotationType.symbol,
      ],
    );
  }
}

class MainGameCampusMaplibreCanvas extends StatelessWidget {
  const MainGameCampusMaplibreCanvas({
    super.key,
    required this.cameraController,
    required this.constrainCamera,
    required MapCreatedCallback onMapCreated,
    required Future<void> Function() onStyleLoaded,
    required OnCameraMoveCallback onCameraMove,
    required VoidCallback onCameraIdle,
  }) : _onMapCreated = onMapCreated,
       _onStyleLoaded = onStyleLoaded,
       _onCameraMove = onCameraMove,
       _onCameraIdle = onCameraIdle;
  final CampusMapCameraController cameraController;

  /// 校內顯示地圖時限制鏡頭；校外只剩背景時解除限制，讓鏡頭繼續跟隨玩家。
  final bool constrainCamera;
  final MapCreatedCallback _onMapCreated;
  final Future<void> Function() _onStyleLoaded;
  final OnCameraMoveCallback _onCameraMove;
  final VoidCallback _onCameraIdle;
  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: MainGameMaplibreStyles.blankStyle,
      initialCameraPosition: cameraController.getInitialCameraPosition(
        CampusMapViewports.mainMap.initialCenter,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,
      trackCameraPosition: true,
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,

      // 玩家定位
      myLocationEnabled: false,
      myLocationTrackingMode: MyLocationTrackingMode.none,

      compassEnabled: true,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: false,
      cameraTargetBounds: constrainCamera
          ? cameraController.cameraTargetBounds
          : CameraTargetBounds.unbounded,
      minMaxZoomPreference: cameraController.zoomPreference,
      annotationOrder: const [
        AnnotationType.fill,
        AnnotationType.line,
        AnnotationType.circle,
        AnnotationType.symbol,
      ],
    );
  }
}
