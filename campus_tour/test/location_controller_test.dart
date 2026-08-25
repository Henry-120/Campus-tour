import 'dart:math' as math;

import 'package:campus_tour/controllers/location_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group('LocationOffsetTransformer', () {
    late LocationOffsetTransformer transformer;
    late Position origin;

    setUp(() {
      transformer = LocationOffsetTransformer(
        anchorLatitude: LocationTestConfig.anchorLatitude,
        anchorLongitude: LocationTestConfig.anchorLongitude,
      );
      origin = _position(latitude: 51.5074, longitude: -0.1278);
    });

    test('returns the real position before an origin is configured', () {
      final realPosition = _position(latitude: 35.0, longitude: 139.0);

      expect(transformer.transform(realPosition), same(realPosition));
    });

    test('maps the captured origin exactly to the campus anchor', () {
      transformer.setOrigin(origin);

      final shifted = transformer.transform(origin);

      expect(shifted.latitude, LocationTestConfig.anchorLatitude);
      expect(shifted.longitude, LocationTestConfig.anchorLongitude);
      expect(shifted.isMocked, isTrue);
      expect(shifted.timestamp, origin.timestamp);
      expect(shifted.accuracy, origin.accuracy);
      expect(shifted.heading, origin.heading);
      expect(shifted.speed, origin.speed);
    });

    test('preserves movement distance and direction at another latitude', () {
      transformer.setOrigin(origin);
      final moved = _position(latitude: 51.50755, longitude: -0.12745);

      final shifted = transformer.transform(moved);
      final realDistance = _distanceMeters(
        origin.latitude,
        origin.longitude,
        moved.latitude,
        moved.longitude,
      );
      final shiftedDistance = _distanceMeters(
        LocationTestConfig.anchorLatitude,
        LocationTestConfig.anchorLongitude,
        shifted.latitude,
        shifted.longitude,
      );
      final realBearing = _bearingDegrees(
        origin.latitude,
        origin.longitude,
        moved.latitude,
        moved.longitude,
      );
      final shiftedBearing = _bearingDegrees(
        LocationTestConfig.anchorLatitude,
        LocationTestConfig.anchorLongitude,
        shifted.latitude,
        shifted.longitude,
      );

      expect(shiftedDistance, closeTo(realDistance, 0.01));
      expect(_bearingDifference(shiftedBearing, realBearing), lessThan(0.01));
    });
  });
}

Position _position({required double latitude, required double longitude}) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime.utc(2026, 8, 10),
    accuracy: 3,
    altitude: 12,
    altitudeAccuracy: 2,
    heading: 45,
    headingAccuracy: 4,
    speed: 1.2,
    speedAccuracy: 0.3,
    floor: 2,
  );
}

double _distanceMeters(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
) {
  const earthRadiusMeters = 6371008.8;
  final startLat = _radians(startLatitude);
  final endLat = _radians(endLatitude);
  final deltaLat = endLat - startLat;
  final deltaLon = _radians(endLongitude - startLongitude);
  final haversine =
      math.pow(math.sin(deltaLat / 2), 2) +
      math.cos(startLat) *
          math.cos(endLat) *
          math.pow(math.sin(deltaLon / 2), 2);
  return earthRadiusMeters *
      2 *
      math.atan2(
        math.sqrt(haversine.toDouble()),
        math.sqrt(1 - haversine.toDouble()),
      );
}

double _bearingDegrees(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
) {
  final startLat = _radians(startLatitude);
  final endLat = _radians(endLatitude);
  final deltaLon = _radians(endLongitude - startLongitude);
  final y = math.sin(deltaLon) * math.cos(endLat);
  final x =
      math.cos(startLat) * math.sin(endLat) -
      math.sin(startLat) * math.cos(endLat) * math.cos(deltaLon);
  return math.atan2(y, x) * 180 / math.pi;
}

double _bearingDifference(double first, double second) {
  return ((first - second + 540) % 360 - 180).abs();
}

double _radians(double degrees) => degrees * math.pi / 180;
