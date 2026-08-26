import 'package:cloud_firestore/cloud_firestore.dart';

/// Stations supported by the station hardware feature.
enum StationId {
  sakura('sakura');

  const StationId(this.wireName);

  final String wireName;
}

/// Events supported by the station hardware MQTT protocol.
enum MqttEventType {
  scanSuccess('scan_success'),
  arrival('arrival'),
  storyUnlocked('story_unlocked'),
  challengeComplete('challenge_complete');

  const MqttEventType(this.wireName);

  final String wireName;
}

/// Page-owned input accepted by the station hardware feature.
///
/// Page data belongs here instead of in an arbitrary map. The MQTT adapter can
/// deliberately choose which fields are ready to cross the backend boundary.
class StationHardwareInput {
  const StationHardwareInput({this.message = ''});

  final String message;
}

/// MQTT data assembled from trusted application state and page-owned input.
class MqttEventData {
  MqttEventData({required String displayName})
    : displayName = _normalizeDisplayName(displayName);

  factory MqttEventData.fromInput({
    required StationHardwareInput input,
    required String displayName,
  }) {
    return MqttEventData(displayName: displayName);
  }

  final String displayName;

  Map<String, Object?> toJson() => {'displayName': displayName};

  static String _normalizeDisplayName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        'displayName',
        'Display name is required',
      );
    }

    return normalized;
  }
}

/// A read-only view of the current user's `HardwareDevice` document.
///
/// [lastTriggerTime] gives callers a normalized UTC value, while [rawData]
/// preserves every Firestore field so newly added hardware data remains
/// accessible before it receives a dedicated typed property.
class HardwareDeviceData {
  HardwareDeviceData._({
    required this.lastTriggerTime,
    required Map<String, dynamic> rawData,
  }) : rawData = Map<String, dynamic>.unmodifiable(rawData);

  final DateTime? lastTriggerTime;
  final Map<String, dynamic> rawData;

  factory HardwareDeviceData.fromMap(Map<String, dynamic> data) {
    final rawLastTriggerTime = data['lastTriggerTime'];
    final DateTime? lastTriggerTime;

    if (rawLastTriggerTime == null) {
      lastTriggerTime = null;
    } else if (rawLastTriggerTime is Timestamp) {
      lastTriggerTime = rawLastTriggerTime.toDate().toUtc();
    } else if (rawLastTriggerTime is DateTime) {
      lastTriggerTime = rawLastTriggerTime.toUtc();
    } else {
      throw const FormatException(
        'HardwareDevice.lastTriggerTime must be a Timestamp or DateTime',
      );
    }

    return HardwareDeviceData._(
      lastTriggerTime: lastTriggerTime,
      rawData: Map<String, dynamic>.from(data),
    );
  }
}
