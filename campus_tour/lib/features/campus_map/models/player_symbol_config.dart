class PlayerSymbolConfig {
  const PlayerSymbolConfig({required this.iconSize}) : assert(iconSize > 0);

  final double iconSize;
}

abstract final class CampusMapPlayerSymbolConfigs {
  static const emergency = PlayerSymbolConfig(iconSize: 0.6);

  static const mainMap = PlayerSymbolConfig(iconSize: 0.8);
}
