import 'package:campus_tour/styles/level_style.dart';
import 'package:campus_tour/widgets/buttons/click_and_accept_button.dart';
import 'package:campus_tour/widgets/buttons/nfc_button.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';
import 'package:flutter/material.dart';

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

class _GraphicsTextLevelPageState extends State<GraphicsTextLevelPage> {
  static const String _nfcTeachingGifPath = 'assets/images/nfc_teaching.gif';

  @override
  Widget build(BuildContext context) {
    final hasImage =
        widget.level.firstTracePhoto != null &&
        widget.level.firstTracePhoto!.trim().isNotEmpty;
    final hasText =
        widget.level.descriptionText != null &&
        widget.level.descriptionText!.trim().isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: LevelStyle.pageDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LevelStyle.pageHorizontalPadding,
              vertical: LevelStyle.pageVerticalPadding,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: LevelStyle.mainCardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text('探索關卡', style: LevelStyle.titleStyle),
                            ),
                            _buildTeachingButton(),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('觀察線索後，前往指定地點感應 NFC', style: LevelStyle.hintStyle),
                        const SizedBox(height: LevelStyle.bodySpacing),
                        Expanded(
                          child: _buildBody(
                            hasImage: hasImage,
                            hasText: hasText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: LevelStyle.nfcButtonTopSpacing),
                NfcButton1(
                  ans: widget.level.nfcId,
                  onResult: widget.nextFunction,
                ),
                const SizedBox(height: 8),
                ClickAndAcceptButton(
                  movementFuntion: widget.loseingFunction,
                  accept_info: '是否確定放棄捕捉精靈?',
                  AppearanceIcon: Icons.close,
                  AppearanceText: '放棄捕捉',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeachingButton() {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: 'NFC 教學',
        icon: const Icon(Icons.help_outline_rounded),
        color: LevelStyle.imageIconColor,
        iconSize: 26,
        onPressed: _showNfcTeachingDialog,
      ),
    );
  }

  void _showNfcTeachingDialog() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '關閉 NFC 教學',
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
                constraints: const BoxConstraints(
                  maxWidth: 360,
                  maxHeight: 520,
                ),
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
      transitionDuration: const Duration(milliseconds: 160),
    );
  }

  Widget _buildBody({required bool hasImage, required bool hasText}) {
    if (hasImage && hasText) {
      return Column(
        children: [
          Expanded(child: _buildImageSection(widget.level.firstTracePhoto!)),
          const SizedBox(height: LevelStyle.panelSpacing),
          Expanded(child: _buildTextSection(widget.level.descriptionText!)),
        ],
      );
    }

    if (hasImage) {
      return _buildImageSection(widget.level.firstTracePhoto!);
    }

    if (hasText) {
      return _buildTextSection(widget.level.descriptionText!);
    }

    return _buildEmptySection();
  }

  Widget _buildImageSection(String imagePath) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: LevelStyle.sectionMinHeight),
      decoration: LevelStyle.imageCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: _buildAdaptiveImage(imagePath),
    );
  }

  Widget _buildAdaptiveImage(String imagePath) {
    final trimmedPath = imagePath.trim();
    final isNetworkImage =
        trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://');

    final image = isNetworkImage
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

    return SizedBox.expand(child: image);
  }

  Widget _buildTextSection(String text) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: LevelStyle.sectionMinHeight),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: LevelStyle.textCardDecoration,
      child: SingleChildScrollView(
        child: Center(
          child: Text(
            text,
            style: LevelStyle.descriptionStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: LevelStyle.sectionMinHeight),
      decoration: LevelStyle.imagePlaceholderDecoration,
      child: Center(
        child: Text('這個關卡目前沒有可顯示的內容', style: LevelStyle.placeholderStyle),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      decoration: LevelStyle.imagePlaceholderDecoration,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 72,
          color: LevelStyle.imageIconColor,
        ),
      ),
    );
  }
}
