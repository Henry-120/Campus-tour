import 'package:campus_tour/controllers/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

class AEDMap extends StatefulWidget {
  const AEDMap({super.key});

  @override
  State<AEDMap> createState() => _AEDMapState();
}

class _AEDMapState extends State<AEDMap> {
  MapLibreMapController? _controller;
  String? _locationMessage;

  static const String _campusMapAssetPath =
      'assets/images/Disaster_Evacuation_Map/防災地圖_地圖.jpg';

  // 空白底圖，只給你的圖片當地圖使用
  static const String _blankStyle = '''
  {
    "version": 8,
    "sources": {},
    "layers": [
      {
        "id": "background",
        "type": "background",
        "paint": {
          "background-color": " #000000"
        }
      }
    ]
  }
  ''';

  //
  // 順序：
  // 左上 → 右上 → 右下 → 左下
  static const LatLng _topLeft = LatLng(24.972389, 121.184551);
  static const LatLng _topRight = LatLng(24.972389, 121.198360);
  static const LatLng _bottomRight = LatLng(24.963905, 121.198360);
  static const LatLng _bottomLeft = LatLng(24.963905, 121.184551);

  static const LatLng _initialCenter = LatLng(24.968147, 121.191456);
  static const List<DeviceOrientation> _landscapeOrientations = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
  static const List<DeviceOrientation> _restoreOrientations = [
    DeviceOrientation.portraitUp,
  ];

  static final LatLngBounds _campusBounds = LatLngBounds(
    southwest: _bottomLeft,
    northeast: _topRight,
  );

  PlayerSymbolController? _playerSymbolController;
  late final LocationController _locationController;
  late final Worker _locationWorker;
  late final CampusMapCameraController _cameraController;
  late final CampusImageLayerController _imageLayerController;

  bool _viewportPrepared = false;

  @override
  void initState() {
    super.initState();
    _lockLandscape();
    _locationController = Get.find<LocationController>();
    _locationWorker = ever<AppLocationState>(
      _locationController.state,
      _handleLocationChanged,
    );
    _handleLocationChanged(_locationController.state.value);
    _cameraController = CampusMapCameraController(
      campusBounds: _campusBounds,
      maxZoom: 20,
      padding: 24,
      fallbackMinZoom: 16,
    );

    _imageLayerController = CampusImageLayerController(
      assetPath: _campusMapAssetPath,
      topLeft: _topLeft,
      topRight: _topRight,
      bottomRight: _bottomRight,
      bottomLeft: _bottomLeft,
    );
  }

  @override
  void dispose() {
    _locationWorker.dispose();
    _playerSymbolController?.dispose();
    _restoreOrientation();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_viewportPrepared) return;

    _cameraController.prepareViewport(context);

