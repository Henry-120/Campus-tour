import 'dart:async'; // 💡 引入 StreamSubscription
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart'; // 💡 引入 GPS 套件
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/controllers/nfc_scan_controller.dart';
import 'package:campus_tour/local_information/local_setting.dart';
import 'package:campus_tour/models/architecture_model.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/utils/monster_image_path.dart';
import 'package:get/get.dart';
import '../../view/nearby_monsters_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/monster_model.dart';
//for mission
import 'package:campus_tour/view/full_mission_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';
import 'package:campus_tour/widgets/game/catching_pages/full_mission.dart';
import 'package:campus_tour/widgets/game/catching_pages/discovered_item.dart';
import 'package:campus_tour/widgets/game/catching_pages/default_plot.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_plot.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_trace_plot.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';
import 'package:campus_tour/widgets/encyclopedia/all_the_monster/monster_graphics.dart';
import 'package:campus_tour/widgets/common/snackbar_builder.dart';
import 'package:campus_tour/models/qa_model.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:campus_tour/services/audio_service.dart';
//end for mission

class GameMap extends StatefulWidget {
  const GameMap({super.key});

  @override
  State<GameMap> createState() => _GameMapState();
}

enum MapTileLayer {
  campus(
    id: 'campus',
    labelKey: 'widgets.game.game.map.s001',
    assetFolder: 'assets/tiles',
    maxTileZoom: 19,
  ),
  forest(
    id: 'forest',
    labelKey: 'widgets.game.game.map.s002',
    assetFolder: 'assets/forest_tiles',
    maxTileZoom: 20,
  );

  const MapTileLayer({
    required this.id,
    required this.labelKey,
    required this.assetFolder,
    required this.maxTileZoom,
  });

  final String id;
  final String labelKey;
  final String assetFolder;
  final int maxTileZoom;

  String get label => labelKey.tr;
}

enum BackgroundTileKind {
  day(id: 'sky', assetPath: 'assets/images/cute_grass.png'),
  night(id: 'star', assetPath: 'assets/images/cute_star.png');

  const BackgroundTileKind({required this.id, required this.assetPath});

  final String id;
  final String assetPath;

  static BackgroundTileKind fromLocalTime(DateTime time) {
    return time.hour >= 6 && time.hour < 18
        ? BackgroundTileKind.day
        : BackgroundTileKind.night;
  }
}

class _GameMapState extends State<GameMap> with MonsterMarkersMixin {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream; // 📡 位置監聽器
  Timer? _backgroundTileRefreshTimer;

  bool _hasLocationPermission = false;
  String? _mapStyle; // 地圖 JSON 風格

  // AssetMapBitmap? _customMapImage; // 特製地圖圖片
  double _maxZoomRate = 18.5;
  double _minZoomRate = 18.5;

  LatLng? _playerPosition;
  bool _hasCenteredMap = false;
  bool _isPlayerInsideCampusBounds = true;
  MapTileLayer _selectedTileLayer = MapTileLayer.campus;
  BackgroundTileKind _backgroundTileKind = BackgroundTileKind.fromLocalTime(
    DateTime.now(),
  );
  // UserMarker? _playerMarker;
  // BitmapDescriptor? _playerIcon;

  static LatLng get southwest => LatLng(24.965184, 121.185000); // 左下
  static LatLng get northeast => LatLng(24.971653, 121.197487); // 右上
  static const bool _useFixedTestLocation = true; // 💡 測試用開關：使用固定位置而非真實 GPS
  static LatLng get _fixedTestLocation => LatLng(24.967731, 121.193638);
  // static LatLng get _fixedTestLocation => LatLng(24.9691, 121.1946);

  final LatLngBounds campusBounds = LatLngBounds(
    southwest: southwest,
    northeast: northeast,
  );
  // static const double playerSize = 60;

