import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/monster_model.dart';

/// 封裝怪物在地圖上的 Marker，比照 UserMarker 的設計模式。
class MonsterMarker {
  final MonsterModel monster;
  final BitmapDescriptor icon;
  final VoidCallback? onTap;

  const MonsterMarker({
    required this.monster,
    required this.icon,
    this.onTap,
  });

  Marker toMarker() {
    return Marker(
      markerId: MarkerId('monster_${monster.id}'),
      position: LatLng(
        monster.location.latitude,
        monster.location.longitude,
      ),
      icon: icon,
      anchor: const Offset(0.5, 1.0), // 圖片底部對齊座標點
      infoWindow: InfoWindow(title: monster.name),
      onTap: onTap,
    );
  }
}