    _viewportPrepared = true;
  }

  Future<void> _lockLandscape() async {
    await SystemChrome.setPreferredOrientations(_landscapeOrientations);
  }

  Future<void> _restoreOrientation() async {
    await SystemChrome.setPreferredOrientations(_restoreOrientations);
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    _cameraController.attachMapController(controller);
  }

  Future<void> _onStyleLoaded() async {
    final controller = _controller;
    if (controller == null) return;

    await _imageLayerController.addToMap(controller);

    await _cameraController.fitCampusBounds();

    _playerSymbolController ??= PlayerSymbolController(controller);

    await _playerSymbolController!.initialize();
    final currentPosition = _locationController.position;
    if (currentPosition != null) {
      await _playerSymbolController!.updatePosition(
        LatLng(currentPosition.latitude, currentPosition.longitude),
      );
    }
    await _locationController.startTracking();
  }

  void _handleLocationChanged(AppLocationState locationState) {
    final position = locationState.position;

    if (position != null) {
      _playerSymbolController?.updatePosition(
        LatLng(position.latitude, position.longitude),
      );
    }

    if (!mounted) return;

    setState(() {
      _locationMessage = _messageForLocationState(locationState);
    });
  }

  String? _messageForLocationState(AppLocationState locationState) {
    switch (locationState.status) {
      case AppLocationStatus.idle:
      case AppLocationStatus.requestingPermission:
      case AppLocationStatus.ready:
        return null;
      case AppLocationStatus.serviceDisabled:
        return 'view.aed.map.s001'.tr;
      case AppLocationStatus.permissionDenied:
        return 'view.aed.map.s002'.tr;
      case AppLocationStatus.permissionDeniedForever:
        return 'view.aed.map.s003'.tr;
      case AppLocationStatus.error:
        return 'view.aed.map.s004'.trParams({
          'error': locationState.errorMessage ?? '',
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _blankStyle,
            initialCameraPosition: _cameraController.getInitialCameraPosition(
              _initialCenter,
            ),
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,

            // 玩家定位
            myLocationEnabled: false,
            myLocationTrackingMode: MyLocationTrackingMode.none,

            compassEnabled: true,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            tiltGesturesEnabled: false,
            cameraTargetBounds: _cameraController.cameraTargetBounds,
            minMaxZoomPreference: _cameraController.zoomPreference,
            annotationOrder: const [
              AnnotationType.fill,
              AnnotationType.line,
              AnnotationType.circle,
              AnnotationType.symbol,
            ],
          ),

          // 左上角返回
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),

          // 定位權限提示
          if (_locationMessage != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Material(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _locationMessage!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PlayerSymbolController {
  //自訂玩家位置
  bool _started = false;
  Symbol? _playerSymbol;
  MapLibreMapController? controller;

  StreamSubscription<CompassEvent>? _compassSub;
  int _walkFrame = 0;
  static const int _defaultWalkSpeed = 140;
  static const double _defaultIconSize = 0.6;

  Timer? _walkAnimationTimer;
  String _currentDirection = 'right';
  LatLng? _latestPlayerLatLng;

  PlayerSymbolController(this.controller);
  String get _currentPlayerIcon {
    return 'squirrel_${_currentDirection}_$_walkFrame';
  }

  Future<void> _addPlayerAnimationImages(
    MapLibreMapController controller,
  ) async {
    final directions = ['up', 'right', 'down', 'left'];

    for (final direction in directions) {
      for (int i = 0; i < 4; i++) {
        final imageBytes = await rootBundle.load(
          'assets/images/player/squirrel_${direction}_$i.png',
        );

        await controller.addImage(
          'squirrel_${direction}_$i',
          imageBytes.buffer.asUint8List(),
        );
      }
    }
  }

  void _startWalkAnimation() {
    _walkAnimationTimer?.cancel();

    _walkAnimationTimer = Timer.periodic(
      const Duration(milliseconds: _defaultWalkSpeed),
      (_) {
        _walkFrame = (_walkFrame + 1) % 4;
        _updatePlayerSymbol();
      },
    );
  }

  void _startCompassStream() {
    _compassSub = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null) return;

      final nextDirection = _directionFromHeading(heading);

      if (nextDirection == _currentDirection) return;

      _currentDirection = nextDirection;
      _updatePlayerSymbol();
    });
  }

  String _directionFromHeading(double heading) {
    final normalized = (heading + 360) % 360;

    if (normalized >= 315 || normalized < 45) {
      return 'up';
    } else if (normalized >= 45 && normalized < 135) {
      return 'right';
    } else if (normalized >= 135 && normalized < 225) {
      return 'down';
    } else {
      return 'left';
    }
  }

  Future<void> _updatePlayerSymbol() async {
    final controller = this.controller;
    final position = _latestPlayerLatLng;

    if (controller == null || position == null) return;

    final iconName = _currentPlayerIcon;

    if (_playerSymbol == null) {
      _playerSymbol = await controller.addSymbol(
        SymbolOptions(
          geometry: position,
          iconImage: iconName,
          iconSize: _defaultIconSize,
          iconAnchor: 'center',
          zIndex: 999,
        ),
      );
    } else {
      await controller.updateSymbol(
        _playerSymbol!,
        SymbolOptions(geometry: position, iconImage: iconName),
      );
    }
  }

  Future<void> updatePosition(LatLng position) async {
    _latestPlayerLatLng = position;
    await _updatePlayerSymbol();
  }

  Future<void> initialize() async {
    if (_started) return;

    final mapController = controller;
    if (mapController == null) {
      throw StateError('SymbolController 尚未取得 MapLibreMapController');
    }

    _started = true;

    // 1. 先把玩家動畫圖片註冊進 MapLibre style
    await _addPlayerAnimationImages(mapController);

    // 2. 開始走路動畫
    _startWalkAnimation();

    // 3. 開始監聽指南針方向
    _startCompassStream();
  }

  void dispose() {
    _walkAnimationTimer?.cancel();
    _compassSub?.cancel();
  }
}

class CampusMapCameraController {
  CampusMapCameraController({
    required this.campusBounds,
    this.maxZoom = 20,
    this.padding = 24,
    this.fallbackMinZoom = 16,
  }) : _minZoom = fallbackMinZoom;

  final LatLngBounds campusBounds;
  final double maxZoom;
  final double padding;
  final double fallbackMinZoom;

  MapLibreMapController? _mapController;

  double _minZoom;
  bool _isViewportReady = false;

  double get minZoom => _minZoom;

  bool get isViewportReady => _isViewportReady;

  MinMaxZoomPreference get zoomPreference {
    return MinMaxZoomPreference(_minZoom, maxZoom);
  }

  CameraTargetBounds get cameraTargetBounds {
    return CameraTargetBounds(campusBounds);
  }

  CameraPosition getInitialCameraPosition(LatLng initialCenter) {
    return CameraPosition(
      target: initialCenter,
      zoom: _minZoom,
      bearing: 0,
      tilt: 0,
    );
  }

  void attachMapController(MapLibreMapController controller) {
    _mapController = controller;
  }

  void prepareViewport(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    _minZoom = _calculateFitMinZoom(
      screenSize: screenSize,
      bounds: campusBounds,
      padding: padding,
    );

    _isViewportReady = true;
  }

  Future<void> fitCampusBounds() async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.moveCamera(
      CameraUpdate.newLatLngBounds(
        campusBounds,
        left: padding,
        top: padding,
        right: padding,
        bottom: padding,
      ),
    );
  }

  Future<void> zoomIn() async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> zoomOut() async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> moveTo(LatLng target, {double zoom = 18}) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  double _calculateFitMinZoom({
    required Size screenSize,
    required LatLngBounds bounds,
    required double padding,
  }) {
    final usableWidth = screenSize.width - padding * 2;
    final usableHeight = screenSize.height - padding * 2;

    if (usableWidth <= 0 || usableHeight <= 0) {
      return fallbackMinZoom;
    }

    const double tileSize = 512;

    double lngToX(double lng) {
      return (lng + 180.0) / 360.0;
    }

    double latToY(double lat) {
      final latRad = lat * math.pi / 180.0;

      return (1.0 -
              math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
          2.0;
    }

    final west = bounds.southwest.longitude;
    final east = bounds.northeast.longitude;
    final south = bounds.southwest.latitude;
    final north = bounds.northeast.latitude;

    final x1 = lngToX(west);
    final x2 = lngToX(east);
    final y1 = latToY(north);
    final y2 = latToY(south);

    final lngFraction = (x2 - x1).abs();
    final latFraction = (y2 - y1).abs();

    if (lngFraction <= 0 || latFraction <= 0) {
      return fallbackMinZoom;
    }

    final zoomX = math.log(usableWidth / tileSize / lngFraction) / math.ln2;
    final zoomY = math.log(usableHeight / tileSize / latFraction) / math.ln2;

    final fitZoom = math.min(zoomX, zoomY);

    return fitZoom - 0.05;
  }
}

class CampusImageLayerController {
  CampusImageLayerController({
    required this.assetPath,
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
    this.sourceId = 'campus-image-source',
    this.layerId = 'campus-image-layer',
  });

  final String assetPath;

  final LatLng topLeft;
  final LatLng topRight;
  final LatLng bottomRight;
  final LatLng bottomLeft;

  final String sourceId;
  final String layerId;

  bool _added = false;

  Future<void> addToMap(MapLibreMapController controller) async {
    if (_added) return;
    _added = true;

    final byteData = await rootBundle.load(assetPath);
    final imageBytes = byteData.buffer.asUint8List();

    final imageCoordinates = LatLngQuad(
      topLeft: topLeft,
      topRight: topRight,
      bottomRight: bottomRight,
      bottomLeft: bottomLeft,
    );

    await controller.addImageSource(sourceId, imageBytes, imageCoordinates);

    await _addImageLayerBelowSymbols(controller);
  }

  Future<void> _addImageLayerBelowSymbols(
    MapLibreMapController controller,
  ) async {
    final symbolLayerIds =
        controller.symbolManager?.layerIds ?? const <String>[];

    if (symbolLayerIds.isNotEmpty) {
      await controller.addImageLayerBelow(
        layerId,
        sourceId,
        symbolLayerIds.first,
      );
      return;
    }

    await controller.addImageLayer(layerId, sourceId);
  }
}
