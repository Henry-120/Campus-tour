import 'dart:async';

import 'package:campus_tour/services/json_to_suggestion.dart';
import 'package:campus_tour/styles/map_suggestion_style.dart';
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

  // [L-09]
  static const double locationUpdateMeters = 2;

  // [L-10]
  static const String ncuTenViewsCategory = '中大十景';

  // [L-53]
  static const String installationArtCategory = '裝置藝術';

  // [L-11]
  static const List<String> locationJsonPaths = [
    'assets/json/locations/NCU10view.json',
    'assets/json/locations/installation_art.json',
  ];

  static const int step = 10;
}

class _LandmarkMarker {
  const _LandmarkMarker({required this.landmark, required this.offset});

  final SuggestionLocation landmark;
  final Offset offset;
}

class MapSuggestionsPage extends StatefulWidget {
  const MapSuggestionsPage({super.key});

  @override
  State<MapSuggestionsPage> createState() => _MapSuggestionsPageState();
}

class _MapSuggestionsPageState extends State<MapSuggestionsPage> {
  final JsonToSuggestionService _suggestionService = JsonToSuggestionService();
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isLocationReady = false;
  String? _locationMessage;
  List<SuggestionLocation> _landmarks = const [];
  String? _landmarkLoadMessage;
  Size? _cachedLandmarkMapSize;
  String? _cachedSelectedCategoryKey;
  List<_LandmarkMarker> _cachedLandmarkMarkers = const [];
  final Map<String, bool> _selectedCategories = {
    MapSuggestionsVariables.ncuTenViewsCategory: false,
    MapSuggestionsVariables.installationArtCategory: false,
  };

  @override
  void initState() {
    super.initState();
    // [L-13]
    _forceLandscape();
    // [L-14]
    _loadLandscapeLocations();
    // [L-15]
    _startLocationTracking();
  }

  @override
  void dispose() {
    // [L-16]
    _positionSubscription?.cancel();
    // [L-17]
    _restoreOrientation();
    super.dispose();
  }

  Future<void> _forceLandscape() async {
    // [L-18]
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _restoreOrientation() async {
    // [L-19]
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  Future<void> _loadLandscapeLocations() async {
    try {
      // [L-20]
      final loadedLandmarks = await _suggestionService.loadLocations(
        MapSuggestionsVariables.locationJsonPaths,
      );

      if (!mounted) return;
      // [L-21]
      setState(() {
        _landmarks = loadedLandmarks;
        _landmarkLoadMessage = null;
        _clearLandmarkMarkerCache();
      });
    } catch (error) {
      debugPrint('[Debug][MapSuggestionsPage] 載入地景資料失敗: $error');
      if (!mounted) return;
      // [L-22]
      setState(() {
        _landmarkLoadMessage = '地景資料載入失敗：$error';
        _clearLandmarkMarkerCache();
      });
    }
  }

  Future<void> _startLocationTracking() async {
    // [L-23]
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _isLocationReady = false;
        _locationMessage = 'GPS 尚未開啟';
      });
      return;
    }