  Future<void> _loadAssets() async {
    try {
      final style = await rootBundle.loadString('assets/mapStyles/style3.json');

      if (!mounted) return;

      setState(() {
        _mapStyle = style;
      });
    } catch (e) {
      debugPrint("[Debug][GameMap][Error] 載入資源失敗: $e");
    }
  }

  Future<void> _checkPermissionAndListen() async {
    try {
      final monsterController = Get.find<MonsterController>();

      if (_useFixedTestLocation) {
        final testPosition = _fixedTestPosition();
        setState(() {
          _hasLocationPermission = true;
          _playerPosition = _fixedTestLocation;
          _isPlayerInsideCampusBounds = _isInsideCampusBounds(
            _fixedTestLocation,
          );
        });

        _moveCamera(testPosition);
        unawaited(monsterController.updateLocationMonsters(testPosition));
        debugPrint(
          '[Debug][GameMap]:使用固定測試定位 ${_fixedTestLocation.latitude}, ${_fixedTestLocation.longitude}',
        );
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _hasLocationPermission = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _hasLocationPermission = false);
        return;
      }

      setState(() => _hasLocationPermission = true);

      final Position currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      final LatLng currentLocation = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      setState(() {
        _playerPosition = currentLocation;
        _isPlayerInsideCampusBounds = _isInsideCampusBounds(currentLocation);
      });

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              distanceFilter: 0,
            ),
          ).listen((Position position) {
            debugPrint(
              '[Debug][GameMap]:位置更新: ${position.latitude}, ${position.longitude}',
            );

            final currentLocation = LatLng(
              position.latitude,
              position.longitude,
            );
            final oldPosition = _playerPosition;
            final shouldUpdateMarker =
                oldPosition == null ||
                Geolocator.distanceBetween(
                      oldPosition.latitude,
                      oldPosition.longitude,
                      currentLocation.latitude,
                      currentLocation.longitude,
                    ) >
                    2;
            final isInsideCampusBounds = _isInsideCampusBounds(currentLocation);

            if (shouldUpdateMarker ||
                isInsideCampusBounds != _isPlayerInsideCampusBounds) {
              setState(() {
                if (shouldUpdateMarker) {
                  _playerPosition = currentLocation;
                }
                _isPlayerInsideCampusBounds = isInsideCampusBounds;
              });
            }

            _moveCamera(position);

            unawaited(monsterController.updateLocationMonsters(position));
          });

      debugPrint('widgets.game.game.map.s006'.tr);
    } catch (e, st) {
      debugPrint("[Debug][GameMap]:_checkPermissionAndListen 例外：$e");
      debugPrint("[Debug][GameMap]:stack trace：$st");
      setState(() => _hasLocationPermission = false);
    }
  }

  bool _isInsideCampusBounds(LatLng position) {
    return position.latitude >= campusBounds.southwest.latitude &&
        position.latitude <= campusBounds.northeast.latitude &&
        position.longitude >= campusBounds.southwest.longitude &&
        position.longitude <= campusBounds.northeast.longitude;
  }

  void _scheduleBackgroundTileRefresh() {
    _backgroundTileRefreshTimer?.cancel();

    final now = DateTime.now();
    final nextSwitch = _nextBackgroundTileSwitch(now);
    _backgroundTileRefreshTimer = Timer(nextSwitch.difference(now), () {
      if (!mounted) return;

      setState(() {
        _backgroundTileKind = BackgroundTileKind.fromLocalTime(DateTime.now());
      });
      _scheduleBackgroundTileRefresh();
    });
  }

  DateTime _nextBackgroundTileSwitch(DateTime now) {
    final todayAt6 = DateTime(now.year, now.month, now.day, 6);
    final todayAt18 = DateTime(now.year, now.month, now.day, 18);

    if (now.isBefore(todayAt6)) return todayAt6;
    if (now.isBefore(todayAt18)) return todayAt18;
    return todayAt6.add(const Duration(days: 1));
  }

  void _moveCamera(Position position) {
    if (_mapController == null) return;

    if (!_hasCenteredMap) {
      _hasCenteredMap = true;

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(campusBounds, 50),
      );

      // 1 秒後拉近玩家位置，並設定正確縮放倍率以顯示特製地圖
      Future.delayed(Duration(seconds: 1), () {
        if (_mapController != null && mounted) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              // 不讓畫面旋轉
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 18.5,
                bearing: 0,
              ),
            ),
          );

          // 完成後鎖定縮放倍率
          setState(() {
            _minZoomRate = 18.5;
            _maxZoomRate = 18.5;
          });
        }
      });
      return;
    }

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18.5,
          bearing: 0,
        ),
      ),
    );
  }

  Position _fixedTestPosition() {
    return Position(
      latitude: _fixedTestLocation.latitude,
      longitude: _fixedTestLocation.longitude,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
      floor: null,
      isMocked: true,
    );
  }

  // Future<void> _handleMonsterCapture(MonsterModel monster) async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;

  //   final controller = Get.find<MonsterController>();
  //   final success = await controller.captureMonster(monster, uid);

  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           success ? '成功捕捉 ${monster.name} ✓' : '${monster.name} 已捕捉過',
  //         ),
  //         backgroundColor: success ? Colors.green : Colors.orange,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  //從這裡開始
  bool _isCaptureFlowActive = false;

  Future<void> _handleMonsterCapture(MonsterModel monster) async {
    if (_isCaptureFlowActive) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final controller = Get.find<MonsterController>();
    debugPrint(
      "[Debug][GameMap]:Nearby Monsters: ${controller.nearbyMonsters.length}",
    );
    _isCaptureFlowActive = true;

    try {
      final qa = await controller.getQAByMonster(monster);
      final architecture = await controller.getArchitectureByMonster(monster);

      if (!mounted) return;

      if (qa == null) {
        SnackBarBuilder.show(
          context,
          '無法載入 ${monster.name} 的題目，請稍後再試',
          type: AppToastType.error,
          duration: Duration(seconds: 3),
        );
        return;
      }

      if (architecture == null) {
        SnackBarBuilder.show(
          context,
          '無法載入 ${monster.name} 的建築資料，請稍後再試',
          type: AppToastType.error,
          duration: Duration(seconds: 3),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuildingMonsterLevel(
            monster: monster,
            qa: qa,
            architectureType: architecture.canonicalType,
            onMissionFinished: () async {
              final navigator = Navigator.of(context);
              final success = await controller.captureMonster(monster, uid);

              if (!mounted) return;

              navigator.pop();
              SnackBarBuilder.show(
                context,
                success ? '成功捕捉 ${monster.name}' : '${monster.name} 已捕捉過',
                type: success ? AppToastType.success : AppToastType.warning,
              );
            },
          ),
        ),
      );
    } finally {
      _isCaptureFlowActive = false;
    }
  }
  //到這裡為止

  Set<Marker> _debugMonsterMarkers(Set<Marker> markers) {
    debugPrint('========== [MarkerDebug_GameMap] ==========');
    debugPrint('GoogleMap 收到 marker 數量: ${markers.length}');

    for (final marker in markers) {
      debugPrint(
        '[MarkerDebug_GameMap] '
        'markerId: ${marker.markerId.value}, '
        'lat: ${marker.position.latitude.toStringAsFixed(6)}, '
        'lng: ${marker.position.longitude.toStringAsFixed(6)}',
      );
    }

    debugPrint('==========================================');

    return markers;
  }

  @override
  void initState() {
    super.initState();
    _loadAssets(); // 一次性載入 JSON 與 圖片
    _checkPermissionAndListen(); // 初始化時檢查權限並開始監聽
    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(Get.find<NfcScanController>().startForegroundListening());
    }
    _scheduleBackgroundTileRefresh();
    listenToNearbyMonsters(_handleMonsterCapture);
  }

  @override
  void dispose() {
    _backgroundTileRefreshTimer?.cancel();
    _positionStream?.cancel();
    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(Get.find<NfcScanController>().stopForegroundListening());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final marker in monsterMarkers) {
      debugPrint(
        '[MarkerDebug_GameMap]'
        'markerId: ${marker.markerId.value}, '
        'lat: ${marker.position.latitude.toStringAsFixed(6)}, '
        'lng: ${marker.position.longitude.toStringAsFixed(6)}',
      );
    }
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.none,
          minMaxZoomPreference: MinMaxZoomPreference(
            _minZoomRate,
            _maxZoomRate,
          ),
          initialCameraPosition: CameraPosition(
            target: _useFixedTestLocation
                ? _fixedTestLocation
                : LatLng(24.9684, 121.1912),
            zoom: 18.5, // 💡 初始縮放
          ),
          style: _mapStyle,

          tileOverlays: {
            TileOverlay(
              tileOverlayId: TileOverlayId(
                'background_tiles_${_backgroundTileKind.id}',
              ),
              tileProvider: BackgroundTileProvider(
                tileKind: _backgroundTileKind,
              ),
              transparency: 0.0,
              zIndex: 0,
              tileSize: 512,
            ),
            TileOverlay(
              tileOverlayId: TileOverlayId(
                'ncu_custom_tiles_${_selectedTileLayer.id}',
              ),
              tileProvider: AssetTileProvider(layer: _selectedTileLayer),
              transparency: 0.0,
              zIndex: 1,
            ),
          },

          buildingsEnabled: true,
          markers: _debugMonsterMarkers({...monsterMarkers}),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          scrollGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          onMapCreated: (controller) {
            _mapController = controller;
            final playerPosition = _playerPosition;
            if (playerPosition != null) {
              _moveCamera(
                Position(
                  latitude: playerPosition.latitude,
                  longitude: playerPosition.longitude,
                  timestamp: DateTime.now(),
                  accuracy: 1,
                  altitude: 0,
                  altitudeAccuracy: 0,
                  heading: 0,
                  headingAccuracy: 0,
                  speed: 0,
                  speedAccuracy: 0,
                  floor: null,
                  isMocked: _useFixedTestLocation,
                ),
              );
            }
          },
        ),
        Positioned(
          right: 16,
          top: 16,
          child: SafeArea(
            child: _MapLayerButton(
              selectedLayer: _selectedTileLayer,
              onSelected: (layer) {
                setState(() {
                  _selectedTileLayer = layer;
                });
                if (layer == MapTileLayer.forest) {
                  AudioService().playMainBgm(
                    fileName: 'audio/M05_walk_night.wav',
                  );
                } else {
                  AudioService().playMainBgm(
                    fileName: 'audio/M04_walk_daytime.wav',
                  );
                }
              },
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: 76,
          child: SafeArea(child: _DrawerHintButton()),
        ),
        if (!_hasLocationPermission)
          Positioned(
            right: 16,
            top: 136,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'widgets.game.game.map.s012'.tr,
                style: AppTheme.titleStyle.copyWith(
                  color: Colors.black87,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        if (_hasLocationPermission && !_isPlayerInsideCampusBounds)
          const Align(
            alignment: Alignment(0, -0.4),
            child: _OutOfCampusNotice(),
          ),
      ],
    );
  }
}

