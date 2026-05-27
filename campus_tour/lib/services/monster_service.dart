import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MonsterService {
  static const double nearbyRangeMeters = 50;

  bool isWithinRange(Position user, GeoPoint monsterLocation) {
    final distance = Geolocator.distanceBetween(
      user.latitude,
      user.longitude,
      monsterLocation.latitude,
      monsterLocation.longitude,
    );

    return distance < nearbyRangeMeters;
  }
}
