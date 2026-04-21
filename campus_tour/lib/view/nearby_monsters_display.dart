import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/monster_controller.dart';
import '../../models/monster_model.dart';
import '../../widgets/game/monster_marker.dart';

/// 提供給 GameMap 使用的 mixin，負責維護怪物 markers set。
///
/// 使用方式：
///   class _GameMapState extends State<GameMap> with MonsterMarkersMixin {
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
    ever(_monsterController.nearbyMonsters, (monsters) async {
      final markers = await _buildMonsterMarkers(
        List<MonsterModel>.from(monsters),
        onTap,
      );
      if (mounted) {
        setState(() => _monsterMarkers = markers);
      }
    });
  }

  Future<Set<Marker>> _buildMonsterMarkers(
    List<MonsterModel> monsters,
    void Function(MonsterModel) onTap,
  ) async {
    final result = <Marker>{};
    for (final m in monsters) {
      final icon = await _loadMonsterIcon(m);
      result.add(
        MonsterMarker(monster: m, icon: icon, onTap: () => onTap(m)).toMarker(),
      );
    }
    return result;
  }

  Future<BitmapDescriptor> _loadMonsterIcon(MonsterModel monster) async {
    if (_monsterIconCache.containsKey(monster.id)) {
      return _monsterIconCache[monster.id]!;
    }
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(64, 64)),
        monster.imageURL,
        width: 64,
        height: 64,
      );
      _monsterIconCache[monster.id] = icon;
      return icon;
    } catch (_) {
      // 圖示載入失敗時 fallback 為綠色預設 pin
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }
}