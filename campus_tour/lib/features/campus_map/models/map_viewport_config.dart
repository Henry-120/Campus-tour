import 'package:maplibre_gl/maplibre_gl.dart';

class MapViewportConfig {
  const MapViewportConfig({
    required this.initialCenter,
    required this.cameraBounds,
    required this.fallbackMinZoom,
    required this.maxZoom,
    required this.padding,
    required this.playerFocusZoom,
    this.keepViewportInsideBounds = false,
    this.edgeBufferPixels = 0,
  });

  final LatLng initialCenter;
  final LatLngBounds cameraBounds;
  final double fallbackMinZoom;
  final double maxZoom;
  final double padding;
  final double playerFocusZoom;

  /// 是否讓整個手機畫面永遠落在地圖圖片範圍內，而不只是限制鏡頭中心。
  final bool keepViewportInsideBounds;

  /// 額外保留的畫面內縮像素，避免浮點誤差造成地圖邊緣露出細縫。
  final double edgeBufferPixels;
}

abstract final class CampusMapViewports {
  static final emergency = MapViewportConfig(
    initialCenter: LatLng(24.968147, 121.191456),
    cameraBounds: LatLngBounds(
      southwest: LatLng(24.963905, 121.184551),
      northeast: LatLng(24.972389, 121.198360),
    ),
    fallbackMinZoom: 16,
    maxZoom: 20,
    padding: 2,
    playerFocusZoom: 18,
  );
  static final mainMap = MapViewportConfig(
    initialCenter: LatLng(24.968418, 121.191243),
    cameraBounds: LatLngBounds(
      southwest: LatLng(24.965184, 121.185000),
      northeast: LatLng(24.971653, 121.197487),
    ),
    fallbackMinZoom: 16,
    maxZoom: 20,
    padding: 2,
    playerFocusZoom: 17,
    keepViewportInsideBounds: true,
    edgeBufferPixels: 4,
  );
}
