import 'dart:convert';
import 'dart:math';

import 'package:campus_tour/config/esp32_scheme.dart';
import 'package:campus_tour/features/station_hardware/models/station_hardware_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// Base type for errors intentionally exposed by [MqttService].
sealed class MqttServiceException implements Exception {
  const MqttServiceException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Authentication is missing or changed while an event was being prepared.
final class MqttAuthenticationException extends MqttServiceException {
  const MqttAuthenticationException({
    String message = 'User is not authenticated',
    Object? cause,
  }) : super(message, cause);
}

/// The MQTT broker connection could not be established.
final class MqttConnectionException extends MqttServiceException {
  const MqttConnectionException([Object? cause])
    : super('MQTT connection failed', cause);
}

/// An MQTT event could not be encoded or published.
final class MqttPublishException extends MqttServiceException {
  const MqttPublishException([Object? cause])
    : super('MQTT publish failed', cause);
}

class MqttService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final String _clientId;
  bool get isConnected =>
      _client.connectionStatus?.state == MqttConnectionState.connected;
  bool get isConnecting => _connectFuture != null;

  Future<bool>? _connectFuture;
  Object? _lastConnectionError;
  late final MqttServerClient _client;

  MqttService() {
    _clientId = _generateClientId();

    _client = MqttServerClient.withPort(
      Esp32MQTT_info.BROKER_ADDRESS,
      _clientId,
      Esp32MQTT_info.PORT,
    );
    _client.secure = true;
    _client.logging(on: false);
  }

  String _generateClientId() {
    // 將時間轉成較短的 36 進位字串
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);

    // 產生 6 位十六進位隨機碼
    final randomPart = Random.secure()
        .nextInt(0x1000000)
        .toRadixString(16)
        .padLeft(6, '0');

    return '${Esp32MQTT_info.CLIENT}_${timestamp}_$randomPart';
  }

  Future<bool> connect() {
    if (isConnected) {
      return Future<bool>.value(true);
    }

    final pendingConnection = _connectFuture;
    if (pendingConnection != null) return pendingConnection;

    late final Future<bool> connectionAttempt;
    connectionAttempt = _connectClient().whenComplete(() {
      if (identical(_connectFuture, connectionAttempt)) {
        _connectFuture = null;
      }
    });
    _connectFuture = connectionAttempt;
    return connectionAttempt;
  }

  Future<bool> _connectClient() async {
    _lastConnectionError = null;

    try {
      await _client.connect(Esp32MQTT_info.USERNAME, Esp32MQTT_info.PASSWORD);
      return isConnected;
    } catch (error) {
      _lastConnectionError = error;
      debugPrint('[MQTT] Connect error: $error');
      return false;
    }
  }

  /// Publishes one event to the selected station with QoS 1.
  ///
  /// Throws [MqttAuthenticationException], [MqttConnectionException], or
  /// [MqttPublishException] so callers can handle each failure category.
  Future<void> sendStationEvent({
    required StationId stationId,
    required MqttEventType event,
    required MqttEventData data,
  }) async {
    if (!isConnected) {
      final success = await connect();

      if (!success) {
        throw MqttConnectionException(_lastConnectionError);
      }
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw const MqttAuthenticationException();
    }

    final String? token;
    try {
      token = await user.getIdToken();
    } catch (error) {
      throw MqttAuthenticationException(
        message: 'Unable to obtain Firebase ID token',
        cause: error,
      );
    }

    if (token == null || token.isEmpty) {
      throw const MqttAuthenticationException(
        message: 'Unable to obtain Firebase ID token',
      );
    }

    if (_auth.currentUser?.uid != user.uid) {
      throw const MqttAuthenticationException(
        message: 'Authentication session changed during MQTT publish',
      );
    }

    try {
      final eventData = data.toJson();
      const protectedFields = {'idToken', 'event'};
      final conflictingFields = eventData.keys
          .where(protectedFields.contains)
          .toList(growable: false);

      if (conflictingFields.isNotEmpty) {
        throw ArgumentError(
          'MQTT event data cannot override protected fields: '
          '${conflictingFields.join(', ')}',
        );
      }

      final topic = 'campustour/${stationId.wireName}/checkin';
      final message = jsonEncode({
        'idToken': token,
        'event': event.wireName,
        ...eventData,
      });

      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      final payload = builder.payload;
      if (payload == null) {
        throw StateError('MQTT payload is empty');
      }

      _client.publishMessage(topic, MqttQos.atLeastOnce, payload);
    } catch (error) {
      throw MqttPublishException(error);
    }
  }

  /// Explicitly closes the broker connection owned by this service instance.
  void disconnect() {
    final state = _client.connectionStatus?.state;
    if (state == null || state == MqttConnectionState.disconnected) return;

    _client.disconnect();
  }
}
