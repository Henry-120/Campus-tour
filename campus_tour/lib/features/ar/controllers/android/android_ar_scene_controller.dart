import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Commands and native events for one Android AR PlatformView instance.
class AndroidArSceneController {
  static const _channelPrefix = 'campus_tour/arcore_scene_';

  MethodChannel? _channel;

  void Function()? onReady;
  void Function()? onPlaneDetected;
  void Function()? onModelPlaced;
  void Function(String message)? onError;

  bool get isAttached => _channel != null;

  void attach(int viewId) {
    final channel = MethodChannel('$_channelPrefix$viewId');
    _channel = channel;
    channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> clearModel() async {
    await _channel?.invokeMethod<void>('clearModel');
  }

  Future<bool> setModel(String arRef) async {
    final channel = _channel;
    if (channel == null) return false;
    return await channel.invokeMethod<bool>('setModel', <String, String>{
          'arRef': arRef,
        }) ??
        false;
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onReady':
        onReady?.call();
        return;
      case 'onPlaneDetected':
        onPlaneDetected?.call();
        return;
      case 'onModelPlaced':
        onModelPlaced?.call();
        return;
      case 'onError':
        onError?.call(
          call.arguments?.toString() ??
              'features.ar.controllers.android.android.ar.scene.controller.s001'
                  .tr,
        );
        return;
    }
  }

  void detach() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
  }

  void dispose() {
    detach();
    onReady = null;
    onPlaneDetected = null;
    onModelPlaced = null;
    onError = null;
  }
}
