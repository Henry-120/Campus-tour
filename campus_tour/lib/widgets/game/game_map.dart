import 'dart:async'; // 💡 引入 StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart'; // 💡 引入 GPS 套件
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:get/get.dart';
import '../../view/nearby_monsters_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/monster_model.dart';
import 'user_marker.dart';
//for mission
import 'package:campus_tour/view/full_mission_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';
import 'package:campus_tour/widgets/game/catching_pages/full_mission.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level.dart';
import 'package:campus_tour/widgets/encyclopedia/all_the_monster/monster_graphics.dart';
import 'package:campus_tour/widgets/encyclopedia/all_the_monster/monster_text.dart';
import 'package:campus_tour/widgets/encyclopedia/all_the_monster/monster_nfc.dart';
import 'package:campus_tour/models/qa_model.dart';
//end for mission

class GameMap extends StatefulWidget {
  const GameMap({super.key});

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> with MonsterMarkersMixin {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream; // 📡 位置監聽器

  bool _hasLocationPermission = false;
  String? _mapStyle; // 地圖 JSON 風格
  AssetMapBitmap? _customMapImage; // 特製地圖圖片
  double _maxZoomRate = 21.0;
  double _minZoomRate = 15.0;

  LatLng? _playerPosition;
  bool _hasCenteredMap = false;
  UserMarker? _playerMarker;
  BitmapDescriptor? _playerIcon;

  static const LatLng southwest = LatLng(24.965184, 121.185000); // 左下
  static const LatLng northeast = LatLng(24.971653, 121.197487); // 右上

  final LatLngBounds campusBounds = LatLngBounds(
    southwest: southwest,
    northeast: northeast,
  );

  Future<void> _loadAssets() async {
    try {
      const imageConfig = ImageConfiguration();
      final style = await rootBundle.loadString('assets/mapStyles/style3.json');
      final image = await AssetMapBitmap.create(
        imageConfig,
        'assets/images/campus_map_4.png',
        bitmapScaling: MapBitmapScaling.none,
      );
      final playerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/doro.png',
        width: 48,
        height: 48,
      );

      if (!mounted) return;

      setState(() {
        _mapStyle = style;
        _customMapImage = image;
        _playerIcon = playerIcon;
        if (_playerPosition != null) {
          _playerMarker = UserMarker(
            position: _playerPosition!,
            icon: _playerIcon!,
          );
        }
      });
    } catch (e) {
      debugPrint("[Debug][GameMap][Error] 載入資源失敗: $e");
    }
  }

  Future<void> _checkPermissionAndListen() async {
    try {
      final monsterController = Get.find<MonsterController>();

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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      final LatLng currentLocation = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      setState(() {
        _playerPosition = currentLocation;
        if (_playerIcon != null) {
          _playerMarker = UserMarker(
            position: currentLocation,
            icon: _playerIcon!,
          );
        }
      });

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              distanceFilter: 8,
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

            if (shouldUpdateMarker) {
              setState(() {
                _playerPosition = currentLocation;
                if (_playerIcon != null) {
                  _playerMarker = UserMarker(
                    position: currentLocation,
                    icon: _playerIcon!,
                  );
                }
              });
            }

            _moveCamera(position);

            // 更新附近怪物
            monsterController.updateNearbyMonsters(position);
          });

      debugPrint("[Debug][GameMap]:已開始監聽位置變化");
    } catch (e, st) {
      debugPrint("[Debug][GameMap]:_checkPermissionAndListen 例外：$e");
      debugPrint("[Debug][GameMap]:stack trace：$st");
      setState(() => _hasLocationPermission = false);
    }
  }

  void _moveCamera(Position position) {
    if (_mapController == null) return;

    if (!_hasCenteredMap) {
      _hasCenteredMap = true;

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(campusBounds, 200),
      );

      // 1 秒后拉进玩家位置，然后锁定缩放倍率
      Future.delayed(const Duration(seconds: 1), () {
        if (_mapController != null && mounted) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                bearing: position.heading,
              ),
            ),
          );

          // 完成后锁定缩放倍率
          setState(() {
            _minZoomRate = 19.5;
            _maxZoomRate = 19.5;
          });
        }
      });
      return;
    }

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          bearing: position.heading,
        ),
      ),
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
  //         duration: const Duration(seconds: 2),
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
    _isCaptureFlowActive = true;

    try {
      final qa = await controller.getQAByMonster(monster);

      if (!mounted) return;

      if (qa == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('無法載入 ${monster.name} 的題目，請稍後再試'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuildingMonsterLevel(
            monster: monster,
            qa: qa,
            onMissionFinished: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final success = await controller.captureMonster(monster, uid);

              if (!mounted) return;

              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success ? '成功捕捉 ${monster.name} ✓' : '${monster.name} 已捕捉過',
                  ),
                  backgroundColor: success ? Colors.green : Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
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

  @override
  void initState() {
    super.initState();
    _loadAssets(); // 一次性載入 JSON 與 圖片
    _checkPermissionAndListen(); // 初始化時檢查權限並開始監聽
    listenToNearbyMonsters(_handleMonsterCapture);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          minMaxZoomPreference: MinMaxZoomPreference(
            _minZoomRate,
            _maxZoomRate,
          ),
          initialCameraPosition: const CameraPosition(
            target: LatLng(24.9684, 121.1912),
          ),
          style: _mapStyle,

          groundOverlays: _customMapImage != null
              ? {
                  GroundOverlay.fromBounds(
                    groundOverlayId: const GroundOverlayId("ncu_custom_map"),
                    image: _customMapImage!,
                    bounds: campusBounds, // 圖片會自動對齊這四個角
                    transparency: 0, // 0.0 ~ 1.0，建議先設 0.8 方便校對
                    clickable: false,
                  ),
                }
              : {},

          buildingsEnabled: true,
          markers: {
            if (_playerMarker != null) _playerMarker!.toMarker(),
            ...monsterMarkers, // 👈 MonsterMarkersMixin 提供的 getter
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: true,
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
        if (!_hasLocationPermission)
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '定位權限未授權',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
      ],
    );
  }
}

//從這裡開始
class BuildingMonsterLevel extends StatelessWidget {
  final MonsterModel monster;
  final QAModel qa;
  final Future<void> Function()? onMissionFinished;
  final MonsterModelCry monsterModelCry;
  final GraphicsTextLevel mission1;
  final CryptographyLevel mission2;
  BuildingMonsterLevel({
    super.key,
    required this.monster,
    required this.qa,
    this.onMissionFinished,
  }) : monsterModelCry = MonsterModelCry(
         name: monster.name,
         type: monster.type,
         imageUrl: monster.imageURL,
       ),
       mission1 = GraphicsTextLevel(
         firstTracePhoto: MonsterGraphics.graphics[monster.id] ?? '',
         descriptionText: MonsterText.texts[monster.id] ?? '',
         nfcId: MonsterNFC.nfcIds[monster.id] ?? '',
       ),
       mission2 = CryptographyLevel(
         questionSet: [qa.question],
         choiceSet: [qa.options],
         answerSet: [qa.answer],
       );
  List<FullMission> get missions => [
    FullMission(levelType: "graphicsTextLevel", graphicsTextLevel: mission1),
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

//到這裡為止
