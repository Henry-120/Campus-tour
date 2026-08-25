import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_tour/controllers/location_controller.dart';
import 'package:geolocator/geolocator.dart';

class MonsterService {
  static const double nearbyRangeMeters = 50;

  bool isWithinRange(Position user, GeoPoint monsterLocation) {
    final distance = LocationController.distanceBetweenCoordinates(
      user.latitude,
      user.longitude,
      monsterLocation.latitude,
      monsterLocation.longitude,
    );

    return distance < nearbyRangeMeters;
  }
}
