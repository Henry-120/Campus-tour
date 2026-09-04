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
      southwest: LatLng(24.96, 121.18),
      northeast: LatLng(25.00, 121.22),
    ),
    fallbackMinZoom: 16,
    maxZoom: 20,
    padding: 2,
  );
  // static final main = MapViewportConfig(...);
}

abstract class MainMapViewport {}
