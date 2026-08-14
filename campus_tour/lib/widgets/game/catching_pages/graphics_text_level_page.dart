import 'package:campus_tour/styles/level_style.dart';
import 'package:campus_tour/widgets/buttons/nfc_button.dart';
import 'package:campus_tour/widgets/game/catching_pages/discovered_item_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/services/audio_service.dart';

import 'package:get/get.dart';

class GraphicsTextLevelPage extends StatefulWidget {
  const GraphicsTextLevelPage({
    super.key,
    required this.level,
    required this.nextFunction,
    required this.loseingFunction,
  });

  final GraphicsTextLevel level;
  final VoidCallback nextFunction;
  final VoidCallback loseingFunction;

  @override
  State<GraphicsTextLevelPage> createState() => _GraphicsTextLevelPageState();
}

class _GraphicsTextLevelPageState extends State<GraphicsTextLevelPage>
    with WidgetsBindingObserver {
  static const String _nfcTeachingGifPath = 'assets/images/nfc_teaching.gif';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioService().playOverlayBgm(fileName: 'audio/M06_find_monster.wav');
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
    WidgetsBinding.instance.removeObserver(this);
    AudioService().stopOverlayBgm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundImage(),
          Container(color: Colors.black.withValues(alpha: 0.2)),
          SafeArea(
            minimum: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'widgets.game.catching.pages.graphics.text.level.page.s001'
                        .tr,
                    style: LevelStyle.titleStyle.copyWith(
                      color: Colors.white,
                      shadows: LevelStyle.plotTextShadows,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTeachingButton(),
                      const SizedBox(width: 8),
                      _buildAbandonButton(),
                    ],
                  ),
                ),
                Align(
                  alignment: const Alignment(1, 0.68),
                  child: FilledButton.icon(
                    onPressed: _showStoryReviewDialog,
                    icon: const Icon(Icons.menu_book_rounded),
                    label: Text(
                      'widgets.game.catching.pages.graphics.text.level.page.s008'
                          .tr,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: NfcButton1(
                    ans: widget.level.nfcId,
                    onResult: _handleNfcSuccess,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachingButton() {
    return _buildTopIconButton(
      child: IconButton(
        tooltip: 'widgets.game.catching.pages.graphics.text.level.page.s005'.tr,
        icon: const Icon(Icons.help_outline_rounded),
        color: Colors.white,
        onPressed: _showNfcTeachingDialog,
      ),
    );
  }

  Widget _buildAbandonButton() {
    return _buildTopIconButton(
      child: IconButton(
        tooltip: 'widgets.game.catching.pages.graphics.text.level.page.s004'.tr,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.expand(),
        icon: const Icon(Icons.close_rounded),
        color: Colors.white,
        iconSize: 26,
        onPressed: _showAbandonDialog,
      ),
    );
  }

  Future<void> _showAbandonDialog() async {
    final shouldAbandon = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        content: Text(
          'widgets.game.catching.pages.graphics.text.level.page.s003'.tr,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('widgets.buttons.click.and.accept.button.s001'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('widgets.buttons.click.and.accept.button.s002'.tr),
          ),
        ],
      ),
    );

    if (shouldAbandon == true && mounted) {
      widget.loseingFunction();
    }
  }

  Widget _buildTopIconButton({required Widget child}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  void _showNfcTeachingDialog() {
    // [L-06]
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel:
          'widgets.game.catching.pages.graphics.text.level.page.s006'.tr,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      pageBuilder: (dialogContext, _, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(dialogContext).pop(),
          child: SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(28),
                padding: const EdgeInsets.all(10),
                constraints: BoxConstraints(maxWidth: 360, maxHeight: 520),
                decoration: BoxDecoration(
                  color: LevelStyle.frameColor,
                  borderRadius: LevelStyle.innerCardRadius,
                  border: Border.all(color: LevelStyle.borderColor, width: 1.4),
                  boxShadow: LevelStyle.softShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  _nfcTeachingGifPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _buildImageFallback(),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 160),
    );
  }

  void _handleNfcSuccess() {
    final discoveredItem = widget.level.discoveredItem;

    // [L-07]
    if (discoveredItem == null) {
      widget.nextFunction();
      return;
    }

    // [L-08]
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: discoveredItem.title,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      pageBuilder: (dialogContext, _, _) {
        return DiscoveredItemPage(
          item: discoveredItem,
          nextFunction: () {
            // [L-09]
            Navigator.of(dialogContext).pop();
            widget.nextFunction();
          },
        );
      },
      transitionBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 220),
    );
  }

  Widget _buildBackgroundImage() {
    final trimmedPath = widget.level.firstTracePhoto?.trim() ?? '';
    if (trimmedPath.isEmpty) return _buildImageFallback();
    final isNetworkImage =
        trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://');
    return isNetworkImage
        ? Image.network(
            trimmedPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildImageFallback(),
          )
        : Image.asset(
            trimmedPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildImageFallback(),
          );
  }

  void _showStoryReviewDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'widgets.game.catching.pages.graphics.text.level.page.s008'.tr,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: widget.level.storyReviewSteps.isEmpty
              ? Text(
                  'widgets.game.catching.pages.graphics.text.level.page.s007'
                      .tr,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.level.storyReviewSteps.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final step = widget.level.storyReviewSteps[index];
                    final hasSpeaker =
                        step.speakerSlot != PlotSpeakerSlot.narrator &&
                        step.speakerName.trim().isNotEmpty;
                    return Text(
                      hasSpeaker
                          ? '${step.speakerName}：${step.text}'
                          : step.text,
                      style: LevelStyle.descriptionStyle.copyWith(fontSize: 18),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'widgets.game.catching.pages.graphics.text.level.page.s009'.tr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback() {
    // [L-18]
    return Container(
      decoration: LevelStyle.imagePlaceholderDecoration,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 72,
          color: LevelStyle.imageIconColor,
        ),
      ),
    );
  }
}
