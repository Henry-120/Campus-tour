import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:campus_tour/features/campus_map/models/georeferenced_image_config.dart';

class GeoreferencedImageLayerController {
  GeoreferencedImageLayerController({required GeoreferencedImageConfig config})
    : assetPath = config.assetPath,
      topLeft = config.topLeft,
      topRight = config.topRight,
      bottomRight = config.bottomRight,
      bottomLeft = config.bottomLeft,
      sourceId = config.sourceId,
      layerId = config.layerId;

  final String assetPath;

  final LatLng topLeft;
  final LatLng topRight;
  final LatLng bottomRight;
  final LatLng bottomLeft;

  final String sourceId;
  final String layerId;

  bool _addedToCurrentStyle = false;
  Uint8List? _preparedImageBytes;

  // MapLibre uploads image sources as GPU textures. The original campus map is
  // 7734 px wide, which exceeds the texture limit on some iOS devices.
  static const int _maxTextureWidth = 4096;

  Future<void> addToMap(MapLibreMapController controller) async {
    if (_addedToCurrentStyle) return;

    if (_preparedImageBytes == null) {
      final byteData = await rootBundle.load(assetPath);
      _preparedImageBytes = await _resizeForMapTexture(
        byteData.buffer.asUint8List(),
      );
    }
    final imageBytes = _preparedImageBytes!;
    final imageCoordinates = LatLngQuad(
      topLeft: topLeft,
      topRight: topRight,
      bottomRight: bottomRight,
      bottomLeft: bottomLeft,
    );

    await controller.addImageSource(sourceId, imageBytes, imageCoordinates);

    await _addImageLayerBelowSymbols(controller);
    _addedToCurrentStyle = true;
  }

  Future<Uint8List> _resizeForMapTexture(Uint8List sourceBytes) async {
    final codec = await ui.instantiateImageCodec(
      sourceBytes,
      targetWidth: _maxTextureWidth,
      allowUpscaling: false,
    );
    final frame = await codec.getNextFrame();

    try {
      final resizedBytes = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (resizedBytes == null) {
        throw StateError('無法轉換地圖圖片');
      }
      return resizedBytes.buffer.asUint8List();
    } finally {
      frame.image.dispose();
      codec.dispose();
    }
  }

  Future<void> _addImageLayerBelowSymbols(
    MapLibreMapController controller,
  ) async {
    final symbolLayerIds =
        controller.symbolManager?.layerIds ?? const <String>[];

    if (symbolLayerIds.isNotEmpty) {
      await controller.addImageLayerBelow(
        layerId,
        sourceId,
        symbolLayerIds.first,
      );
      return;
    }

    await controller.addImageLayer(layerId, sourceId);
  }

  Future<void> removeFromMap(MapLibreMapController controller) async {
    if (!_addedToCurrentStyle) return;

    await controller.removeLayer(layerId);
    await controller.removeSource(sourceId);

    _addedToCurrentStyle = false;
  }

  Future<void> setVisible(
    MapLibreMapController controller,
    bool visible,
  ) async {
    if (!_addedToCurrentStyle) return;
    await controller.setLayerVisibility(layerId, visible);
  }

  //預留更換用
  void resetAfterStyleReload() {
    _addedToCurrentStyle = false;
  }
}
