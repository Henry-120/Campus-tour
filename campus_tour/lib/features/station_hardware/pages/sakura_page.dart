import 'dart:async';

import 'package:campus_tour/features/station_hardware/view_models/sakura_card_draft_view_model.dart';
import 'package:campus_tour/features/station_hardware/view_models/station_hardware_view_model.dart';
import 'package:campus_tour/features/station_hardware/widgets/sakura_card_view.dart';
import 'package:campus_tour/features/station_hardware/widgets/sakura_collection_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SakuraPage extends StatefulWidget {
  const SakuraPage({super.key});

  @override
  State<SakuraPage> createState() => _SakuraPageState();
}

class _SakuraPageState extends State<SakuraPage> {
  late final String _hardwareControllerTag;
  late final PageController _pageController;
  late final StationHardwareViewModel _hardwareViewModel;
  late final SakuraCardDraftViewModel _draftViewModel;

  @override
  void initState() {
    super.initState();
    _hardwareControllerTag = 'sakura-page-${identityHashCode(this)}';
    _pageController = PageController();
    _draftViewModel = SakuraCardDraftViewModel();
    _hardwareViewModel = Get.put(
      StationHardwareViewModel(),
      tag: _hardwareControllerTag,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _draftViewModel.dispose();
    unawaited(
      Get.delete<StationHardwareViewModel>(
        tag: _hardwareControllerTag,
        force: true,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: PageView(
        controller: _pageController,
        pageSnapping: true,
        physics: const PageScrollPhysics(),
        children: [
          SakuraCollectionView(
            hardwareViewModel: _hardwareViewModel,
            onNextPage: () => _goToPage(1),
          ),
          SakuraCardView(
            hardwareViewModel: _hardwareViewModel,
            draftViewModel: _draftViewModel,
            onPreviousPage: () => _goToPage(0),
          ),
        ],
      ),
    );
  }

  void _goToPage(int page) {
    if (!_pageController.hasClients) return;
    unawaited(
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      ),
    );
  }
}
