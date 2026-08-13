import 'package:campus_tour/features/ar/pages/android/ar_placement_page.dart';
import 'package:campus_tour/features/ar/pages/ar_support_gate_page.dart';
import 'package:campus_tour/features/ar/services/android/arcore_support_service.dart';
import 'package:flutter/material.dart';

class AndroidArSupportGatePage extends StatelessWidget {
  const AndroidArSupportGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArSupportGatePage(
      service: ArCoreSupportService(),
      destinationBuilder: (_) => const AndroidArPlacementPage(),
    );
  }
}
