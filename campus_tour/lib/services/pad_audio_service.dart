import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// 取得 Android install-time Play Asset Pack 內的音樂。
class PadAudioService {
  PadAudioService._();

  static const MethodChannel _channel = MethodChannel(
    'tw.edu.ncu.campustour/pad_audio',
  );

  static Future<Source> getSource(String assetPath) async {
    final normalizedPath = assetPath.replaceAll('\\', '/');
    final pathSegments = normalizedPath.split('/');

    if (!normalizedPath.startsWith('music/') ||
        pathSegments.any((segment) => segment.isEmpty || segment == '..')) {
      throw ArgumentError.value(assetPath, 'assetPath', '必須是 music/ 底下的相對路徑');
    }

    final devicePath = await _channel.invokeMethod<String>(
      'prepareAudioAsset',
      <String, String>{'assetPath': normalizedPath},
    );

    if (devicePath == null || devicePath.isEmpty) {
      throw PlatformException(
        code: 'PAD_AUDIO_PATH_MISSING',
        message: 'Android 未回傳音樂檔案路徑：$normalizedPath',
      );
    }

    return DeviceFileSource(devicePath);
  }
}
