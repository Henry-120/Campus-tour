import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:campus_tour/config/esp32_scheme.dart';
import 'package:flutter/material.dart';

class MqttService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool get isConnected =>
      _client.connectionStatus?.state == MqttConnectionState.connected;
  bool isConnecting = false;
  final _client = MqttServerClient.withPort(
    Esp32MQTT_info.BROKER_ADDRESS,
    Esp32MQTT_info.CLIENT,
    Esp32MQTT_info.PORT,
  );
  MqttService() {
    _client.logging(on: true);
  }
  Future<String?> get _idToken async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return user.getIdToken();
  }

  Future<bool> connect() async {
    if (isConnected || isConnecting) {
      return isConnected;
    }
    try {
      isConnecting = true;

      await _client.connect();
      return isConnected;
    } catch (e) {
      debugPrint('[MQTT] Connect error: $e');
      return isConnected;
    } finally {
      isConnecting = false;
    }
  }

  Future<void> sendMessageWithToken(String actionID) async {
    if (!isConnected) {
      final success = await connect();

      if (!success) {
        throw Exception("MQTT connection failed");
      }
    }
    final token = await _idToken;
    if (token == null) {
      throw Exception("User not authenticated");
    }
    final message = jsonEncode({
      'action': 'play',
      'actionID': actionID,
      'token': token,
    });
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(
      Esp32MQTT_info.TOPIC,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }
}