class _DrawerHintButton extends StatelessWidget {
  const _DrawerHintButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Image.asset(
        'assets/images/component/side_bar.png',
        width: 52,
        height: 52,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _OutOfCampusNotice extends StatelessWidget {
  const _OutOfCampusNotice();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.85),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          'widgets.game.game.map.s017'.tr,
          textAlign: TextAlign.center,
          style: AppTheme.titleStyle.copyWith(
            color: AppTheme.gameTextColor,
            fontSize: 22,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _MapLayerButton extends StatelessWidget {
  const _MapLayerButton({
    required this.selectedLayer,
    required this.onSelected,
  });

  final MapTileLayer selectedLayer;
  final ValueChanged<MapTileLayer> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MapTileLayer>(
      tooltip: 'widgets.game.game.map.s013'.tr,
      initialValue: selectedLayer,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final layer in MapTileLayer.values)
          PopupMenuItem<MapTileLayer>(
            value: layer,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  layer == selectedLayer
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: Colors.black87,
                ),
                SizedBox(width: 10),
                Text(layer.label),
              ],
            ),
          ),
      ],
      child: Image.asset(
        'assets/images/component/layers.png',
        width: 52,
        height: 52,
        fit: BoxFit.contain,
      ),
    );
  }
}

//從這裡開始
class BuildingMonsterLevel extends StatelessWidget {
  final MonsterModel monster;
  final QAModel qa;
  final String architectureType;
  final Future<void> Function()? onMissionFinished;
  final MonsterModelCry monsterModelCry;
  final PlotLevel tracePlotMission;
  final GraphicsTextLevel mission1;
  final PlotLevel battlePlotMission;
  final CryptographyLevel mission2;
  BuildingMonsterLevel({
    super.key,
    required this.monster,
    required this.qa,
    required this.architectureType,
    this.onMissionFinished,
  }) : monsterModelCry = MonsterModelCry(
         name: monster.name,
         type: monster.canonicalType,
         imageUrl: MonsterImagePath.staticImage(monster.imageURL),
       ),

