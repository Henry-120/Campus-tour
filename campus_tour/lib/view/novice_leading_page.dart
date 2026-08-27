import 'package:campus_tour/styles/novice_leading_style.dart';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

import 'package:get/get.dart';

class NoviceLeadingPage extends StatefulWidget {
  const NoviceLeadingPage({super.key, this.onFinish});

  final VoidCallback? onFinish;

  @override
  State<NoviceLeadingPage> createState() => _NoviceLeadingPageState();
}

class _NoviceLeadingPageState extends State<NoviceLeadingPage>
    with WidgetsBindingObserver {
  // [L-01]
  static List<_NoviceLeadingStep> get _steps => [
    _NoviceLeadingStep.image(
      imageAsset: 'assets/images/novice_leading/squirrel.JPG',
      message: 'view.novice.leading.page.s001'.tr,
      textAlignment: Alignment.bottomCenter,
    ),
    _NoviceLeadingStep.image(
      imageAsset: 'assets/images/novice_leading/avatar.JPG',
      message: 'view.novice.leading.page.s002'.tr,
      textAlignment: Alignment.bottomCenter,
    ),
    _NoviceLeadingStep.image(
      imageAsset: 'assets/images/novice_leading/avatar_chageing.JPG',
      message: 'view.novice.leading.page.s003'.tr,
      textAlignment: Alignment.bottomCenter,
    ),
    _NoviceLeadingStep.image(
      imageAsset: 'assets/images/novice_leading/arrow.JPG',
      message: 'view.novice.leading.page.s004'.tr,
      textAlignment: Alignment.topCenter,
    ),
    _NoviceLeadingStep.image(
      imageAsset: 'assets/images/novice_leading/elf.JPG',
      message: 'view.novice.leading.page.s005'.tr,
      textAlignment: Alignment.topCenter,
    ),
    _NoviceLeadingStep.plot(message: 'view.novice.leading.page.s006'.tr),
    _NoviceLeadingStep.image(
      imageAsset: 'assets/images/novice_leading/encyclopedia.JPG',
      message: 'view.novice.leading.page.s007'.tr,
      textAlignment: Alignment.topCenter,
    ),
    _NoviceLeadingStep.image(
      imageAsset: 'assets/images/novice_leading/encylopedia_col.JPG',
      message: 'view.novice.leading.page.s008'.tr,
      textAlignment: Alignment.bottomCenter,
    ),
    _NoviceLeadingStep.image(
      imageAsset: 'assets/images/novice_leading/story.JPG',
      message: 'view.novice.leading.page.s009'.tr,
      textAlignment: Alignment.topCenter,
    ),
    _NoviceLeadingStep.finish(message: 'view.novice.leading.page.s010'.tr),
  ];

  // [L-02]
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService().playOverlayBgm(track: AudioTrack.tutorial);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService().pauseAllBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioService().resumeAllBgm();
    }
  }

  @override
  void dispose() {
    // [L-03]
    WidgetsBinding.instance.removeObserver(this);
    AudioService().stopOverlayBgm();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // [L-04]
    return Scaffold(
      backgroundColor: NoviceLeadingStyle.backgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // [L-05]
        onTap: _handlePageTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // [L-06]
            PageView.builder(
              controller: _pageController,
              itemCount: _steps.length,
              // [L-07]
              onPageChanged: _updateCurrentIndex,
              itemBuilder: (context, index) {
                // [L-08]
                return _buildStepPage(_steps[index]);
              },
            ),
            // [L-09]
            _buildSkipButton(),
            // [L-10]
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPage(_NoviceLeadingStep step) {
    // [L-11]
    switch (step.kind) {
      case _NoviceLeadingStepKind.image:
        return _buildImagePage(step);
      case _NoviceLeadingStepKind.plot:
        return _buildPlotLevelPage(step);
      case _NoviceLeadingStepKind.finish:
        return _buildFinishPage(step);
    }
  }

  Widget _buildImagePage(_NoviceLeadingStep step) {
    // [L-12]
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(step.imageAsset!, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: NoviceLeadingStyle.imageShadeGradient,
          ),
        ),
        Align(
          alignment: step.textAlignment,
          child: Padding(
            padding: NoviceLeadingStyle.textPanelMargin,
            child: _InstructionPanel(message: step.message),
          ),
        ),
      ],
    );
  }

  Widget _buildPlotLevelPage(_NoviceLeadingStep step) {
    // [L-13]
    return DecoratedBox(
      decoration: BoxDecoration(gradient: NoviceLeadingStyle.plotGradient),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: NoviceLeadingStyle.textPanelMargin,
            child: Text(
              step.message,
              style: NoviceLeadingStyle.plotTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishPage(_NoviceLeadingStep step) {
    // [L-14]
    return DecoratedBox(
      decoration: BoxDecoration(gradient: NoviceLeadingStyle.finishGradient),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: NoviceLeadingStyle.textPanelMargin,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step.message,
                  style: NoviceLeadingStyle.finishTextStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28),
                ElevatedButton(
                  // [L-15]
                  onPressed: _finishTutorial,
                  style: NoviceLeadingStyle.finishButtonStyle,
                  child: Text(
                    'view.novice.leading.page.s011'.tr,
                    style: NoviceLeadingStyle.finishButtonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    // [L-16]
    if (_isLastPage) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: NoviceLeadingStyle.skipPadding,
          child: TextButton(
            // [L-17]
            onPressed: _finishTutorial,
            style: NoviceLeadingStyle.textButtonStyle,
            child: Text(
              'view.novice.leading.page.s012'.tr,
              style: NoviceLeadingStyle.actionTextStyle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    // [L-18]
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: NoviceLeadingStyle.navigationPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                // [L-19]
                onPressed: _currentIndex == 0 ? null : _goPrevious,
                style: NoviceLeadingStyle.textButtonStyle,
                child: Text(
                  'view.novice.leading.page.s013'.tr,
                  style: _currentIndex == 0
                      ? NoviceLeadingStyle.disabledActionTextStyle
                      : NoviceLeadingStyle.actionTextStyle,
                ),
              ),
              if (!_isLastPage)
                TextButton(
                  // [L-20]
                  onPressed: _goNext,
                  style: NoviceLeadingStyle.textButtonStyle,
                  child: Text(
                    'view.novice.leading.page.s014'.tr,
                    style: NoviceLeadingStyle.actionTextStyle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePageTap() {
    // [L-21]
    if (_isLastPage) {
      return;
    }

    _goNext();
  }

  void _goNext() {
    // [L-22]
    if (_isLastPage) {
      return;
    }

    _goToPage(_currentIndex + 1);
  }

  void _goPrevious() {
    // [L-23]
    if (_currentIndex == 0) {
      return;
    }

    _goToPage(_currentIndex - 1);
  }

  void _goToPage(int index) {
    // [L-24]
    final int targetIndex = index.clamp(0, _steps.length - 1);
    _pageController.animateToPage(
      targetIndex,
      duration: NoviceLeadingStyle.pageTurnDuration,
      curve: NoviceLeadingStyle.pageTurnCurve,
    );
  }

  void _updateCurrentIndex(int index) {
    // [L-25]
    setState(() {
      _currentIndex = index;
    });
  }

  void _finishTutorial() {
    // [L-26]
    if (widget.onFinish != null) {
      widget.onFinish!();
      return;
    }

    // [L-27]
    Navigator.maybePop(context);
  }

  bool get _isLastPage {
    // [L-28]
    return _currentIndex == _steps.length - 1;
  }
}

class _InstructionPanel extends StatelessWidget {
  const _InstructionPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    // [L-29]
    return DecoratedBox(
      decoration: BoxDecoration(
        color: NoviceLeadingStyle.textPanelColor,
        borderRadius: NoviceLeadingStyle.textPanelRadius,
      ),
      child: Padding(
        padding: NoviceLeadingStyle.textPanelPadding,
        child: Text(
          message,
          style: NoviceLeadingStyle.instructionTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

enum _NoviceLeadingStepKind { image, plot, finish }

class _NoviceLeadingStep {
  const _NoviceLeadingStep.image({
    required this.imageAsset,
    required this.message,
    required this.textAlignment,
  }) : kind = _NoviceLeadingStepKind.image;

  const _NoviceLeadingStep.plot({required this.message})
    : kind = _NoviceLeadingStepKind.plot,
      imageAsset = null,
      textAlignment = Alignment.center;

  const _NoviceLeadingStep.finish({required this.message})
    : kind = _NoviceLeadingStepKind.finish,
      imageAsset = null,
      textAlignment = Alignment.center;

  final _NoviceLeadingStepKind kind;
  final String? imageAsset;
  final String message;
  final Alignment textAlignment;
}
