import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/monster_controller.dart';
import '../../models/monster_model.dart';
import '../../widgets/game/monster_marker.dart';

/// 提供給 GameMap 使用的 mixin，負責維護怪物 markers set。
///
/// 使用方式：
///   `class _GameMapState extends State<GameMap> with MonsterMarkersMixin {`
///     @override
///     void initState() {
///       super.initState();
///       listenToNearbyMonsters(_handleMonsterCapture);
///     }
///   }
///
/// 在 GoogleMap 的 markers 參數：
///   markers: {
///     if (_playerMarker != null) _playerMarker!.toMarker(),
///     ...monsterMarkers,
///   },
mixin MonsterMarkersMixin<T extends StatefulWidget> on State<T> {
  final MonsterController _monsterController = Get.find<MonsterController>();
  final Map<String, BitmapDescriptor> _monsterIconCache = {};
  final Set<String> _missingAnimatedFolders = {};
  Set<Marker> _monsterMarkers = {};
  Timer? _monsterAnimationTimer;
  Worker? _nearbyMonsterWorker;
  List<MonsterModel> _visibleMonsters = const [];
  void Function(MonsterModel)? _monsterTapHandler;
  int _monsterFrameIndex = 0;
  int _markerBuildToken = 0;
  static const int _monsterFrameCount = 4;
  static const Duration _monsterFrameDuration = Duration(milliseconds: 300);
  static const double _markerDisplaySize = 150;
  static const int _markerBitmapSize = 300;

  /// GameMap 的 markers 參數直接 spread 這個 getter
  Set<Marker> get monsterMarkers => _monsterMarkers;

  /// 在 initState 呼叫，開始用 ever() 監聽 nearbyMonsters 的變化。
  /// [onTap] 是點擊怪物 Marker 時的回呼，通常傳入 _handleMonsterCapture。
  void listenToNearbyMonsters(void Function(MonsterModel) onTap) {
    _monsterTapHandler = onTap;
    _nearbyMonsterWorker = ever(_monsterController.nearbyMonsters, (monsters) {
      _visibleMonsters = List<MonsterModel>.from(monsters);
      if (_visibleMonsters.isEmpty) {
        _stopMonsterAnimation();
        if (mounted) setState(() => _monsterMarkers = {});
        return;
      }

      _startMonsterAnimation();
      unawaited(_refreshMonsterMarkers());
    });
  }

  void _startMonsterAnimation() {
    if (_monsterAnimationTimer?.isActive ?? false) return;

    _monsterAnimationTimer = Timer.periodic(_monsterFrameDuration, (_) {
      _monsterFrameIndex = (_monsterFrameIndex + 1) % _monsterFrameCount;
      unawaited(_refreshMonsterMarkers());
    });
  }

  void _stopMonsterAnimation() {
    _monsterAnimationTimer?.cancel();
    _monsterAnimationTimer = null;
    _monsterFrameIndex = 0;
  }

  Future<void> _refreshMonsterMarkers() async {
    final onTap = _monsterTapHandler;
    if (onTap == null) return;

    final token = ++_markerBuildToken;
    final markers = await _buildMonsterMarkers(
      List<MonsterModel>.from(_visibleMonsters),
      onTap,
    );

    if (mounted && token == _markerBuildToken) {
      setState(() => _monsterMarkers = markers);
    }
  }

  Future<Set<Marker>> _buildMonsterMarkers(
    List<MonsterModel> monsters,
    void Function(MonsterModel) onTap,
  ) async {
    final result = <Marker>{};
    debugPrint('[MarkerDebug] 準備建立 Marker，monsters 數量: ${monsters.length}');
    for (final m in monsters) {
      final icon = await _loadMonsterIcon(m, _monsterFrameIndex + 1);
      result.add(
        MonsterMarker(monster: m, icon: icon, onTap: () => onTap(m)).toMarker(),
      );

      // final icon = await _loadMonsterIcon(m);

      final marker = MonsterMarker(
        monster: m,
        icon: icon,
        onTap: () {
          debugPrint('[MarkerDebug] 點擊 Marker: ${m.name}');
          onTap(m);
        },
      ).toMarker();

      debugPrint(
        '[MarkerDebug] Marker position: '
        '${marker.position.latitude.toStringAsFixed(6)}, '
        '${marker.position.longitude.toStringAsFixed(6)}',
      );

      result.add(marker);
    }
    return result;
  }

  Future<BitmapDescriptor> _loadMonsterIcon(
    MonsterModel monster,
    int frameNumber,
  ) async {
    final animatedFolder = _animatedFolderName(monster);
    if (animatedFolder != null &&
        !_missingAnimatedFolders.contains(animatedFolder)) {
      final animatedKey = '${monster.id}:frame:$frameNumber';
      final cachedAnimatedIcon = _monsterIconCache[animatedKey];
      if (cachedAnimatedIcon != null) return cachedAnimatedIcon;

      final animatedPath =
          'assets/images/fairy_four_parts/$animatedFolder/$frameNumber.png';
      try {
        final icon = await _bitmapDescriptorFromAsset(animatedPath);
        _monsterIconCache[animatedKey] = icon;
        return icon;
      } catch (error) {
        debugPrint('[MonsterMarkers] 動畫精靈圖載入失敗: $animatedPath, $error');
        _missingAnimatedFolders.add(animatedFolder);
      }
    }

    final staticKey = '${monster.id}:static';
    final cachedStaticIcon = _monsterIconCache[staticKey];
    if (cachedStaticIcon != null) return cachedStaticIcon;

    try {
      final icon = await _bitmapDescriptorFromAsset(monster.imageURL);
      _monsterIconCache[staticKey] = icon;
      return icon;
    } catch (error) {
      debugPrint('[MonsterMarkers] 靜態精靈圖載入失敗: ${monster.imageURL}, $error');
      // 圖示載入失敗時 fallback 為綠色預設 pin
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromAsset(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    final resizedBytes = await _resizePng(
      bytes,
      _markerBitmapSize,
      _markerBitmapSize,
    );
    return BitmapDescriptor.bytes(
      resizedBytes,
      width: _markerDisplaySize,
      height: _markerDisplaySize,
    );
  }

  Future<Uint8List> _resizePng(Uint8List bytes, int width, int height) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: width,
      targetHeight: height,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      throw StateError('無法將精靈圖片轉成 PNG bytes');
    }

    return byteData.buffer.asUint8List();
  }

  String? _animatedFolderName(MonsterModel monster) {
    final imageFileName = monster.imageURL.split('/').last;
    final extensionIndex = imageFileName.lastIndexOf('.');
    if (imageFileName.isEmpty || extensionIndex <= 0) return null;

    return imageFileName.substring(0, extensionIndex);
  }

  @override
  void dispose() {
    _nearbyMonsterWorker?.dispose();
    _stopMonsterAnimation();
    super.dispose();
  }
}