       tracePlotMission = PlotLevel(
         type: PlotLevel.traceType,
         isPassed: LocalSettingService.autoSkipStory.isEnabled,
         title: PlotLevel.traceTitle,
         description: PlotLevel.traceDescription,
         dialogueSteps: MonsterTracePlot.steps(monsterId: monster.id),
         leftCharacter: const PlotSceneCharacter(spritePath: ''),
         rightCharacter: PlotSceneCharacter(
           spritePath: PlotLevel.squirrelSpritePath,
         ),
       ),
       mission1 = GraphicsTextLevel(
         firstTracePhoto: MonsterGraphics.graphics[monster.id] ?? '',
         storyReviewSteps:
             MonsterTracePlot.steps(monsterId: monster.id) ?? const [],
         discoveredItem: DiscoveredItem.strategyBook,
         nfcId: monster.nfcAns ?? '',
       ),
       battlePlotMission = PlotLevel(
         type: PlotLevel.battleType,
         isPassed: LocalSettingService.autoSkipStory.isEnabled,
         title: PlotLevel.battleTitle,
         description: PlotLevel.battleDescription,
         // 優先使用專屬台詞，若未設定則 fallback 到通用版。
         dialogueSteps:
             MonsterPlot.battleSteps(
               monsterId: monster.id,
               fairyImagePath: MonsterImagePath.staticImage(monster.imageURL),
             ) ??
             DefaultPlot.battlePlotDialogueSteps(
               fairyName: monster.name,
               fairyImagePath: MonsterImagePath.staticImage(monster.imageURL),
             ),
         leftCharacter: PlotSceneCharacter(
           spritePath: PlotLevel.magicCircleSpritePath,
         ),
         rightCharacter: PlotSceneCharacter(
           spritePath: PlotLevel.squirrelSpritePath,
         ),
       ),
       mission2 = CryptographyLevel(
         questionSet: [qa.question],
         choiceSet: [qa.options],
         answerSet: [qa.answer],
       );
  List<FullMission> get missions {
    switch (architectureType) {
      case ArchitectureModel.departmentBuilding:
        return systemManagementMissions;
      case ArchitectureModel.installationArt:
        return installationArtMissions;
      case ArchitectureModel.scenicSpot:
        return scenicSpotMissions;
      default:
        return installationArtMissions;
    }
  }

