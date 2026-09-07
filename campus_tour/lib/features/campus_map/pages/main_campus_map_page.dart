import 'dart:async';

import 'package:campus_tour/controllers/location_controller.dart';
import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/controllers/nfc_scan_controller.dart';
import 'package:campus_tour/features/campus_map/controllers/campus_map_background_controller.dart';
import 'package:campus_tour/features/campus_map/controllers/campus_map_camera_controller.dart';
import 'package:campus_tour/features/campus_map/controllers/main_map_image_controller.dart';
import 'package:campus_tour/features/campus_map/controllers/monster_symbol_controller.dart';
import 'package:campus_tour/features/campus_map/controllers/nearest_monster_arrow_controller.dart';
import 'package:campus_tour/features/campus_map/controllers/player_symbol_controller.dart';
import 'package:campus_tour/features/campus_map/models/map_background_config.dart';
import 'package:campus_tour/features/campus_map/models/map_viewport_config.dart';
import 'package:campus_tour/features/campus_map/models/player_symbol_config.dart';
import 'package:campus_tour/features/campus_map/pages/monster_capture_page.dart';
import 'package:campus_tour/features/campus_map/widgets/campus_maplibre_canvas.dart';
import 'package:campus_tour/features/campus_map/widgets/main_map_controls.dart';
import 'package:campus_tour/features/campus_map/widgets/main_map_status_overlay.dart';
import 'package:campus_tour/features/campus_map/widgets/nearest_monster_info_overlay.dart';
import 'package:campus_tour/main.dart';
import 'package:campus_tour/models/monster_model.dart';
import 'package:campus_tour/services/audio_service.dart';
import 'package:campus_tour/widgets/common/drawer.dart';
import 'package:campus_tour/widgets/common/scale_button.dart';
import 'package:campus_tour/widgets/common/snackbar_builder.dart';
import 'package:campus_tour/widgets/constants/responsive.dart';
import 'package:campus_tour/widgets/game/system_menu.dart';
import 'package:campus_tour/widgets/game/user_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MainCampusMapPage extends StatefulWidget {
  const MainCampusMapPage({super.key, this.allowBackNavigation = false});

  final bool allowBackNavigation;

  @override
  State<MainCampusMapPage> createState() => _MainCampusMapPageState();
}

