import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'dart:math' as math;
import 'package:campus_tour/features/campus_map/models/map_viewport_config.dart';

class CampusMapCameraController {
  CampusMapCameraController({required MapViewportConfig config})
    : cameraBounds = config.cameraBounds,
      maxZoom = config.maxZoom,
      padding = config.padding,
      fallbackMinZoom = config.fallbackMinZoom,
      playerFocusZoom = config.playerFocusZoom,
      _minZoom = config.fallbackMinZoom;

  final LatLngBounds cameraBounds;
  final double maxZoom;
  final double padding;
  final double fallbackMinZoom;
  final double playerFocusZoom;

  MapLibreMapController? _mapController;

  double _minZoom;
  bool _isViewportReady = false;

  double get minZoom => _minZoom;

  bool get isViewportReady => _isViewportReady;

  MinMaxZoomPreference get zoomPreference {
    return MinMaxZoomPreference(_minZoom, maxZoom);
  }

  CameraTargetBounds get cameraTargetBounds {
    return CameraTargetBounds(cameraBounds);
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
    final screenSize = MediaQuery.of(context).size;

    _minZoom = _calculateFitMinZoom(
      screenSize: screenSize,
      bounds: cameraBounds,
      padding: padding,
    );

    _isViewportReady = true;
  }

  Future<void> fitCameraBounds() async {
    final controller = _mapController;
    if (controller == null) return;

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

  Future<void> moveTo(LatLng target, {double zoom = 18}) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  Future<void> followPlayer(LatLng position) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  Future<void> returnToPlayer(LatLng position) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: playerFocusZoom,
          bearing: 0,
          tilt: 0,
        ),
      ),
    );
  }

  double _calculateFitMinZoom({
    required Size screenSize,
    required LatLngBounds bounds,
    required double padding,
  }) {
    final usableWidth = screenSize.width - padding * 2;
    final usableHeight = screenSize.height - padding * 2;

    if (usableWidth <= 0 || usableHeight <= 0) {
      return fallbackMinZoom;
    }

    const double tileSize = 512;

    double lngToX(double lng) {
      return (lng + 180.0) / 360.0;
    }

    double latToY(double lat) {
      final latRad = lat * math.pi / 180.0;

      return (1.0 -
              math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
          2.0;
    }

    final west = bounds.southwest.longitude;
    final east = bounds.northeast.longitude;
    final south = bounds.southwest.latitude;
    final north = bounds.northeast.latitude;

    final x1 = lngToX(west);
    final x2 = lngToX(east);
    final y1 = latToY(north);
    final y2 = latToY(south);

    final lngFraction = (x2 - x1).abs();
    final latFraction = (y2 - y1).abs();

    if (lngFraction <= 0 || latFraction <= 0) {
      return fallbackMinZoom;
    }

    final zoomX = math.log(usableWidth / tileSize / lngFraction) / math.ln2;
    final zoomY = math.log(usableHeight / tileSize / latFraction) / math.ln2;

    final fitZoom = math.min(zoomX, zoomY);

    return fitZoom - 0.05;
  }
}
