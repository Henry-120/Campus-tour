import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Controls whether the location-offset test UI is compiled into the app.
///
/// Debug builds show the controls by default. Store test builds must opt in with
/// `--dart-define=SHOW_LOCATION_OFFSET_CONTROLS=true`. Production release builds
/// omit the flag, so stale runtime state can never turn the feature on.
abstract final class LocationTestConfig {
  static const bool showControls = bool.fromEnvironment(
    'SHOW_LOCATION_OFFSET_CONTROLS',
    defaultValue: kDebugMode,
  );

  /// Source-only escape hatch for internal development.
  ///
  /// Keep this false for every distributed build. When true, the first real GPS
  /// fix becomes the origin and offset mode starts without exposing any UI.
  static const bool forceEnabled = false;

  static const double anchorLatitude = 24.967731;
  static const double anchorLongitude = 121.193638;

  static const bool capabilityEnabled = showControls || forceEnabled;
}

enum AppLocationStatus {
  idle,
  requestingPermission,
  ready,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

@immutable
class AppLocationState {
  const AppLocationState({
    required this.status,
    this.position,
    this.errorMessage,
  });

  final AppLocationStatus status;
  final Position? position;
  final String? errorMessage;
}

/// Translates real GPS movement to the same distance and bearing from a fixed
/// campus anchor.
///
/// The transform uses a spherical destination calculation instead of adding raw
/// latitude/longitude deltas. This keeps east/west scale correct even when a
/// tester is far away from the campus latitude.
class LocationOffsetTransformer {
  LocationOffsetTransformer({
    required this.anchorLatitude,
    required this.anchorLongitude,
  });

  static const double _earthRadiusMeters = 6371008.8;

  final double anchorLatitude;
  final double anchorLongitude;
  Position? _origin;

  Position? get origin => _origin;

  void setOrigin(Position position) {
    _origin = position;
  }

  void clear() {
    _origin = null;
  }

  Position transform(Position realPosition) {
    final origin = _origin;
    if (origin == null) return realPosition;

    final distanceMeters = _distanceBetween(
      origin.latitude,
      origin.longitude,
      realPosition.latitude,
      realPosition.longitude,
    );

    late final ({double latitude, double longitude}) shifted;
    if (distanceMeters < 0.001) {
      shifted = (latitude: anchorLatitude, longitude: anchorLongitude);
    } else {
      final bearingDegrees = _bearingBetween(
        origin.latitude,
        origin.longitude,
        realPosition.latitude,
        realPosition.longitude,
      );
      shifted = _destinationPoint(
        latitude: anchorLatitude,
        longitude: anchorLongitude,
        distanceMeters: distanceMeters,
        bearingDegrees: bearingDegrees,
      );
    }

    return Position(
      latitude: shifted.latitude,
      longitude: shifted.longitude,
      timestamp: realPosition.timestamp,
      accuracy: realPosition.accuracy,
      altitude: realPosition.altitude,
      altitudeAccuracy: realPosition.altitudeAccuracy,
      heading: realPosition.heading,
      headingAccuracy: realPosition.headingAccuracy,
      speed: realPosition.speed,
      speedAccuracy: realPosition.speedAccuracy,
      floor: realPosition.floor,
      isMocked: true,
    );
  }

  static double _distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final startLat = _toRadians(startLatitude);
    final endLat = _toRadians(endLatitude);
    final deltaLat = endLat - startLat;
    final deltaLon = _toRadians(endLongitude - startLongitude);
    final haversine =
        math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(startLat) *
            math.cos(endLat) *
            math.pow(math.sin(deltaLon / 2), 2);
    final safeHaversine = haversine.toDouble().clamp(0.0, 1.0);
    final angularDistance =
        2 * math.atan2(math.sqrt(safeHaversine), math.sqrt(1 - safeHaversine));
    return _earthRadiusMeters * angularDistance;
  }

  static double _bearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final startLat = _toRadians(startLatitude);
    final endLat = _toRadians(endLatitude);
    final deltaLon = _toRadians(endLongitude - startLongitude);
    final y = math.sin(deltaLon) * math.cos(endLat);
    final x =
        math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(deltaLon);
    return _toDegrees(math.atan2(y, x));
  }

  static ({double latitude, double longitude}) _destinationPoint({
    required double latitude,
    required double longitude,
    required double distanceMeters,
    required double bearingDegrees,
  }) {
    final angularDistance = distanceMeters / _earthRadiusMeters;
    final bearing = _toRadians(bearingDegrees);
    final startLat = _toRadians(latitude);
    final startLon = _toRadians(longitude);

    final endLat = math.asin(
      math.sin(startLat) * math.cos(angularDistance) +
          math.cos(startLat) * math.sin(angularDistance) * math.cos(bearing),
    );
    final endLon =
        startLon +
        math.atan2(
          math.sin(bearing) * math.sin(angularDistance) * math.cos(startLat),
          math.cos(angularDistance) - math.sin(startLat) * math.sin(endLat),
        );
    final normalizedLon = (endLon + 3 * math.pi) % (2 * math.pi) - math.pi;

    return (latitude: _toDegrees(endLat), longitude: _toDegrees(normalizedLon));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  static double _toDegrees(double radians) => radians * 180 / math.pi;
}

