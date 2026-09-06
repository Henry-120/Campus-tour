enum CampusMapBackgroundKind { day, night }

class CampusMapBackgroundImageConfig {
  const CampusMapBackgroundImageConfig({
    required this.assetPath,
    required this.imageId,
  });

  final String assetPath;
  final String imageId;
}

class CampusMapBackgroundConfig {
  const CampusMapBackgroundConfig({
    required this.layerId,
    required this.images,
  });

  final String layerId;

  final Map<CampusMapBackgroundKind, CampusMapBackgroundImageConfig> images;
}

abstract final class CampusMapBackgroundConfigs {
  static const mainGameMap = CampusMapBackgroundConfig(
    layerId: 'main-map-background-layer',
    images: {
      CampusMapBackgroundKind.day: CampusMapBackgroundImageConfig(
        assetPath: 'assets/images/cute_grass1024.png',
        imageId: 'main-map-background-day-image',
      ),
      CampusMapBackgroundKind.night: CampusMapBackgroundImageConfig(
        assetPath: 'assets/images/cute_star1024.png',
        imageId: 'main-map-background-night-image',
      ),
    },
  );
}
