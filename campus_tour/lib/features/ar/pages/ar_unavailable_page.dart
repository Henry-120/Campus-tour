import 'package:campus_tour/features/ar/services/ar_support_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ArUnavailablePage extends StatelessWidget {
  const ArUnavailablePage({super.key, required this.result, this.onRetry});

  final ArSupportResult result;
  final VoidCallback? onRetry;

  String get _title => switch (result.status) {
    ArSupportStatus.installationRequested =>
      'features.ar.pages.ar.unavailable.page.s001'.tr,
    ArSupportStatus.unsupportedDevice =>
      'features.ar.pages.ar.unavailable.page.s002'.tr,
    ArSupportStatus.permissionDenied ||
    ArSupportStatus.permissionPermanentlyDenied =>
      'features.ar.pages.ar.unavailable.page.s003'.tr,
    ArSupportStatus.restricted =>
      'features.ar.pages.ar.unavailable.page.s004'.tr,
    ArSupportStatus.unavailablePlatform =>
      'features.ar.pages.ar.unavailable.page.s005'.tr,
    _ => 'features.ar.pages.ar.unavailable.page.s006'.tr,
  };

  String get _message => switch (result.status) {
    ArSupportStatus.installationRequested =>
      'features.ar.pages.ar.unavailable.page.s007'.tr,
    ArSupportStatus.unsupportedDevice =>
      'features.ar.pages.ar.unavailable.page.s008'.tr,
    ArSupportStatus.permissionDenied =>
      'features.ar.pages.ar.unavailable.page.s009'.tr,
    ArSupportStatus.permissionPermanentlyDenied =>
      'features.ar.pages.ar.unavailable.page.s010'.tr,
    ArSupportStatus.restricted =>
      'features.ar.pages.ar.unavailable.page.s011'.tr,
    ArSupportStatus.unavailablePlatform =>
      'features.ar.pages.ar.unavailable.page.s012'.tr,
    _ => result.details ?? 'features.ar.pages.ar.unavailable.page.s013'.tr,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('features.ar.pages.ar.unavailable.page.s014'.tr),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.view_in_ar_outlined, size: 72),
                const SizedBox(height: 20),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(_message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                if (result.canOpenSettings)
                  FilledButton.icon(
                    onPressed: openAppSettings,
                    icon: const Icon(Icons.settings),
                    label: Text(
                      'features.ar.pages.ar.unavailable.page.s015'.tr,
                    ),
                  )
                else if (onRetry != null)
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'features.ar.pages.ar.unavailable.page.s016'.tr,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
