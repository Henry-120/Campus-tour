import 'dart:async'; // 💡 引入 StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart'; // 💡 引入 GPS 套件
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:get/get.dart';

class GameMap extends StatefulWidget {
  const GameMap({super.key});

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream; // 📡 位置監聽器

  bool _hasLocationPermission = false;
  String? _mapStyle; // 地圖 JSON 風格
  AssetMapBitmap? _customMapImage; // 特製地圖圖片
  final _zoomRate = 19.5;

  static const LatLng southwest = LatLng(24.965184, 121.185000); // 左下
  static const LatLng northeast = LatLng(24.971653, 121.197487); // 右上

  final LatLngBounds campusBounds = LatLngBounds(
    southwest: southwest,
    northeast: northeast,
  );

  Future<void> _loadAssets() async {
    try {
      // 💡 [修正 1]：在進入任何 await 之前，先利用 context 把圖片設定檔產生好
      const imageConfig = ImageConfiguration();

      // 1. 載入 JSON 風格字串 (這會花一點點時間)
      final style = await rootBundle.loadString('assets/mapStyles/style2.json');
      
      // 2. 載入特製地圖圖片 (直接使用剛剛存好的 imageConfig，不依賴現在的 context)
      final image = await AssetMapBitmap.create(
        imageConfig,
        'assets/images/campus_map_4.png',
        bitmapScaling: MapBitmapScaling.none,
      );

      // 💡 [修正 2]：經過漫長的等待，在更新畫面之前，檢查這個元件是否還在畫面上
      if (!mounted) return; 

      setState(() {
        _mapStyle = style;
        _customMapImage = image;
        debugPrint("[Debug][GameMap]:資源載入完成，正在更新畫面");
      });
    } catch (e) {
      debugPrint("[Debug][GameMap][Error] 載入資源失敗: $e");
    }
  }

  // 💡 核心邏輯：檢查權限並追蹤位置
  Future<void> _checkPermissionAndListen() async {
    try {
      final monsterController = Get.find<MonsterController>();

      debugPrint("[Debug][GameMap]:正在檢查定位服務是否啟用");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint("[Debug][GameMap]:定位服務檢查超時");
          return false;
        },
      );
      debugPrint("[Debug][GameMap]:定位服務 status = $serviceEnabled");
      if (!serviceEnabled) {
        debugPrint("[Debug][GameMap]:定位服務未開啟");
        setState(() => _hasLocationPermission = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("[Debug][GameMap]:初始權限狀態 = $permission");
      if (permission == LocationPermission.denied) {
        debugPrint("[Debug][GameMap]:定位權限被拒絕，正在請求權限");
        permission = await Geolocator.requestPermission();
        debugPrint("[Debug][GameMap]:requestPermission 結果 = $permission");
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint("[Debug][GameMap]:定位權限被拒絕（$permission）");
        setState(() => _hasLocationPermission = false);
        return;
      }

      setState(() => _hasLocationPermission = true);
      debugPrint("[Debug][GameMap]:定位權限已授權，開始監聽位置變化");

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 2,
        ),
      ).listen((Position position) {
        debugPrint('[Debug][GameMap]:位置更新: ${position.latitude}, ${position.longitude}');
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
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: _zoomRate,      // 保持縮放
            bearing: position.heading, // 💡 關鍵：將玩家的移動方向設定為地圖旋轉角度
          ),
        ),
      );
    }
  }
  
  @override
  void initState() {
    super.initState();
    debugPrint("[Debug][GameMap]:正在初始化 GameMap");
    _loadAssets(); // 一次性載入 JSON 與 圖片
    _checkPermissionAndListen(); // 初始化時檢查權限並開始監聽
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[Debug][GameMap]:目前 _customMapImage 是 ${_customMapImage == null}");
    return Stack(
      children: [
        GoogleMap(
          minMaxZoomPreference: MinMaxZoomPreference(null, _zoomRate), // 限制最大縮放級別，避免玩家放大到看不清地圖
          initialCameraPosition: const CameraPosition(
            target: LatLng(24.9681, 121.1919),
          ),
          style: _mapStyle,

          groundOverlays: _customMapImage != null ? {
            GroundOverlay.fromBounds(
              groundOverlayId: const GroundOverlayId("ncu_custom_map"),
              image: _customMapImage!,
              bounds: campusBounds, // 圖片會自動對齊這四個角
              transparency: 0.2,         // 0.0 ~ 1.0，建議先設 0.8 方便校對
              clickable: false,
            ),
          } : {},

          buildingsEnabled: true,
          myLocationEnabled: _hasLocationPermission,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            debugPrint('[Debug][GameMap]:onMapCreated');
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
              child: const Text('定位權限未授權', style: TextStyle(color: Colors.black87)),
            ),
          ),
      ],
    );
  }
}