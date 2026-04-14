import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMarker {
  final String markerId;
  final LatLng position;
  final BitmapDescriptor icon;
  final Offset anchor;
  final double rotation;
  final int zIndex;
  final bool visible;
  final bool flat;
  final InfoWindow infoWindow;
  final VoidCallback? onTap;

  const UserMarker({
    this.markerId = 'player_marker',
    required this.position,
    required this.icon,
    this.anchor = const Offset(0.5, 0.5),
    this.rotation = 0.0,
    this.zIndex = 0,
    this.visible = true,
    this.flat = false,
    this.infoWindow = InfoWindow.noText,
    this.onTap,
  });

  Marker toMarker() {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: icon,
      anchor: anchor,
      rotation: rotation,
      zIndexInt: zIndex,
      visible: visible,
      flat: flat,
      infoWindow: infoWindow,
      onTap: onTap,
    );
  }

  Set<Marker> toMarkerSet() => {toMarker()};

  UserMarker copyWith({
    String? markerId,
    LatLng? position,
    BitmapDescriptor? icon,
    Offset? anchor,
    double? rotation,
    int? zIndex,
    bool? visible,
    bool? flat,
    InfoWindow? infoWindow,
    VoidCallback? onTap,
  }) {
    return UserMarker(
      markerId: markerId ?? this.markerId,
      position: position ?? this.position,
      icon: icon ?? this.icon,
      anchor: anchor ?? this.anchor,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      visible: visible ?? this.visible,
      flat: flat ?? this.flat,
      infoWindow: infoWindow ?? this.infoWindow,
      onTap: onTap ?? this.onTap,
    );
  }
}