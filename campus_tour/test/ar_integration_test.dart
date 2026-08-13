import 'package:campus_tour/features/ar/models/ar_model_config.dart';
import 'package:campus_tour/features/ar/pages/android/ar_support_status.dart';
import 'package:campus_tour/features/ar/services/ar_support_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android AR model catalog', () {
    test('maps Firestore squirrel USDZ reference to the bundled GLB', () {
      final config = ArModelConfig.fromArRef('models\\squirrel.usdz');

      expect(config, isNotNull);
      expect(config!.androidAssetPath, 'ar/models/monsters/squirrel.glb');
      expect(config.targetHeightMeters, 0.08);
    });

    test('does not expose models missing from the Android catalog', () {
      expect(ArModelConfig.fromArRef('Elephant.usdz'), isNotNull);
      expect(ArModelConfig.fromArRef('YMCA.usdz'), isNull);
      expect(ArModelConfig.fromArRef(''), isNull);
      expect(ArModelConfig.fromArRef(null), isNull);
    });
  });

  group('AR support mapping', () {
    test('recognizes installed and install-required ARCore states', () {
      expect(
        AndroidArSupportStatus.fromPlatformValue('SUPPORTED_INSTALLED'),
        AndroidArSupportStatus.supportedInstalled,
      );
      expect(
        AndroidArSupportStatus.fromPlatformValue(
          'SUPPORTED_NOT_INSTALLED',
        ).needsInstall,
        isTrue,
      );
      expect(
        AndroidArSupportStatus.fromPlatformValue(
          'SUPPORTED_APK_TOO_OLD',
        ).needsInstall,
        isTrue,
      );
    });

    test('exposes the correct recovery actions', () {
      const ready = ArSupportResult(ArSupportStatus.ready);
      const denied = ArSupportResult(
        ArSupportStatus.permissionPermanentlyDenied,
      );
      const install = ArSupportResult(ArSupportStatus.installationRequested);

      expect(ready.canStart, isTrue);
      expect(denied.canOpenSettings, isTrue);
      expect(install.canRetry, isTrue);
    });
  });
}