  List<FullMission> get systemManagementMissions => [
    FullMission(levelType: "plotLevel", plotLevel: battlePlotMission),
    FullMission(levelType: "cryptographyLevel", cryptographyLevel: mission2),
  ];

  List<FullMission> get installationArtMissions => [
    FullMission(levelType: "plotLevel", plotLevel: tracePlotMission),
    if (monster.nfcAns != null)
      FullMission(levelType: "graphicsTextLevel", graphicsTextLevel: mission1),
    FullMission(levelType: "plotLevel", plotLevel: battlePlotMission),
    FullMission(levelType: "cryptographyLevel", cryptographyLevel: mission2),
  ];

  List<FullMission> get scenicSpotMissions => [
    FullMission(levelType: "plotLevel", plotLevel: battlePlotMission),
    FullMission(levelType: "cryptographyLevel", cryptographyLevel: mission2),
  ];

  @override
  Widget build(BuildContext context) {
    return FullMissionPage(
      missions: missions,
      monsterModelCry: monsterModelCry,
      onMissionFinished: onMissionFinished,
    );
  }
}

class AssetTileProvider implements TileProvider {
  static const int _minTileZoom = 15;
  static int _debugLogCount = 0;

  AssetTileProvider({required this.layer});

  final MapTileLayer layer;

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final int z = zoom ?? 0;
    if (z < _minTileZoom) return TileProvider.noTile;

