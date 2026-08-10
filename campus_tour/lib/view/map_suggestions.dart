import 'package:campus_tour/controllers/location_controller.dart';
import 'package:campus_tour/services/json_to_suggestion.dart';
import 'package:campus_tour/services/orientation_service.dart';
import 'package:campus_tour/styles/map_suggestion_style.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';

class MapSuggestionsVariables {
  // [L-01]
  // ignore: constant_identifier_names
  static const String map_path = 'assets/images/cute_map_real.png';

  // [L-02]
  // ignore: constant_identifier_names
  static const String position_char = 'assets/images/squirrel_front.png';

  // [L-03]
  static Size get mapImageSize => Size(2744, 1568);

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
  // 分類值必須與 locations JSON 保持一致，不可使用翻譯後文字作為資料 key。
  static const String ncuTenViewsCategory = '中大十景';

  // [L-53]
  static const String installationArtCategory = '裝置藝術';

  // [L-54]
  static const String toiletCategory = '廁所';

  static String categoryLabel(String category) {
    switch (category) {
      case ncuTenViewsCategory:
        return 'view.map.suggestions.s001'.tr;
      case installationArtCategory:
        return 'styles.map.suggestion.style.s001'.tr;
      case toiletCategory:
        return 'styles.map.suggestion.style.s002'.tr;
      default:
        return category;
    }
  }

  // [L-11]
  static List<String> get locationJsonPaths => [
    'assets/json/locations/NCU10view.json',
    'assets/json/locations/installation_art.json',
    'assets/json/locations/toilet.json',
  ];

  static const int step = 10;
}

class _LandmarkMarker {
  const _LandmarkMarker({required this.landmark, required this.offset});

  final SuggestionLocation landmark;
  final Offset offset;
}

class MapSuggestionsPage extends StatefulWidget {
  MapSuggestionsPage({super.key});

  @override
  State<MapSuggestionsPage> createState() => _MapSuggestionsPageState();
}

class _MapSuggestionsPageState extends State<MapSuggestionsPage> {
  final JsonToSuggestionService _suggestionService = JsonToSuggestionService();
  late final LocationController _locationController;
  late final Worker _locationWorker;
  Position? _currentPosition;
  bool _isLocationReady = false;
  String? _locationMessage;
  List<SuggestionLocation> _landmarks = [];
  String? _landmarkLoadMessage;
  Size? _cachedLandmarkMapSize;
  String? _cachedSelectedCategoryKey;
  List<_LandmarkMarker> _cachedLandmarkMarkers = [];
  final Map<String, bool> _selectedCategories = {
    MapSuggestionsVariables.ncuTenViewsCategory: false,
    MapSuggestionsVariables.installationArtCategory: false,
    MapSuggestionsVariables.toiletCategory: false,
  };

  @override
  void initState() {
    super.initState();
    _locationController = Get.find<LocationController>();
    _locationWorker = ever<AppLocationState>(
      _locationController.state,
      _handleLocationState,
    );
    _handleLocationState(_locationController.state.value);
    // [L-13]
    _forceLandscape();
    // [L-14]
    _loadLandscapeLocations();
    // [L-15]
    _locationController.startTracking();
  }

  @override
  void dispose() {
    _locationWorker.dispose();
    // [L-17]
    _restoreOrientation();
    super.dispose();
  }

  Future<void> _forceLandscape() async {
    // [L-18]
    await OrientationService.lockLandscape();
  }

  Future<void> _restoreOrientation() async {
    // [L-19]
    await OrientationService.lockPortrait();
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

  void _handleLocationState(AppLocationState locationState) {
    final position = locationState.position;
    if (position != null) {
      _handlePositionUpdate(position);
      return;
    }

    final message = switch (locationState.status) {
      AppLocationStatus.serviceDisabled => 'view.map.suggestions.s006'.tr,
      AppLocationStatus.permissionDenied ||
      AppLocationStatus.permissionDeniedForever =>
        'view.map.suggestions.s007'.tr,
      AppLocationStatus.error => 'view.aed.map.s004'.trParams({
        'error': locationState.errorMessage ?? '',
      }),
      _ => null,
    };

    if (!mounted || message == _locationMessage) return;
    setState(() {
      _isLocationReady = false;
      _locationMessage = message;
    });
  }

  void _handlePositionUpdate(Position position) {
    // [L-29]
    final previousPosition = _currentPosition;
    final shouldUpdate =
        previousPosition == null ||
        LocationController.distanceBetweenPositions(
              previousPosition,
              position,
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
    _cachedLandmarkMarkers = [];
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
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    panEnabled: true,
                    scaleEnabled: true,
                    boundaryMargin: EdgeInsets.zero,
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          MapSuggestionsVariables.map_path,
                          fit: MapSuggestionStyle.mapImageFit,
                        ),
                        if (markerOffset != null)
                          Positioned(
                            // [L-08]
                            left:
                                markerOffset.dx -
                                MapSuggestionStyle.markerSize / 2,
                            top:
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
                            left: landmarkMarker.offset.dx,
                            top: landmarkMarker.offset.dy,
                            child: _LandmarkLabel(marker: landmarkMarker),
                          ),
                      ],
                    ),
                  ),
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
                Positioned(
                  top: MapSuggestionStyle.filterPanelInset,
                  right: MapSuggestionStyle.filterPanelInset,
                  child: _MapBackButton(
                    onTap: () => Navigator.maybePop(context),
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

class _MapBackButton extends StatelessWidget {
  const _MapBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.58),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 25),
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
                  MapSuggestionsVariables.categoryLabel(entry.key),
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
      offset: MapSuggestionStyle.landmarkLabelOffset,
      child: Row(
        mainAxisSize: MapSuggestionStyle.landmarkLabelAxisSize,
        children: [
          Icon(
            Icons.location_on,
            size: MapSuggestionStyle.landmarkPinSize,
            color: MapSuggestionStyle.landmarkPinColor(
              marker.landmark.category,
            ),
          ),
          SizedBox(width: MapSuggestionStyle.landmarkLabelSpacing),
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
