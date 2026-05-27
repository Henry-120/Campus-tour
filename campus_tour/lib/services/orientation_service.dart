import 'package:flutter/services.dart';

class OrientationService {
  const OrientationService._();

  static const List<DeviceOrientation> portraitOnly = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  static const List<DeviceOrientation> landscapeOnly = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static Future<void> lockPortrait() {
    return SystemChrome.setPreferredOrientations(portraitOnly);
  }

  static Future<void> lockLandscape() {
    return SystemChrome.setPreferredOrientations(landscapeOnly);
  }
}
