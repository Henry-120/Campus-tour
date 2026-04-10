import 'package:campus_tour/controllers/NFC_api.dart';
import 'package:campus_tour/styles/level_style.dart';
import 'package:campus_tour/widgets/buttons/nfc_button.dart';
import 'package:campus_tour/widgets/game/catching_pages/graphics_text_level.dart';
import 'package:flutter/material.dart';

class GraphicsTextLevelPage extends StatefulWidget {
  const GraphicsTextLevelPage({
    super.key,
    required this.level,
    required this.nextFunction,
  });

  final GraphicsTextLevel level;
  final void Function(NfcScanResult result) nextFunction;

  @override
  State<GraphicsTextLevelPage> createState() => _GraphicsTextLevelPageState();
}

class _GraphicsTextLevelPageState extends State<GraphicsTextLevelPage> {
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
                        Text('探索關卡', style: LevelStyle.titleStyle),
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
              ],
            ),
          ),
        ),
      ),
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