class _MainCampusMapPageState extends State<MainCampusMapPage>
    with WidgetsBindingObserver, RouteAware {
  static const double _minimumArrowDistance = 40;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final LocationController _locationController;
  late final MonsterController _monsterController;
  late final CampusMapCameraController _cameraController;
  late final CampusMapBackgroundController _backgroundController;
  late final MainMapImageController _mainMapImageController;
  late final PlayerSymbolController _playerSymbolController;
  late final MonsterSymbolController _monsterSymbolController;
  late final NearestMonsterArrowController _nearestMonsterArrowController;

  late final Worker _locationWorker;
  late final Worker _nearbyMonstersWorker;
  late final Worker _nearestMonsterWorker;
  late final Worker _nearestDistanceWorker;

  MapLibreMapController? _mapController;
  ModalRoute<dynamic>? _subscribedRoute;
  Timer? _backgroundRefreshTimer;
  Future<void>? _styleRestoreFuture;
  Future<void>? _mapKindSyncFuture;

  LatLng? _playerPosition;
  MonsterModel? _nearestMonster;
  double? _nearestMonsterDistance;
  MainMapKind _selectedMapKind = MainMapKind.campus;
  CampusMapBackgroundKind _backgroundKind = _backgroundKindAt(DateTime.now());
  String? _locationUnavailableMessage;

  bool _viewportPrepared = false;
  bool _styleRestoreRequested = false;
  bool _mapKindSyncRequested = false;
  bool _styleReady = false;
  bool _hasCenteredMap = false;
  bool _hasLocation = false;
  bool _isPlayerInsideCampusBounds = true;
  bool _isCaptureFlowActive = false;
  int _styleRevision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _locationController = Get.find<LocationController>();
    _monsterController = Get.find<MonsterController>();
    _cameraController = CampusMapCameraController(
      config: CampusMapViewports.mainMap,
    );
    _backgroundController = CampusMapBackgroundController(
      config: CampusMapBackgroundConfigs.mainGameMap,
    );
    _mainMapImageController = MainMapImageController();
    _playerSymbolController = PlayerSymbolController(
      config: CampusMapPlayerSymbolConfigs.mainMap,
    );
    _monsterSymbolController = MonsterSymbolController(
      onMonsterTap: _handleMonsterTapped,
    );
    _nearestMonsterArrowController = NearestMonsterArrowController();

    _locationWorker = ever<AppLocationState>(
      _locationController.state,
      _handleLocationChanged,
    );
    _nearbyMonstersWorker = ever<List<MonsterModel>>(
      _monsterController.nearbyMonsters,
      _handleNearbyMonstersChanged,
    );
    _nearestMonster = _monsterController.nearestMonster.value;
    _nearestMonsterDistance = _monsterController.nearestDistance.value;
    _nearestMonsterWorker = ever<MonsterModel?>(
      _monsterController.nearestMonster,
      _handleNearestMonsterChanged,
    );
    _nearestDistanceWorker = ever<double?>(
      _monsterController.nearestDistance,
      _handleNearestMonsterDistanceChanged,
    );

    _handleNearbyMonstersChanged(_monsterController.nearbyMonsters);
    _handleLocationChanged(_locationController.state.value);
    _scheduleBackgroundRefresh();

    unawaited(_locationController.startTracking());
    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(Get.find<NfcScanController>().startForegroundListening());
    }
    unawaited(_playSelectedMapBgm());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_viewportPrepared) {
      _cameraController.prepareViewport(context);
      _viewportPrepared = true;
    }

    final route = ModalRoute.of(context);
    if (route != null && !identical(route, _subscribedRoute)) {
      if (_subscribedRoute != null) {
        routeObserver.unsubscribe(this);
      }
      routeObserver.subscribe(this, route);
      _subscribedRoute = route;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(AudioService().pauseAllBgm());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(AudioService().resumeAllBgm());
    }
  }

  @override
  void didPushNext() {
    unawaited(AudioService().pauseMainBgm());
  }

  @override
  void didPopNext() {
    unawaited(_playSelectedMapBgm());
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    _cameraController.attachMapController(controller);
    _playerSymbolController.attachMapController(controller);
    _monsterSymbolController.attachMapController(controller);
    _nearestMonsterArrowController.attachMapController(controller);
  }

  Future<void> _onStyleLoaded() {
    if (!mounted) return Future<void>.value();

    _styleRevision++;
    _styleRestoreRequested = true;

    final runningRestore = _styleRestoreFuture;
    if (runningRestore != null) return runningRestore;

    final restore = _runStyleRestoreQueue();
    _styleRestoreFuture = restore;

    return restore.whenComplete(() {
      if (identical(_styleRestoreFuture, restore)) {
        _styleRestoreFuture = null;
      }
    });
  }

  Future<void> _runStyleRestoreQueue() async {
    while (_styleRestoreRequested && mounted) {
      _styleRestoreRequested = false;
      final revision = _styleRevision;

      try {
        await _restoreCurrentStyle(revision);
      } catch (error, stackTrace) {
        if (!mounted || revision != _styleRevision) continue;
        debugPrint(
          '[MainCampusMapPage] 還原 MapLibre style 內容失敗：'
          '$error\n$stackTrace',
        );
      }
    }
  }

  Future<void> _restoreCurrentStyle(int revision) async {
    final controller = _mapController;
    if (controller == null) return;

    _styleReady = false;
    _backgroundController.resetAfterStyleReload();
    _mainMapImageController.resetAfterStyleReload();
    _playerSymbolController.resetAfterStyleReload();
    _monsterSymbolController.resetAfterStyleReload();
    _nearestMonsterArrowController.resetAfterStyleReload();

    await _backgroundController.addToMap(controller, _backgroundKind);
    if (!_isCurrentStyleOperation(controller, revision)) return;

    await _mainMapImageController.addToMap(controller);
    if (!_isCurrentStyleOperation(controller, revision)) return;

    await controller.setSymbolIconAllowOverlap(true);
    if (!_isCurrentStyleOperation(controller, revision)) return;

    await _playerSymbolController.initialize();
    if (!_isCurrentStyleOperation(controller, revision)) return;

    await _monsterSymbolController.initialize();
    if (!_isCurrentStyleOperation(controller, revision)) return;

    await _nearestMonsterArrowController.initialize();
    if (!_isCurrentStyleOperation(controller, revision)) return;

    _styleReady = true;
    await _requestMapKindSync();
    if (!_isCurrentStyleOperation(controller, revision)) return;

    await _backgroundController.setBackground(controller, _backgroundKind);
    if (!_isCurrentStyleOperation(controller, revision)) return;

    await _restoreLiveMapState();
  }

  bool _isCurrentStyleOperation(
    MapLibreMapController controller,
    int revision,
  ) {
    return mounted &&
        identical(controller, _mapController) &&
        revision == _styleRevision;
  }

  Future<void> _restoreLiveMapState() async {
    final playerPosition = _playerPosition;
    if (playerPosition != null) {
      await _playerSymbolController.updatePosition(playerPosition);

      if (!_hasCenteredMap) {
        _hasCenteredMap = true;
        await _cameraController.returnToPlayer(playerPosition);
      }
    } else if (!_hasCenteredMap) {
      await _cameraController.fitCameraBounds();
    }

    await _monsterSymbolController.setMonsters(
      _monsterController.nearbyMonsters,
    );
    await _syncNearestMonsterArrow();
  }

  void _handleCameraMove(CameraPosition cameraPosition) {
    _playerSymbolController.handleCameraMove(cameraPosition);
    _nearestMonsterArrowController.handleCameraMove(cameraPosition);
  }

  void _handleLocationChanged(AppLocationState locationState) {
    if (!mounted) return;

    final position = locationState.position;
    if (position == null) {
      final message = _messageForLocationState(locationState);
      if (_hasLocation || message != _locationUnavailableMessage) {
        setState(() {
          _hasLocation = false;
          _locationUnavailableMessage = message;
        });
      }
      return;
    }

    final playerPosition = LatLng(position.latitude, position.longitude);
    final isInsideCampusBounds = _isInsideCampusBounds(playerPosition);
    final shouldRebuild =
        !_hasLocation ||
        isInsideCampusBounds != _isPlayerInsideCampusBounds ||
        _locationUnavailableMessage != null;

    _playerPosition = playerPosition;
    if (shouldRebuild) {
      setState(() {
        _hasLocation = true;
        _isPlayerInsideCampusBounds = isInsideCampusBounds;
        _locationUnavailableMessage = null;
      });
    }

    unawaited(_updatePlayerMapState(playerPosition));
    unawaited(_updateLocationMonsters(position));
  }

  Future<void> _updatePlayerMapState(LatLng playerPosition) async {
    try {
      await _playerSymbolController.updatePosition(playerPosition);

      if (_styleReady) {
        if (!_hasCenteredMap) {
          _hasCenteredMap = true;
          await _cameraController.returnToPlayer(playerPosition);
        } else {
          await _cameraController.followPlayer(playerPosition);
        }
      }

      await _syncNearestMonsterArrow();
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[MainCampusMapPage] 更新玩家地圖狀態失敗：$error\n$stackTrace');
    }
  }

  Future<void> _updateLocationMonsters(Position position) async {
    try {
      await _monsterController.updateLocationMonsters(position);
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[MainCampusMapPage] 更新附近怪物失敗：$error\n$stackTrace');
    }
  }

  void _handleNearbyMonstersChanged(List<MonsterModel> monsters) {
    unawaited(_setVisibleMonsters(monsters));
  }

  Future<void> _setVisibleMonsters(List<MonsterModel> monsters) async {
    try {
      await _monsterSymbolController.setMonsters(monsters);
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[MainCampusMapPage] 更新怪物 Symbol 失敗：$error\n$stackTrace');
    }
  }

  void _requestNearestMonsterArrowSync() {
    unawaited(_syncNearestMonsterArrowSafely());
  }

  void _handleNearestMonsterChanged(MonsterModel? monster) {
    if (mounted && !identical(monster, _nearestMonster)) {
      setState(() => _nearestMonster = monster);
    }
    _requestNearestMonsterArrowSync();
  }

  void _handleNearestMonsterDistanceChanged(double? distance) {
    if (mounted && distance != _nearestMonsterDistance) {
      setState(() => _nearestMonsterDistance = distance);
    }
    _requestNearestMonsterArrowSync();
  }

  Future<void> _syncNearestMonsterArrowSafely() async {
    try {
      await _syncNearestMonsterArrow();
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[MainCampusMapPage] 更新最近怪物箭頭失敗：$error\n$stackTrace');
    }
  }

  Future<void> _syncNearestMonsterArrow() async {
    final playerPosition = _playerPosition;
    final nearestMonster = _monsterController.nearestMonster.value;
    final nearestDistance = _monsterController.nearestDistance.value;

    if (playerPosition == null ||
        nearestMonster == null ||
        nearestDistance == null ||
        nearestDistance < _minimumArrowDistance) {
      await _nearestMonsterArrowController.hide();
      return;
    }

    await _nearestMonsterArrowController.updateDirection(
      playerPosition: playerPosition,
      monsterPosition: LatLng(
        nearestMonster.location.latitude,
        nearestMonster.location.longitude,
      ),
    );
  }

  void _handleMonsterTapped(MonsterModel monster) {
    unawaited(_handleMonsterCapture(monster));
  }

  Future<void> _handleMonsterCapture(MonsterModel monster) async {
    if (_isCaptureFlowActive || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isCaptureFlowActive = true;

    try {
      final qa = await _monsterController.getQAByMonster(monster);
      final architecture = await _monsterController.getArchitectureByMonster(
        monster,
      );

      if (!mounted) return;

      if (qa == null) {
        SnackBarBuilder.show(
          context,
          '無法載入 ${monster.name} 的題目，請稍後再試',
          type: AppToastType.error,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (architecture == null) {
        SnackBarBuilder.show(
          context,
          '無法載入 ${monster.name} 的建築資料，請稍後再試',
          type: AppToastType.error,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MonsterCapturePage(
            monster: monster,
            qa: qa,
            architectureType: architecture.canonicalType,
            onMissionFinished: () async {
              final navigator = Navigator.of(context);
              final success = await _monsterController.captureMonster(
                monster,
                uid,
              );

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
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[MainCampusMapPage] 開啟怪物捕捉流程失敗：$error\n$stackTrace');
      SnackBarBuilder.show(
        context,
        '無法開啟 ${monster.name} 的捕捉任務，請稍後再試',
        type: AppToastType.error,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isCaptureFlowActive = false;
    }
  }

  void _handleMapKindSelected(MainMapKind kind) {
    if (kind == _selectedMapKind) return;

    setState(() => _selectedMapKind = kind);
    _mapKindSyncRequested = true;
    unawaited(_requestMapKindSync());
    unawaited(_playSelectedMapBgm());
  }

  AudioTrack get _selectedMapAudioTrack {
    return switch (_selectedMapKind) {
      MainMapKind.campus => AudioTrack.walkDaytime,
      MainMapKind.forest => AudioTrack.walkNight,
    };
  }

  Future<void> _playSelectedMapBgm() {
    return AudioService().playMainBgm(track: _selectedMapAudioTrack);
  }

  Future<void> _requestMapKindSync() {
    if (!_styleReady || _mapController == null) {
      return Future<void>.value();
    }

    _mapKindSyncRequested = true;
    final runningSync = _mapKindSyncFuture;
    if (runningSync != null) return runningSync;

    final sync = _runMapKindSyncQueue();
    _mapKindSyncFuture = sync;

    return sync.whenComplete(() {
      if (identical(_mapKindSyncFuture, sync)) {
        _mapKindSyncFuture = null;
      }
    });
  }

  Future<void> _runMapKindSyncQueue() async {
    while (_mapKindSyncRequested && _styleReady && mounted) {
      _mapKindSyncRequested = false;
      final controller = _mapController;
      if (controller == null) return;

      try {
        await _mainMapImageController.switchTo(controller, _selectedMapKind);
      } catch (error, stackTrace) {
        if (!mounted || !identical(controller, _mapController)) return;
        debugPrint('[MainCampusMapPage] 切換主地圖失敗：$error\n$stackTrace');
      }
    }
  }

  Future<void> _returnToCurrentLocation() async {
    final position =
        _locationController.position ??
        await _locationController.getCurrentPosition(fresh: true);
    if (!mounted || position == null) return;

    final playerPosition = LatLng(position.latitude, position.longitude);
    _playerPosition = playerPosition;
    _hasCenteredMap = true;
    await _cameraController.returnToPlayer(playerPosition);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  bool _isInsideCampusBounds(LatLng position) {
    final bounds = CampusMapViewports.mainMap.cameraBounds;
    return position.latitude >= bounds.southwest.latitude &&
        position.latitude <= bounds.northeast.latitude &&
        position.longitude >= bounds.southwest.longitude &&
        position.longitude <= bounds.northeast.longitude;
  }

  String? _messageForLocationState(AppLocationState locationState) {
    return switch (locationState.status) {
      AppLocationStatus.idle ||
      AppLocationStatus.requestingPermission ||
      AppLocationStatus.ready => null,
      AppLocationStatus.serviceDisabled => 'view.aed.map.s001'.tr,
      AppLocationStatus.permissionDenied => 'view.aed.map.s002'.tr,
      AppLocationStatus.permissionDeniedForever => 'view.aed.map.s003'.tr,
      AppLocationStatus.error => 'view.aed.map.s004'.trParams({
        'error': locationState.errorMessage ?? '',
      }),
    };
  }

  void _scheduleBackgroundRefresh() {
    _backgroundRefreshTimer?.cancel();

    final now = DateTime.now();
    final nextSwitch = _nextBackgroundSwitch(now);
    _backgroundRefreshTimer = Timer(nextSwitch.difference(now), () {
      if (!mounted) return;

      _backgroundKind = _backgroundKindAt(DateTime.now());
      final controller = _mapController;
      if (_styleReady && controller != null) {
        unawaited(_setBackgroundSafely(controller));
      }
      _scheduleBackgroundRefresh();
    });
  }

  Future<void> _setBackgroundSafely(MapLibreMapController controller) async {
    try {
      await _backgroundController.setBackground(controller, _backgroundKind);
    } catch (error, stackTrace) {
      if (!mounted || !identical(controller, _mapController)) return;
      debugPrint('[MainCampusMapPage] 切換日夜背景失敗：$error\n$stackTrace');
    }
  }

  static CampusMapBackgroundKind _backgroundKindAt(DateTime time) {
    return time.hour >= 6 && time.hour < 18
        ? CampusMapBackgroundKind.day
        : CampusMapBackgroundKind.night;
  }

  DateTime _nextBackgroundSwitch(DateTime now) {
    final todayAt6 = DateTime(now.year, now.month, now.day, 6);
    final todayAt18 = DateTime(now.year, now.month, now.day, 18);

    if (now.isBefore(todayAt6)) return todayAt6;
    if (now.isBefore(todayAt18)) return todayAt18;
    return todayAt6.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _subscribedRoute = null;

    _backgroundRefreshTimer?.cancel();
    _locationWorker.dispose();
    _nearbyMonstersWorker.dispose();
    _nearestMonsterWorker.dispose();
    _nearestDistanceWorker.dispose();

    _styleRestoreRequested = false;
    _mapKindSyncRequested = false;
    _styleReady = false;
    _mapController = null;

    _playerSymbolController.dispose();
    _monsterSymbolController.dispose();
    _nearestMonsterArrowController.dispose();

    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(Get.find<NfcScanController>().stopForegroundListening());
    }
    unawaited(
      AudioService().stopMainBgm(onlyIfPlaying: _selectedMapAudioTrack),
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return PopScope(
      canPop: widget.allowBackNavigation,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        drawerEnableOpenDragGesture: true,
        body: Stack(
          children: [
            MainGameCampusMaplibreCanvas(
              cameraController: _cameraController,
              onMapCreated: _onMapCreated,
              onStyleLoaded: _onStyleLoaded,
              onCameraMove: _handleCameraMove,
            ),
            MainMapControls(
              selectedMapKind: _selectedMapKind,
              onMapKindSelected: _handleMapKindSelected,
              onOpenDrawer: _openDrawer,
              onReturnToPlayer: _returnToCurrentLocation,
              canReturnToPlayer: _hasLocation,
            ),
            MainMapStatusOverlay(
              hasLocation: _hasLocation,
              isPlayerInsideCampusBounds: _isPlayerInsideCampusBounds,
              locationUnavailableMessage: _locationUnavailableMessage,
            ),
            NearestMonsterInfoOverlay(
              hasPlayerPosition: _playerPosition != null,
              nearestMonster: _nearestMonster,
              distanceMeters: _nearestMonsterDistance,
              minimumVisibleDistance: _minimumArrowDistance,
            ),
            Positioned(
              top: 50 * scale,
              left: 20 * scale,
              child: const ScaleButton(onTap: null, child: UserHud()),
            ),
            Positioned(
              bottom: 30 * scale,
              left: 0,
              right: 0,
              child: const SystemMenu(),
            ),
          ],
        ),
      ),
    );
  }
}
