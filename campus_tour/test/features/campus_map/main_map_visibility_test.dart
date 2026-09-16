import 'package:campus_tour/features/campus_map/controllers/georeferenced_image_layer_controller.dart';
import 'package:campus_tour/features/campus_map/controllers/main_map_image_controller.dart';
import 'package:campus_tour/features/campus_map/models/georeferenced_image_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

void main() {
  group('MainMapImageController 地圖顯示狀態', () {
    late _FakeImageLayerController campusLayer;
    late _FakeImageLayerController forestLayer;
    late MainMapImageController imageController;
    late MapLibreMapController mapController;

    setUp(() {
      campusLayer = _FakeImageLayerController();
      forestLayer = _FakeImageLayerController();
      imageController = MainMapImageController(
        campusController: campusLayer,
        forestController: forestLayer,
      );
      mapController = _FakeMapLibreMapController();
    });

    test('校外載入 style 時兩張地圖都維持隱藏', () async {
      await imageController.addToMap(mapController, isVisible: false);

      expect(imageController.isVisible, isFalse);
      expect(campusLayer.visible, isFalse);
      expect(forestLayer.visible, isFalse);
    });

    test('回到校內只顯示目前選取的地圖', () async {
      await imageController.addToMap(mapController, isVisible: false);
      await imageController.setVisible(mapController, true);

      expect(campusLayer.visible, isTrue);
      expect(forestLayer.visible, isFalse);

      await imageController.switchTo(mapController, MainMapKind.forest);

      expect(campusLayer.visible, isFalse);
      expect(forestLayer.visible, isTrue);
    });

    test('校外切換地圖種類不會讓圖片重新出現', () async {
      await imageController.addToMap(mapController, isVisible: true);
      await imageController.setVisible(mapController, false);
      await imageController.switchTo(mapController, MainMapKind.forest);

      expect(campusLayer.visible, isFalse);
      expect(forestLayer.visible, isFalse);
    });
  });
}

class _FakeImageLayerController extends GeoreferencedImageLayerController {
  _FakeImageLayerController()
    : super(config: CampusMapGeoreferencedImages.mainCampus);

  bool? visible;

  @override
  Future<void> addToMap(MapLibreMapController controller) async {}

  @override
  Future<void> setVisible(
    MapLibreMapController controller,
    bool visible,
  ) async {
    this.visible = visible;
  }
}

class _FakeMapLibreMapController extends Fake
    implements MapLibreMapController {}
