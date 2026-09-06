import 'package:campus_tour/controllers/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:campus_tour/features/campus_map/controllers/campus_map_camera_controller.dart';
import 'package:campus_tour/features/campus_map/models/map_viewport_config.dart';
import 'package:campus_tour/features/campus_map/controllers/player_symbol_controller.dart';
import 'package:campus_tour/features/campus_map/controllers/georeferenced_image_layer_controller.dart';
import 'package:campus_tour/features/campus_map/models/georeferenced_image_config.dart';
import 'package:campus_tour/features/campus_map/widgets/campus_maplibre_canvas.dart';
import 'package:campus_tour/services/orientation_service.dart';

class EmergencyMapPage extends StatefulWidget {
  const EmergencyMapPage({super.key});

  @override
  State<EmergencyMapPage> createState() => _EmergencyMapPageState();
}

class _EmergencyMapPageState extends State<EmergencyMapPage> {
  MapLibreMapController? _controller;
  String? _locationMessage;

  // 空白底圖，只給你的圖片當地圖使用
  // iOS MapLibre only recognizes inline JSON when the first character is `{`.

  late final PlayerSymbolController _playerSymbolController;
  late final LocationController _locationController;
  late final Worker _locationWorker;
  late final CampusMapCameraController _cameraController;
  late final GeoreferencedImageLayerController _imageLayerController;

  bool _viewportPrepared = false;

  @override
  void initState() {
    super.initState();
    unawaited(OrientationService.lockLandscape());
    _locationController = Get.find<LocationController>();
    _locationWorker = ever<AppLocationState>(
      _locationController.state,
      _handleLocationChanged,
    );
    _handleLocationChanged(_locationController.state.value);
    _playerSymbolController = PlayerSymbolController();
    _cameraController = CampusMapCameraController(
      config: CampusMapViewports.emergency,
    );

    _imageLayerController = GeoreferencedImageLayerController(
      config: CampusMapGeoreferencedImages.emergency,
    );
  }

  @override
  void dispose() {
    _locationWorker.dispose();
    _playerSymbolController.dispose();
    unawaited(OrientationService.lockPortrait());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_viewportPrepared) return;

    _cameraController.prepareViewport(context);

    _viewportPrepared = true;
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    _cameraController.attachMapController(controller);
    _playerSymbolController.attachMapController(controller);
  }

  Future<void> _onStyleLoaded() async {
    final controller = _controller;
    if (controller == null) return;
    _imageLayerController.resetAfterStyleReload();
    _playerSymbolController.resetAfterStyleReload();

    await _imageLayerController.addToMap(controller);

    await _cameraController.fitCameraBounds();

    await _playerSymbolController.initialize();
    final currentPosition = _locationController.position;
    if (currentPosition != null) {
      await _playerSymbolController.updatePosition(
        LatLng(currentPosition.latitude, currentPosition.longitude),
      );
    }
    await _locationController.startTracking();
  }

  void _handleLocationChanged(AppLocationState locationState) {
    final position = locationState.position;

    if (position != null) {
      _playerSymbolController.updatePosition(
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
          EmergencyCampusMaplibreCanvas(
            cameraController: _cameraController,
            onMapCreated: _onMapCreated,
            onStyleLoaded: _onStyleLoaded,
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
