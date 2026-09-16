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
import 'package:campus_tour/features/monster_capture/pages/monster_capture_page.dart';
import 'package:campus_tour/features/campus_map/widgets/campus_maplibre_canvas.dart';
import 'package:campus_tour/features/campus_map/widgets/main_map_controls.dart';
import 'package:campus_tour/features/campus_map/widgets/main_map_status_overlay.dart';
import 'package:campus_tour/features/campus_map/widgets/nearest_monster_info_overlay.dart';
import 'package:campus_tour/main.dart';
import 'package:campus_tour/models/monster_model.dart';
import 'package:campus_tour/services/audio_service.dart';
import 'package:campus_tour/features/drawer/drawer.dart';
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
  Future<void>? _campusStateSyncFuture;
  Completer<void>? _returnCameraIdleCompleter;

  LatLng? _playerPosition;
  MonsterModel? _nearestMonster;
  double? _nearestMonsterDistance;
  MainMapKind _selectedMapKind = MainMapKind.campus;
  CampusMapBackgroundKind _backgroundKind = _backgroundKindAt(DateTime.now());
  String? _locationUnavailableMessage;

  bool _styleRestoreRequested = false;
  bool _mapKindSyncRequested = false;
  bool _campusStateSyncRequested = false;
  bool _styleReady = false;
  bool _hasCenteredMap = false;
  bool _hasLocation = false;
  bool _isPlayerInsideCampusBounds = true;
  bool _isCaptureFlowActive = false;
  bool _isReturningToPlayer = false;
  bool _isReturnCameraReady = false;
  int _styleRevision = 0;
  int _cameraFollowRevision = 0;

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

    // 先套用目前位置的校內外狀態，再決定初始怪物是否應顯示。
    _handleLocationChanged(_locationController.state.value);
    _handleNearbyMonstersChanged(_monsterController.nearbyMonsters);
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

    // MediaQuery 尺寸改變時重新計算最低倍率與安全鏡頭範圍。
    _cameraController.prepareViewport(context);

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

    await _mainMapImageController.addToMap(
      controller,
      isVisible: _isPlayerInsideCampusBounds,
    );
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
    // Style 重載後一次還原目前應有的校內／校外畫面內容。
    await _requestCampusStateSync();
  }

  void _handleCameraMove(CameraPosition cameraPosition) {
    _playerSymbolController.handleCameraMove(cameraPosition);
    _nearestMonsterArrowController.handleCameraMove(cameraPosition);
    _cameraController.handleCameraMove(
      cameraPosition,
      constrainToBounds: _isPlayerInsideCampusBounds,
    );
  }

  void _handleCameraIdle() {
    final boundsChanged = _cameraController.commitPendingCameraTargetBounds(
      constrainToBounds: _isPlayerInsideCampusBounds,
    );
    if (boundsChanged && mounted) {
      // 只在縮放停止且安全範圍真的改變時重建，避免移動期間反覆更新原生選項。
      setState(() {});
    }

    // 明確通知定位流程動畫已停止，避免只依賴平台 Future 的回傳時機。
    final completer = _returnCameraIdleCompleter;
    if (completer != null && !completer.isCompleted) completer.complete();
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
    final cameraFollowRevision = ++_cameraFollowRevision;
    final oldIsInsideCampusBounds = _isPlayerInsideCampusBounds;
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

    if (isInsideCampusBounds != oldIsInsideCampusBounds) {
      if (_isReturningToPlayer) {
        // 定位期間先記住校內外狀態變更，等相機完成後再同步圖片與鏡頭。
        _campusStateSyncRequested = true;
        unawaited(_updatePlayerMapState(playerPosition, cameraFollowRevision));
      } else {
        unawaited(_requestCampusStateSync());
      }
    } else {
      unawaited(_updatePlayerMapState(playerPosition, cameraFollowRevision));
    }
    unawaited(_updateLocationMonsters(position));
  }

  Future<void> _updatePlayerMapState(
    LatLng playerPosition,
    int cameraFollowRevision,
  ) async {
    try {
      await _playerSymbolController.updatePosition(playerPosition);

      if (_styleReady &&
          !_isReturningToPlayer &&
          cameraFollowRevision == _cameraFollowRevision) {
        // 只有最新一筆 GPS 可以控制相機，避免較慢完成的舊更新覆蓋定位結果。
        if (!_hasCenteredMap) {
          _hasCenteredMap = true;
          await _cameraController.returnToPlayer(
            playerPosition,
            constrainToBounds: _isPlayerInsideCampusBounds,
          );
        } else {
          await _cameraController.followPlayer(
            playerPosition,
            constrainToBounds: _isPlayerInsideCampusBounds,
          );
        }
      }

      await _syncNearestMonsterArrow();
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[MainCampusMapPage] 更新玩家地圖狀態失敗：$error\n$stackTrace');
    }
  }

  Future<void> _requestCampusStateSync() {
    _campusStateSyncRequested = true;

    if (!_styleReady || _mapController == null) {
      return Future<void>.value();
    }

    final runningSync = _campusStateSyncFuture;
    if (runningSync != null) return runningSync;

    final sync = _runCampusStateSyncQueue();
    _campusStateSyncFuture = sync;

    return sync.whenComplete(() {
      if (identical(_campusStateSyncFuture, sync)) {
        _campusStateSyncFuture = null;
      }
    });
  }

  Future<void> _runCampusStateSyncQueue() async {
    while (_campusStateSyncRequested && _styleReady && mounted) {
      _campusStateSyncRequested = false;
      final controller = _mapController;
      if (controller == null) return;

      final isInsideCampusBounds = _isPlayerInsideCampusBounds;
      final playerPosition = _playerPosition;

      try {
        await _applyCampusState(
          controller: controller,
          isInsideCampusBounds: isInsideCampusBounds,
          playerPosition: playerPosition,
        );
      } catch (error, stackTrace) {
        if (!mounted || !identical(controller, _mapController)) return;
        debugPrint('[MainCampusMapPage] 同步校內外地圖狀態失敗：$error\n$stackTrace');
      }
    }
  }

  Future<void> _applyCampusState({
    required MapLibreMapController controller,
    required bool isInsideCampusBounds,
    required LatLng? playerPosition,
  }) async {
    if (!isInsideCampusBounds) {
      // 先隱藏有邊界的圖片與怪物，再解除鏡頭限制跟隨校外玩家。
      await _mainMapImageController.setVisible(controller, false);
      if (_isPlayerInsideCampusBounds) return;

      await _monsterSymbolController.setMonsters(const <MonsterModel>[]);

      if (playerPosition != null) {
        await _playerSymbolController.updatePosition(playerPosition);
        if (!_isReturningToPlayer) {
          await _cameraController.followPlayer(
            playerPosition,
            constrainToBounds: false,
          );
          _hasCenteredMap = true;
        }
      }

      // 校外仍保留最近怪物箭頭，讓玩家可以沿方向返回探索區域。
      await _syncNearestMonsterArrow();
      return;
    }

    // 回到校內時先把鏡頭移回安全中心範圍，完成後才顯示地圖，避免短暫露邊。
    if (playerPosition != null) {
      await _playerSymbolController.updatePosition(playerPosition);
      if (_isReturningToPlayer) {
        if (!_isReturnCameraReady) return;
        _hasCenteredMap = true;
      } else {
        await _cameraController.returnToPlayer(
          playerPosition,
          constrainToBounds: true,
        );
        _hasCenteredMap = true;
      }
    } else if (!_hasCenteredMap) {
      await _cameraController.fitCameraBounds();
      _hasCenteredMap = true;
    }

    if (!_isPlayerInsideCampusBounds) return;

    await _mainMapImageController.setVisible(controller, true);
    await _monsterSymbolController.setMonsters(
      _monsterController.nearbyMonsters,
    );
    await _syncNearestMonsterArrow();
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
    // 校外只留下玩家與指路箭頭；怪物等回到校內再同步顯示。
    final visibleMonsters =
        _isPlayerInsideCampusBounds && _mainMapImageController.isVisible
        ? monsters
        : const <MonsterModel>[];
    unawaited(_setVisibleMonsters(visibleMonsters));
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
    final shouldHideForShortDistance =
        _isPlayerInsideCampusBounds &&
        nearestDistance != null &&
        nearestDistance < _minimumArrowDistance;

    if (playerPosition == null ||
        nearestMonster == null ||
        nearestDistance == null ||
        shouldHideForShortDistance) {
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
    // 定位尚未結束時忽略重複點擊，避免多個相機動畫互相取消。
    if (_isReturningToPlayer) return;

    _isReturningToPlayer = true;
    _isReturnCameraReady = false;
    _cameraFollowRevision++;

    try {
      // 定位按鈕一律要求新的 GPS 座標，不再優先使用可能過期的快取位置。
      final position = await _locationController.getCurrentPosition(
        fresh: true,
      );
      if (!mounted ||
          position == null ||
          _locationController.state.value.status != AppLocationStatus.ready ||
          _mapController == null) {
        return;
      }

      var playerPosition = LatLng(position.latitude, position.longitude);
      var isInsideCampusBounds = _isInsideCampusBounds(playerPosition);
      _playerPosition = playerPosition;
      _hasCenteredMap = true;

      if (!_hasLocation ||
          isInsideCampusBounds != _isPlayerInsideCampusBounds ||
          _locationUnavailableMessage != null) {
        setState(() {
          _hasLocation = true;
          _isPlayerInsideCampusBounds = isInsideCampusBounds;
          _locationUnavailableMessage = null;
        });
      }

      // 等待先前已開始的校內外同步，確保它不會在定位動畫途中搶走相機。
      final runningCampusSync = _campusStateSyncFuture;
      if (runningCampusSync != null) await runningCampusSync;
      if (!mounted) return;

      final cameraIdleCompleter = Completer<void>();
      _returnCameraIdleCompleter = cameraIdleCompleter;
      try {
        await _cameraController.returnToPlayer(
          playerPosition,
          constrainToBounds: isInsideCampusBounds,
        );
        await cameraIdleCompleter.future.timeout(const Duration(seconds: 2));
      } on TimeoutException {
        // 少數裝置在相機位置沒有變化時不會送出 idle，逾時後仍執行最後校正。
        debugPrint('[MainCampusMapPage] 等待定位相機停止逾時，改用目前邊界繼續校正');
      } finally {
        if (identical(_returnCameraIdleCompleter, cameraIdleCompleter)) {
          _returnCameraIdleCompleter = null;
        }
      }
      if (!mounted) return;

      // 第一段動畫停止後會提交目標 zoom 的 Android 邊界；等畫面重建後，
      // 再使用期間收到的最新座標做一次無動畫校正，避免被舊邊界卡住。
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      playerPosition = _playerPosition ?? playerPosition;
      isInsideCampusBounds = _isInsideCampusBounds(playerPosition);
      await _cameraController.returnToPlayer(
        playerPosition,
        constrainToBounds: isInsideCampusBounds,
        animated: false,
      );
      if (!mounted) return;

      _isReturnCameraReady = true;
      await _requestCampusStateSync();
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[MainCampusMapPage] 返回目前位置失敗：$error\n$stackTrace');
    } finally {
      _isReturningToPlayer = false;
      _isReturnCameraReady = false;
      _cameraFollowRevision++;

      // 定位期間若跨越校園邊界，結束後補做尚未完成的畫面同步。
      if (mounted && _campusStateSyncRequested) {
        unawaited(_requestCampusStateSync());
      }
    }
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
    _campusStateSyncRequested = false;
    final returnCameraIdleCompleter = _returnCameraIdleCompleter;
    if (returnCameraIdleCompleter != null &&
        !returnCameraIdleCompleter.isCompleted) {
      returnCameraIdleCompleter.complete();
    }
    _returnCameraIdleCompleter = null;
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
              constrainCamera: _isPlayerInsideCampusBounds,
              onMapCreated: _onMapCreated,
              onStyleLoaded: _onStyleLoaded,
              onCameraMove: _handleCameraMove,
              onCameraIdle: _handleCameraIdle,
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
