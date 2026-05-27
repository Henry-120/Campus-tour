import 'package:flutter/material.dart';
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
  Set<Marker> _monsterMarkers = {};

  /// GameMap 的 markers 參數直接 spread 這個 getter
  Set<Marker> get monsterMarkers => _monsterMarkers;

  /// 在 initState 呼叫，開始用 ever() 監聽 nearbyMonsters 的變化。
  /// [onTap] 是點擊怪物 Marker 時的回呼，通常傳入 _handleMonsterCapture。
  void listenToNearbyMonsters(void Function(MonsterModel) onTap) {
    debugPrint('[MarkerDebug] 開始監聽 nearbyMonsters');
    ever(_monsterController.nearbyMonsters, (monsters) async {
      debugPrint('[MarkerDebug] nearbyMonsters 變化，數量: ${monsters.length}');
      final markers = await _buildMonsterMarkers(
        List<MonsterModel>.from(monsters),
        onTap,
      );
      debugPrint('[MarkerDebug] 建立完成 Marker 數量: ${markers.length}');
      if (mounted) {
        setState(() => _monsterMarkers = markers);
        debugPrint('[MarkerDebug] setState 完成，目前 monsterMarkers 數量: ${_monsterMarkers.length}');
      } 
      else {
        debugPrint('[MarkerDebug] widget 已經 unmounted，沒有 setState');
      }
    });
  }

  Future<Set<Marker>> _buildMonsterMarkers(
    List<MonsterModel> monsters,
    void Function(MonsterModel) onTap,
  ) async {
    final result = <Marker>{};
    debugPrint('[MarkerDebug] 準備建立 Marker，monsters 數量: ${monsters.length}');
    for (final m in monsters) {
      debugPrint(
        '[MarkerDebug] 建立 Marker: '
        'name=${m.name}, '
        'id=${m.id}, '
        'lat=${m.location.latitude.toStringAsFixed(6)}, '
        'lng=${m.location.longitude.toStringAsFixed(6)}, '
        'imageURL=${m.imageURL}',
      );

      final icon = await _loadMonsterIcon(m);

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

  // Future<BitmapDescriptor> _loadMonsterIcon(MonsterModel monster) async {
  //   debugPrint('[MarkerDebug] 使用固定預設 Marker: ${monster.name}');

  //   return BitmapDescriptor.defaultMarkerWithHue(
  //     BitmapDescriptor.hueGreen,
  //   );
  // }

  // 這個有問題
  Future<BitmapDescriptor> _loadMonsterIcon(MonsterModel monster) async {
    if (_monsterIconCache.containsKey(monster.id)) {
      debugPrint('[MarkerDebug] 使用快取 icon: ${monster.name}');
      return _monsterIconCache[monster.id]!;
    }
    try {
      debugPrint('[MarkerDebug] 載入 icon 開始: path=${monster.imageURL}');
      final stopwatch = Stopwatch()..start();  // ADD
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(64, 64)),
        monster.imageURL,
        width: 128,
        height: 128,
      );
      stopwatch.stop();  // ADD
      _monsterIconCache[monster.id] = icon;
      debugPrint(
        '[MarkerDebug] icon 載入成功: '
        'name=${monster.name}, '
        'path=${monster.imageURL}, '
        '耗時=${stopwatch.elapsedMilliseconds}ms, '
        'runtimeType=${icon.runtimeType}, '
        '快取大小=${_monsterIconCache.length}',
      );
      return icon;
    } catch (e, stack) {
      debugPrint(
        '[MarkerDebug] icon 載入失敗: '
        'name=${monster.name}, '
        'path=${monster.imageURL}, '
        'error=$e',
      );
      debugPrint('[MarkerDebug] stack: $stack');
      // 圖示載入失敗時 fallback 為綠色預設 pin
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }
}
