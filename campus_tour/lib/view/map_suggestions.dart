import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class MapSuggestionsVariables {
  // [L-01]
  // ignore: constant_identifier_names
  static const String map_path = 'assets/images/cute_map_real.png';

  // [L-02]
  // ignore: constant_identifier_names
  static const String position_char = 'assets/images/component/squirrel.png';

  // [L-03]
  static const Size mapImageSize = Size(2744, 1568);

  // [L-04]
  static const double southwestLatitude = 24.965184;

  // [L-05]
  static const double southwestLongitude = 121.185000;

  // [L-06]
  static const double northeastLatitude = 24.971653;

  // [L-07]
  static const double northeastLongitude = 121.197487;

  // [L-08]
  static const double markerSize = 56;

  // [L-09]
  static const double locationUpdateMeters = 2;

  static const int step = 10;
}

class MapSuggestionsPage extends StatefulWidget {
  const MapSuggestionsPage({super.key});

  @override
  State<MapSuggestionsPage> createState() => _MapSuggestionsPageState();
}

class _MapSuggestionsPageState extends State<MapSuggestionsPage> {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isLocationReady = false;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    // [L-10]
    _forceLandscape();
    // [L-11]
    _startLocationTracking();
  }

  @override
  void dispose() {
    // [L-12]
    _positionSubscription?.cancel();
    // [L-13]
    _restoreOrientation();
    super.dispose();
  }

  Future<void> _forceLandscape() async {
    // [L-14]
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _restoreOrientation() async {
    // [L-15]
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  Future<void> _startLocationTracking() async {
    // [L-16]
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _isLocationReady = false;
        _locationMessage = 'GPS 尚未開啟';
      });
      return;
    }

    // [L-17]
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // [L-18]
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _isLocationReady = false;
        _locationMessage = '尚未取得定位權限';
      });
      return;
    }

    // [L-19]
    final initialPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    if (!mounted) return;
    // [L-20]
    setState(() {
      _currentPosition = initialPosition;
      _isLocationReady = true;
      _locationMessage = null;
    });

    // [L-21]
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen(_handlePositionUpdate);
  }

  void _handlePositionUpdate(Position position) {
    // [L-22]
    final previousPosition = _currentPosition;
    final shouldUpdate =
        previousPosition == null ||
        Geolocator.distanceBetween(
              previousPosition.latitude,
              previousPosition.longitude,
              position.latitude,
              position.longitude,
            ) >=
            MapSuggestionsVariables.locationUpdateMeters;

    // [L-23]
    if (!shouldUpdate || !mounted) return;

    // [L-24]
    setState(() {
      _currentPosition = position;
      _isLocationReady = true;
      _locationMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // [L-25]
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // [L-26]
            final fittedMap = calculateContainedMapRect(
              containerSize: constraints.biggest,
              imageSize: MapSuggestionsVariables.mapImageSize,
            );

            // [L-27]
            final markerOffset = _currentPosition == null
                ? null
                : gpsToImageOffset(
                    latitude: _currentPosition!.latitude,
                    longitude: _currentPosition!.longitude,
                    imageSize: fittedMap.size,
                  );

            // [L-28]
            return Stack(
              children: [
                Positioned.fromRect(
                  rect: fittedMap,
                  child: Image.asset(
                    MapSuggestionsVariables.map_path,
                    fit: BoxFit.contain,
                  ),
                ),
                if (markerOffset != null)
                  Positioned(
                    left:
                        fittedMap.left +
                        markerOffset.dx -
                        MapSuggestionsVariables.markerSize / 2,
                    top:
                        fittedMap.top +
                        markerOffset.dy -
                        MapSuggestionsVariables.markerSize / 2,
                    child: Image.asset(
                      MapSuggestionsVariables.position_char,
                      width: MapSuggestionsVariables.markerSize,
                      height: MapSuggestionsVariables.markerSize,
                    ),
                  ),
                if (!_isLocationReady && _locationMessage != null)
                  Center(
                    child: Text(
                      _locationMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Rect calculateContainedMapRect({
  required Size containerSize,
  required Size imageSize,
}) {
  // [L-29]
  if (containerSize.isEmpty || imageSize.isEmpty) {
    return Rect.zero;
  }

  // [L-30]
  final widthScale = containerSize.width / imageSize.width;
  final heightScale = containerSize.height / imageSize.height;
  final scale = widthScale < heightScale ? widthScale : heightScale;

  // [L-31]
  final fittedSize = Size(imageSize.width * scale, imageSize.height * scale);
  final left = (containerSize.width - fittedSize.width) / 2;
  final top = (containerSize.height - fittedSize.height) / 2;

  // [L-32]
  return Offset(left, top) & fittedSize;
}

Offset gpsToImageOffset({
  required double latitude,
  required double longitude,
  required Size imageSize,
}) {
  // [L-33]
  final longitudeRatio =
      (longitude - MapSuggestionsVariables.southwestLongitude) /
      (MapSuggestionsVariables.northeastLongitude -
          MapSuggestionsVariables.southwestLongitude);
  final latitudeRatio =
      (MapSuggestionsVariables.northeastLatitude - latitude) /
      (MapSuggestionsVariables.northeastLatitude -
          MapSuggestionsVariables.southwestLatitude);

  // [L-34]
  final safeLongitudeRatio = longitudeRatio.clamp(0.0, 1.0);
  final safeLatitudeRatio = latitudeRatio.clamp(0.0, 1.0);

  // [L-35]
  return Offset(
    safeLongitudeRatio * imageSize.width,
    safeLatitudeRatio * imageSize.height,
  );
}
