import 'dart:convert';
import 'dart:math';

import 'package:campus_tour/config/esp32_scheme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static const Set<String> _supportedEvents = {
    'scan_success',
    'arrival',
    'story_unlock',
    'challenge_clear',
  };

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final String _clientId;
  bool get isConnected =>
      _client.connectionStatus?.state == MqttConnectionState.connected;
  bool isConnecting = false;
  late final MqttServerClient _client;

  MqttService() {
    _clientId = _generateClientId();

    _client = MqttServerClient.withPort(
      Esp32MqttInfo.brokerAddress,
      _clientId,
      Esp32MqttInfo.port,
    );
    _client.secure = true;
    _client.logging(on: false);
  }
  Future<String?> get _idToken async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return user.getIdToken();
  }

  String _generateClientId() {
    // 將時間轉成較短的 36 進位字串
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);

    // 產生 6 位十六進位隨機碼
    final randomPart = Random.secure()
        .nextInt(0x1000000)
        .toRadixString(16)
        .padLeft(6, '0');

    return '${Esp32MqttInfo.client}_${timestamp}_$randomPart';
  }

  Future<bool> connect() async {
    if (isConnected || isConnecting) {
      return isConnected;
    }
    try {
      isConnecting = true;
      await _client.connect(Esp32MqttInfo.username, Esp32MqttInfo.password);
      return isConnected;
    } catch (e) {
      debugPrint('[MQTT] Connect error: $e');
      return isConnected;
    } finally {
      isConnecting = false;
    }
  }

  Future<void> sendStationEvent({
    required String stationId,
    String event = 'scan_success',
  }) async {
    if (!_supportedEvents.contains(event)) {
      throw ArgumentError.value(event, 'event', 'Unsupported MQTT event');
    }

    if (!isConnected) {
      final success = await connect();

      if (!success) {
        throw Exception('MQTT connection failed');
      }
    }

    final token = await _idToken;
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final topic = 'campustour/$stationId/checkin';
    final message = jsonEncode({'idToken': token, 'event': event});

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}