    // [L-24]
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // [L-25]
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _isLocationReady = false;
        _locationMessage = '尚未取得定位權限';
      });
      return;
    }

    // [L-26]
    final initialPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    if (!mounted) return;
    // [L-27]
    setState(() {
      _currentPosition = initialPosition;
      _isLocationReady = true;
      _locationMessage = null;
    });

    // [L-28]
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen(_handlePositionUpdate);
  }

  void _handlePositionUpdate(Position position) {
    // [L-29]
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

    // [L-30]
    if (!shouldUpdate || !mounted) return;

    // [L-31]
    setState(() {
      _currentPosition = position;
      _isLocationReady = true;
      _locationMessage = null;
    });
  }

  void _toggleCategory(String category, bool? value) {
    // [L-32]
    setState(() {
      _selectedCategories[category] = value ?? false;
      _clearLandmarkMarkerCache();
    });
  }

  void _clearLandmarkMarkerCache() {
    // [L-33]
    _cachedLandmarkMapSize = null;
    _cachedSelectedCategoryKey = null;
    _cachedLandmarkMarkers = const [];
  }

  String _selectedCategoryKey() {
    // [L-34]
    final selectedCategories =
        _selectedCategories.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();

    return selectedCategories.join('|');
  }

  List<_LandmarkMarker> _visibleLandmarkMarkers(Size mapSize) {
    final selectedCategoryKey = _selectedCategoryKey();

    // [L-35]
    if (_cachedLandmarkMapSize == mapSize &&
        _cachedSelectedCategoryKey == selectedCategoryKey) {
      return _cachedLandmarkMarkers;
    }

    // [L-36]
    final selectedCategories = _selectedCategories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toSet();

    // [L-37]
    final markers = _landmarks
        .where((landmark) => selectedCategories.contains(landmark.category))
        .map(
          (landmark) => _LandmarkMarker(
            landmark: landmark,
            offset: gpsToImageOffset(
              latitude: landmark.latitude,
              longitude: landmark.longitude,
              imageSize: mapSize,
            ),
          ),
        )
        .toList(growable: false);

    // [L-38]
    _cachedLandmarkMapSize = mapSize;
    _cachedSelectedCategoryKey = selectedCategoryKey;
    _cachedLandmarkMarkers = markers;
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    // [L-39]
    return Scaffold(
      backgroundColor: MapSuggestionStyle.pageBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // [L-40]
            final fittedMap = calculateContainedMapRect(
              containerSize: constraints.biggest,
              imageSize: MapSuggestionsVariables.mapImageSize,
            );

            // [L-41]
            final markerOffset = _currentPosition == null
                ? null
                : gpsToImageOffset(
                    latitude: _currentPosition!.latitude,
                    longitude: _currentPosition!.longitude,
                    imageSize: fittedMap.size,
                  );

            // [L-42]
            final landmarkMarkers = _visibleLandmarkMarkers(fittedMap.size);
            final panelLength = MapSuggestionStyle.filterPanelLength(
              constraints.maxWidth,
            );

            // [L-43]
            return Stack(
              children: [
                Positioned.fromRect(
                  rect: fittedMap,
                  child: Image.asset(
                    MapSuggestionsVariables.map_path,
                    fit: MapSuggestionStyle.mapImageFit,
                  ),
                ),
                if (markerOffset != null)
                  Positioned(
                    // [L-08]
                    left:
                        fittedMap.left +
                        markerOffset.dx -
                        MapSuggestionStyle.markerSize / 2,
                    top:
                        fittedMap.top +
                        markerOffset.dy -
                        MapSuggestionStyle.markerSize / 2,
                    child: Image.asset(
                      MapSuggestionsVariables.position_char,
                      width: MapSuggestionStyle.markerSize,
                      height: MapSuggestionStyle.markerSize,
                    ),
                  ),
                for (final landmarkMarker in landmarkMarkers)
                  Positioned(
                    left: fittedMap.left + landmarkMarker.offset.dx,
                    top: fittedMap.top + landmarkMarker.offset.dy,
                    child: _LandmarkLabel(marker: landmarkMarker),
                  ),
                Positioned(
                  left: MapSuggestionStyle.filterPanelInset,
                  top: MapSuggestionStyle.filterPanelInset,
                  width: panelLength,
                  child: _LandmarkFilterPanel(
                    maxPanelHeight: panelLength,
                    selectedCategories: _selectedCategories,
                    loadMessage: _landmarkLoadMessage,
                    onCategoryChanged: _toggleCategory,
                  ),
                ),
                if (!_isLocationReady && _locationMessage != null)
                  Center(
                    child: Text(
                      _locationMessage!,
                      style: MapSuggestionStyle.locationMessageTextStyle,
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

class _LandmarkFilterPanel extends StatelessWidget {
  const _LandmarkFilterPanel({
    required this.maxPanelHeight,
    required this.selectedCategories,
    required this.loadMessage,
    required this.onCategoryChanged,
  });

  final double maxPanelHeight;
  final Map<String, bool> selectedCategories;
  final String? loadMessage;
  final void Function(String category, bool? value) onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    // [L-44]
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxPanelHeight),
      child: DecoratedBox(
        decoration: MapSuggestionStyle.filterPanelDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in selectedCategories.entries)
              CheckboxListTile(
                value: entry.value,
                onChanged: (value) => onCategoryChanged(entry.key, value),
                dense: MapSuggestionStyle.filterTileDense,
                controlAffinity: MapSuggestionStyle.filterTileControlAffinity,
                activeColor: MapSuggestionStyle.filterTileActiveColor,
                checkColor: MapSuggestionStyle.filterTileCheckColor,
                title: Text(
                  entry.key,
                  style: MapSuggestionStyle.filterOptionTextStyle,
                ),
              ),
            if (loadMessage != null)
              Padding(
                padding: MapSuggestionStyle.loadMessagePadding,
                child: Align(
                  alignment: MapSuggestionStyle.loadMessageAlignment,
                  child: Text(
                    loadMessage!,
                    style: MapSuggestionStyle.loadMessageTextStyle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LandmarkLabel extends StatelessWidget {
  const _LandmarkLabel({required this.marker});

  final _LandmarkMarker marker;

  @override
  Widget build(BuildContext context) {
    // [L-45]
    return Transform.translate(
      offset: MapSuggestionStyle.landmarkLabelOffset(
        // [L-12]
        MapSuggestionStyle.landmarkDotSize,
      ),
      child: Row(
        mainAxisSize: MapSuggestionStyle.landmarkLabelAxisSize,
        children: [
          Container(
            width: MapSuggestionStyle.landmarkDotSize,
            height: MapSuggestionStyle.landmarkDotSize,
            decoration: MapSuggestionStyle.landmarkDotDecoration(
              marker.landmark.category,
            ),
          ),
          const SizedBox(width: MapSuggestionStyle.landmarkLabelSpacing),
          Text(
            marker.landmark.name,
            style: MapSuggestionStyle.landmarkNameTextStyle,
          ),
        ],
      ),
    );
  }
}

Rect calculateContainedMapRect({
  required Size containerSize,
  required Size imageSize,
}) {
  // [L-46]
  if (containerSize.isEmpty || imageSize.isEmpty) {
    return Rect.zero;
  }

  // [L-47]
  final widthScale = containerSize.width / imageSize.width;
  final heightScale = containerSize.height / imageSize.height;
  final scale = widthScale < heightScale ? widthScale : heightScale;

  // [L-48]
  final fittedSize = Size(imageSize.width * scale, imageSize.height * scale);
  final left = (containerSize.width - fittedSize.width) / 2;
  final top = (containerSize.height - fittedSize.height) / 2;

  // [L-49]
  return Offset(left, top) & fittedSize;
}

Offset gpsToImageOffset({
  required double latitude,
  required double longitude,
  required Size imageSize,
}) {
  // [L-50]
  final longitudeRatio =
      (longitude - MapSuggestionsVariables.southwestLongitude) /
      (MapSuggestionsVariables.northeastLongitude -
          MapSuggestionsVariables.southwestLongitude);
  final latitudeRatio =
      (MapSuggestionsVariables.northeastLatitude - latitude) /
      (MapSuggestionsVariables.northeastLatitude -
          MapSuggestionsVariables.southwestLatitude);

  // [L-51]
  final safeLongitudeRatio = longitudeRatio.clamp(0.0, 1.0);
  final safeLatitudeRatio = latitudeRatio.clamp(0.0, 1.0);

  // [L-52]
  return Offset(
    safeLongitudeRatio * imageSize.width,
    safeLatitudeRatio * imageSize.height,
  );
}
