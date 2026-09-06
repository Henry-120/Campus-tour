import 'package:maplibre_gl/maplibre_gl.dart';

class MapViewportConfig {
  const MapViewportConfig({
    required this.initialCenter,
    required this.cameraBounds,
    required this.fallbackMinZoom,
    required this.maxZoom,
    required this.padding,
  });

  final LatLng initialCenter;
  final LatLngBounds cameraBounds;
  final double fallbackMinZoom;
  final double maxZoom;
  final double padding;
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
  );
}
