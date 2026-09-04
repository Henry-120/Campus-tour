import 'package:maplibre_gl/maplibre_gl.dart';

class GeoreferencedImageConfig {
  const GeoreferencedImageConfig({
    required this.assetPath,
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
    required this.sourceId,
    required this.layerId,
  });

  final String assetPath;
  final LatLng topLeft;
  final LatLng topRight;
  final LatLng bottomRight;
  final LatLng bottomLeft;
  final String sourceId;
  final String layerId;
}

abstract final class CampusMapGeoreferencedImages {
  static const emergency = GeoreferencedImageConfig(
    assetPath: 'assets/images/campus_map_emergency.png',
    // 順序：
    // 左上 → 右上 → 右下 → 左下
    topLeft: LatLng(24.972389, 121.184551),
    topRight: LatLng(24.972389, 121.198360),
    bottomRight: LatLng(24.963905, 121.198360),
    bottomLeft: LatLng(24.963905, 121.184551),
    sourceId: 'emergency-campus-image-source',
    layerId: 'emergency-campus-image-layer',
  );
}
