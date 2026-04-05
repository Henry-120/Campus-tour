import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MonsterService{
  bool isWithinRange(Position user, GeoPoint monsterLocation) {
    // 簡單距離判斷，可用 haversine formula
    final distance = _calculateDistance(user.latitude, user.longitude,
        monsterLocation.latitude, monsterLocation.longitude);

    return distance < 20; // 20 公尺內顯示
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000; // 公尺
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
                (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}