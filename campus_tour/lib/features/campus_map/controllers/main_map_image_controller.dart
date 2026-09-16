import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:campus_tour/features/campus_map/models/georeferenced_image_config.dart';
import 'package:campus_tour/features/campus_map/controllers/georeferenced_image_layer_controller.dart';

enum MainMapKind { campus, forest }

class MainMapImageController {
  MainMapImageController({
    GeoreferencedImageLayerController? campusController,
    GeoreferencedImageLayerController? forestController,
  }) : _campus =
           campusController ??
           GeoreferencedImageLayerController(
             config: CampusMapGeoreferencedImages.mainCampus,
           ),
       _forest =
           forestController ??
           GeoreferencedImageLayerController(
             config: CampusMapGeoreferencedImages.mainForest,
           );

  final GeoreferencedImageLayerController _campus;
  final GeoreferencedImageLayerController _forest;

  MainMapKind _selectedKind = MainMapKind.campus;
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  GeoreferencedImageLayerController get _selectedController {
    return switch (_selectedKind) {
      MainMapKind.campus => _campus,
      MainMapKind.forest => _forest,
    };
  }

  Future<void> addToMap(
    MapLibreMapController controller, {
    required bool isVisible,
  }) async {
    // Style 重載時先記住最新校內／校外狀態，避免地圖圖層短暫閃現。
    _isVisible = isVisible;
    await _campus.addToMap(controller);
    await _campus.setVisible(
      controller,
      _isVisible && _selectedKind == MainMapKind.campus,
    );

    await _forest.addToMap(controller);
    await _forest.setVisible(
      controller,
      _isVisible && _selectedKind == MainMapKind.forest,
    );
  }

  Future<void> _applyVisibility(MapLibreMapController controller) async {
    await _campus.setVisible(
      controller,
      _isVisible && _selectedKind == MainMapKind.campus,
    );

    await _forest.setVisible(
      controller,
      _isVisible && _selectedKind == MainMapKind.forest,
    );
  }

  /// 校外時只隱藏校園／森林地圖圖片，底下的日夜背景仍保持顯示。
  Future<void> setVisible(
    MapLibreMapController controller,
    bool visible,
  ) async {
    _isVisible = visible;
    await _applyVisibility(controller);
  }

  Future<void> switchTo(
    MapLibreMapController controller,
    MainMapKind kind,
  ) async {
    if (kind == _selectedKind) return;

    final previousController = _selectedController;
    _selectedKind = kind;

    await previousController.setVisible(controller, false);
    await _selectedController.setVisible(controller, _isVisible);
  }

  void resetAfterStyleReload() {
    _campus.resetAfterStyleReload();
    _forest.resetAfterStyleReload();
  }
}