/// The app's single owner of location permission, GPS reads, streaming state,
/// geometry calculations, and test-coordinate transformation.
class LocationController extends GetxController {
  LocationController()
    : _offsetTransformer = LocationOffsetTransformer(
        anchorLatitude: LocationTestConfig.anchorLatitude,
        anchorLongitude: LocationTestConfig.anchorLongitude,
      );

  final LocationOffsetTransformer _offsetTransformer;
  final Rx<AppLocationState> state = const AppLocationState(
    status: AppLocationStatus.idle,
  ).obs;
  final RxBool isTestOffsetEnabled = LocationTestConfig.forceEnabled.obs;

  StreamSubscription<Position>? _positionSubscription;
  Future<void>? _startFuture;
  Position? _latestRealPosition;

  Position? get position => state.value.position;

  bool get hasPosition => position != null;

  Future<void> startTracking() {
    if (_positionSubscription != null) return Future<void>.value();

    final pendingStart = _startFuture;
    if (pendingStart != null) return pendingStart;

    final start = _startTrackingInternal();
    _startFuture = start;
    return start.whenComplete(() {
      if (identical(_startFuture, start)) _startFuture = null;
    });
  }

  Future<void> _startTrackingInternal() async {
    if (!await _ensureLocationAccess()) return;

    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
      _publishRealPosition(initialPosition);
    } catch (error) {
      _setError(error);
    }

    if (_positionSubscription != null) return;

    try {
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              distanceFilter: 1,
            ),
          ).listen(
            _publishRealPosition,
            onError: _setError,
            onDone: () => _positionSubscription = null,
          );
    } catch (error) {
      _setError(error);
    }
  }

  Future<bool> _ensureLocationAccess() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setState(status: AppLocationStatus.serviceDisabled);
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        _setState(status: AppLocationStatus.requestingPermission);
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _setState(status: AppLocationStatus.permissionDenied);
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        _setState(status: AppLocationStatus.permissionDeniedForever);
        return false;
      }

      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  /// Returns the same transformed position used by every map.
  Future<Position?> getCurrentPosition({bool fresh = false}) async {
    await startTracking();

    if (!fresh && position != null) return position;
    if (!await _ensureLocationAccess()) return null;

    try {
      final realPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
      _publishRealPosition(realPosition);
      return position;
    } catch (error) {
      _setError(error);
      return position;
    }
  }

  /// Captures the device's current real position as the test origin.
  Future<bool> enableTestOffset() async {
    if (!LocationTestConfig.capabilityEnabled) return false;

    await startTracking();
    if (!await _ensureLocationAccess()) return false;

    Position? realPosition;
    try {
      realPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
    } catch (error) {
      _setError(error);
      realPosition = _latestRealPosition;
    }

    if (realPosition == null) return false;

    _offsetTransformer.setOrigin(realPosition);
    isTestOffsetEnabled.value = true;
    _publishRealPosition(realPosition);
    return true;
  }

  void disableTestOffset() {
    if (LocationTestConfig.forceEnabled) return;

    isTestOffsetEnabled.value = false;
    _offsetTransformer.clear();
    final realPosition = _latestRealPosition;
    if (realPosition != null) _publishRealPosition(realPosition);
  }

  void _publishRealPosition(Position realPosition) {
    _latestRealPosition = realPosition;

    if (LocationTestConfig.forceEnabled && _offsetTransformer.origin == null) {
      _offsetTransformer.setOrigin(realPosition);
    }

    final exposedPosition = isTestOffsetEnabled.value
        ? _offsetTransformer.transform(realPosition)
        : realPosition;
    state.value = AppLocationState(
      status: AppLocationStatus.ready,
      position: exposedPosition,
    );
  }

  void _setError(Object error) {
    _setState(status: AppLocationStatus.error, errorMessage: '$error');
  }

  void _setState({required AppLocationStatus status, String? errorMessage}) {
    state.value = AppLocationState(
      status: status,
      position: state.value.position,
      errorMessage: errorMessage,
    );
  }

  static double distanceBetweenPositions(Position first, Position second) {
    return distanceBetweenCoordinates(
      first.latitude,
      first.longitude,
      second.latitude,
      second.longitude,
    );
  }

  static double distanceBetweenCoordinates(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  static double bearingBetweenCoordinates(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    super.onClose();
  }
}