    final int sourceZ = z > layer.maxTileZoom ? layer.maxTileZoom : z;
    final int zoomDelta = z - sourceZ;
    final int sourceX = zoomDelta > 0 ? x >> zoomDelta : x;
    final int sourceY = zoomDelta > 0 ? y >> zoomDelta : y;
    final int tmsY = (1 << sourceZ) - 1 - sourceY;

    for (final tileY in [sourceY, tmsY]) {
      final path = '${layer.assetFolder}/$sourceZ/$sourceX/$tileY.png';
      try {
        final ByteData data = await rootBundle.load(path);
        final Uint8List bytes = zoomDelta > 0
            ? await _cropOverzoomTile(
                data.buffer.asUint8List(),
                x,
                y,
                zoomDelta,
              )
            : data.buffer.asUint8List();
        if (_debugLogCount < 20) {
          debugPrint('[Debug][TileOverlay] HIT z=$z x=$x y=$y source=$path');
          _debugLogCount++;
        }
        return Tile(256, 256, bytes);
      } catch (_) {
        if (_debugLogCount < 20) {
          debugPrint('[Debug][TileOverlay] MISS z=$z x=$x y=$y tile=$path');
          _debugLogCount++;
        }
      }
    }

    return TileProvider.noTile;
  }

  Future<Uint8List> _cropOverzoomTile(
    Uint8List parentBytes,
    int requestedX,
    int requestedY,
    int zoomDelta,
  ) async {
    final codec = await ui.instantiateImageCodec(parentBytes);
    final frame = await codec.getNextFrame();
    final parent = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final divisions = 1 << zoomDelta;
    final cropSize = parent.width / divisions;
    final cropX = (requestedX % divisions) * cropSize;
    final cropY = (requestedY % divisions) * cropSize;

    canvas.drawImageRect(
      parent,
      ui.Rect.fromLTWH(cropX, cropY, cropSize, cropSize),
      const ui.Rect.fromLTWH(0, 0, 256, 256),
      ui.Paint(),
    );

    final image = await recorder.endRecording().toImage(256, 256);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    parent.dispose();
    image.dispose();

    return byteData!.buffer.asUint8List();
  }
}

class BackgroundTileProvider implements TileProvider {
  static final Map<String, Future<Uint8List>> _tileBytesByPath = {};

  BackgroundTileProvider({required this.tileKind});

  final BackgroundTileKind tileKind;

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final bytes = await _tileBytesByPath.putIfAbsent(
      tileKind.assetPath,
      () => _loadTile(tileKind.assetPath),
    );
    return Tile(512, 512, bytes);
  }

  static Future<Uint8List> _loadTile(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }
}

//到這裡為止
