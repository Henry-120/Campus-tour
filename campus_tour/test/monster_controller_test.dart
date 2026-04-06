import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/models/monster_model.dart';
import 'package:campus_tour/services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';


void main() {
  test("updateNearbyMonsters 應該更新附近怪物清單", () async {
    final controller = MonsterController();

    final fakePosition = Position(
      latitude: 24.9681,
      longitude: 121.1919,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      floor: null,
      isMocked: false,
    );

    await controller.updateNearbyMonsters(fakePosition);

    expect(controller.nearbyMonsters.isNotEmpty, true);
    expect(controller.nearbyMonsters.first.name, "測試怪物");
  });
}
