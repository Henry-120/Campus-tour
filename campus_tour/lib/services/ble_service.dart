import 'package:campus_tour/config/esp32_scheme.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';

enum BleResult { found, permissionDenied, bluetoothOff, notFound, opps }

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final String _serviceUuid = Esp32BLE_info.ID;
  final int _rssiThreshold = Esp32BLE_info.DISTANT;
  final int watingSeconds = 10;

  Future<bool> checkPermissions() async {
    // Check and request permissions for BLE
    PermissionStatus scan = await Permission.bluetoothScan.request();
    PermissionStatus connect = await Permission.bluetoothConnect.request();
    PermissionStatus locationStatus = await Permission.location.request();

    if (scan.isGranted && connect.isGranted && locationStatus.isGranted) {
      // Permissions granted
      return true;
    } else {
      // Handle permission denial
      return false;
    }
  }

  Future<bool> isBluetoothOn() async {
    // Check if Bluetooth is on
    final status = await _ble.statusStream.first;
    return status == BleStatus.ready;
  }

  Future<BleResult> scanForDevice() async {
    //--------------------------------------------------
    // 權限檢查
    //--------------------------------------------------

    if (!await checkPermissions()) {
      return BleResult.permissionDenied;
    }

    //--------------------------------------------------
    // 藍牙檢查
    //--------------------------------------------------
    if (!await isBluetoothOn()) {
      return BleResult.bluetoothOff;
    }
    return await _afterPreparation();
  }

  Future<BleResult> _afterPreparation() async {
    final completer = Completer<BleResult>();

    StreamSubscription<DiscoveredDevice>? subscription;

    subscription = _ble
        .scanForDevices(
          withServices: [Uuid.parse(_serviceUuid)],
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          (device) {
            debugPrint("Found: ${device.name}, RSSI: ${device.rssi}");
            if (device.name == Esp32BLE_info.NAME &&
                device.rssi >= _rssiThreshold) {
              if (!completer.isCompleted) completer.complete(BleResult.found);
            }
          },
          onError: (e) {
            if (!completer.isCompleted) {
              completer.complete(BleResult.opps);
            }
          },
        );

    Future.delayed(Duration(seconds: watingSeconds), () {
      if (!completer.isCompleted) {
        completer.complete(BleResult.notFound);
      }
    });

    final result = await completer.future;

    await subscription.cancel();

    return result;
  }
}
