import 'package:campus_tour/features/ar/pages/android/ar_support_status.dart';
import 'package:campus_tour/features/ar/services/ar_support_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ArCoreSupportService implements ArSupportService {
  static const MethodChannel _channel = MethodChannel(
    'campus_tour/arcore_support',
  );
  static const int _availabilityAttempts = 6;

  @override
  Future<ArSupportResult> prepare() async {
    try {
      final availability = await _waitForAvailability();
      if (availability == AndroidArSupportStatus.unsupportedDevice) {
        return const ArSupportResult(ArSupportStatus.unsupportedDevice);
      }
      if (availability == AndroidArSupportStatus.error) {
        return ArSupportResult(
          ArSupportStatus.error,
          details:
              'features.ar.services.android.arcore.support.service.s001'.tr,
        );
      }
      if (availability == AndroidArSupportStatus.checking) {
        return const ArSupportResult(ArSupportStatus.checking);
      }

      if (availability.needsInstall) {
        final installStatus = await _channel.invokeMethod<String>(
          'requestInstall',
        );
        if (installStatus != 'INSTALLED') {
          return const ArSupportResult(ArSupportStatus.installationRequested);
        }
      }

      return _requestCameraPermission();
    } on PlatformException catch (error) {
      return ArSupportResult(
        ArSupportStatus.error,
        details: error.message ?? error.code,
      );
    } catch (error) {
      return ArSupportResult(ArSupportStatus.error, details: error.toString());
    }
  }

  Future<AndroidArSupportStatus> _waitForAvailability() async {
    var availability = AndroidArSupportStatus.checking;
    for (var attempt = 0; attempt < _availabilityAttempts; attempt++) {
      final value = await _channel.invokeMethod<String>('checkAvailability');
      availability = AndroidArSupportStatus.fromPlatformValue(value);
      if (availability != AndroidArSupportStatus.checking) {
        return availability;
      }
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    return availability;
  }

  Future<ArSupportResult> _requestCameraPermission() async {
    var permission = await Permission.camera.status;
    if (!permission.isGranted) {
      permission = await Permission.camera.request();
    }
    if (permission.isGranted) {
      return const ArSupportResult(ArSupportStatus.ready);
    }
    if (permission.isPermanentlyDenied) {
      return const ArSupportResult(ArSupportStatus.permissionPermanentlyDenied);
    }
    if (permission.isRestricted) {
      return const ArSupportResult(ArSupportStatus.restricted);
    }
    return const ArSupportResult(ArSupportStatus.permissionDenied);
  }
}
