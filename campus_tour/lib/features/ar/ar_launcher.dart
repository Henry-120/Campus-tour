import 'package:campus_tour/features/ar/pages/android/ar_support_gate_page.dart';
import 'package:campus_tour/features/ar/pages/ar_unavailable_page.dart';
import 'package:campus_tour/features/ar/pages/ios/ar_placement_page.dart';
import 'package:campus_tour/features/ar/services/ar_support_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// AR 功能的唯一公開入口。
///
abstract final class ArLauncher {
  static Future<void> open(BuildContext context) async {
    final page = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => const IosArPlacementPage(),
      TargetPlatform.android => const AndroidArSupportGatePage(),
      _ => const ArUnavailablePage(
        result: ArSupportResult(ArSupportStatus.unavailablePlatform),
      ),
    };

    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }
}
