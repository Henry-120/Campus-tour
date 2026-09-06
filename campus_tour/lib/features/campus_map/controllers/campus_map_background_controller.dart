import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:campus_tour/features/campus_map/models/map_background_config.dart';
import 'package:flutter/services.dart';

class CampusMapBackgroundController {
  CampusMapBackgroundController({required CampusMapBackgroundConfig config})
    : layerId = config.layerId,
      images = config.images;
  final String layerId;
  final Map<CampusMapBackgroundKind, CampusMapBackgroundImageConfig> images;

  final Map<CampusMapBackgroundKind, Uint8List> _preparedImageBytes = {};
  bool _preparedImageBytesListReady = false;
  bool _addedToCurrentStyle = false;

  Future<void> addToMap(
    MapLibreMapController controller,
    CampusMapBackgroundKind kind,
  ) async {
    if (_addedToCurrentStyle) return;
    if (!_preparedImageBytesListReady) {
      for (final entry in images.entries) {
        final kind = entry.key;
        final imageConfig = entry.value;

        final byteData = await rootBundle.load(imageConfig.assetPath);

        _preparedImageBytes[kind] = byteData.buffer.asUint8List();
      }
      _preparedImageBytesListReady = true;
    }
    for (final entry in images.entries) {
      final kind = entry.key;
      final imageConfig = entry.value;
      final imageBytes = _preparedImageBytes[kind];

      if (imageBytes == null) {
        throw StateError('背景圖片尚未完成載入：$kind');
      }

      await controller.addImage(imageConfig.imageId, imageBytes);
    }

    await _addBackgroundLayer(controller, kind);
    _addedToCurrentStyle = true;
  }

  Future<void> _addBackgroundLayer(
    MapLibreMapController controller,
    CampusMapBackgroundKind kind,
  ) async {
    final imageConfig = images[kind];
    if (imageConfig == null) {
      throw StateError('找不到指定的背景圖片設定：$kind');
    }
    final layerIds = (await controller.getLayerIds()).cast<String>();

    final String? belowLayerId = layerIds.isEmpty ? null : layerIds.first;
    await controller.addBackgroundLayer(
      layerId,
      BackgroundLayerProperties(
        backgroundPattern: imageConfig.imageId,
        backgroundOpacity: 1.0,
        visibility: 'visible',
      ),
      belowLayerId: belowLayerId,
    );
  }

  Future<void> setBackground(
    MapLibreMapController controller,
    CampusMapBackgroundKind kind,
  ) async {
    if (!_addedToCurrentStyle) return;
    final imageConfig = images[kind];
    if (imageConfig == null) {
      throw StateError('找不到背景設定：$kind');
    }
    await controller.setLayerProperties(
      layerId,
      BackgroundLayerProperties(
        backgroundPattern: imageConfig.imageId,
        backgroundOpacity: 1.0,
        visibility: 'visible',
      ),
    );
  }

  void resetAfterStyleReload() {
    _addedToCurrentStyle = false;
  }
}
