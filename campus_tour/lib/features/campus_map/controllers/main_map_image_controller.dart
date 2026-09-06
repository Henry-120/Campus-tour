import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:campus_tour/features/campus_map/models/georeferenced_image_config.dart';
import 'package:campus_tour/features/campus_map/controllers/georeferenced_image_layer_controller.dart';

enum MainMapKind { campus, forest }

class MainMapImageController {
  MainMapImageController()
    : _campus = GeoreferencedImageLayerController(
        config: CampusMapGeoreferencedImages.mainCampus,
      ),
      _forest = GeoreferencedImageLayerController(
        config: CampusMapGeoreferencedImages.mainForest,
      );

  final GeoreferencedImageLayerController _campus;
  final GeoreferencedImageLayerController _forest;

  MainMapKind _selectedKind = MainMapKind.campus;

  GeoreferencedImageLayerController get _selectedController {
    return switch (_selectedKind) {
      MainMapKind.campus => _campus,
      MainMapKind.forest => _forest,
    };
  }

  Future<void> addToMap(MapLibreMapController controller) async {
    await _campus.addToMap(controller);
    await _forest.addToMap(controller);
    await _applyVisibility(controller);
  }

  Future<void> _applyVisibility(MapLibreMapController controller) async {
    await _campus.setVisible(controller, _selectedKind == MainMapKind.campus);

    await _forest.setVisible(controller, _selectedKind == MainMapKind.forest);
  }

  Future<void> switchTo(
    MapLibreMapController controller,
    MainMapKind kind,
  ) async {
    if (kind == _selectedKind) return;

    final previousController = _selectedController;
    _selectedKind = kind;

    await previousController.setVisible(controller, false);
    await _selectedController.setVisible(controller, true);
  }

  void resetAfterStyleReload() {
    _campus.resetAfterStyleReload();
    _forest.resetAfterStyleReload();
  }
}
