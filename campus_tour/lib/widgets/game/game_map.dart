import 'dart:async'; // 💡 引入 StreamSubscription
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // 💡 引入 GPS 套件
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GameMap extends StatefulWidget {
  const GameMap({super.key});

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream; // 📡 位置監聽器

  @override
  void initState() {
    super.initState();
    _checkPermissionAndListen(); // 初始化時檢查權限並開始監聽
  }

  // 💡 核心邏輯：檢查權限並追蹤位置
  Future<void> _checkPermissionAndListen() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 檢查 GPS 是否開啟
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // 2. 請求權限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // 3. 開始監聽位置變化
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation, // 💡 設為導航級精準度，heading 才會準
        distanceFilter: 2,
      ),
    ).listen((Position position) {
      // 💡 當座標改變時，移動地圖鏡頭
      _moveCamera(position);
    });
  }

  void _moveCamera(Position position) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 19.0,      // 保持縮放
            bearing: position.heading, // 💡 關鍵：將玩家的移動方向設定為地圖旋轉角度
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(24.9681, 121.1919),
        zoom: 19.0, // 追蹤模式建議縮放近一點
      ),
      buildingsEnabled: true,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}