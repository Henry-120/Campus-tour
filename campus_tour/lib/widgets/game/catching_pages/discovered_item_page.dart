import 'package:campus_tour/styles/level_style.dart';
import 'package:campus_tour/widgets/game/catching_pages/discovered_item.dart';
import 'package:flutter/material.dart';

class DiscoveredItemPage extends StatelessWidget {
  const DiscoveredItemPage({
    super.key,
    required this.item,
    required this.nextFunction,
  });

  final DiscoveredItem item;
  final VoidCallback nextFunction;

  @override
  Widget build(BuildContext context) {
    // [L-01]
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: LevelStyle.pageHorizontalPadding,
              vertical: LevelStyle.pageVerticalPadding,
            ),
            child: _buildDialogCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogCard() {
    // [L-02]
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(22),
      decoration: LevelStyle.mainCardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.title,
            style: LevelStyle.titleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LevelStyle.bodySpacing),
          _buildItemImage(),
          const SizedBox(height: LevelStyle.bodySpacing),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildItemImage() {
    final imagePath = item.imagePath.trim();

    // [L-03]
    if (imagePath.isEmpty) {
      return _buildItemImageFrame(child: _buildImageFallback());
    }

    // [L-04]
    return _buildItemImageFrame(
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildImageFallback(),
      ),
    );
  }

  Widget _buildItemImageFrame({required Widget child}) {
    // [L-05]
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220, maxHeight: 320),
      decoration: LevelStyle.imageCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (item.noteText.trim().isNotEmpty)
            // [L-06]
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                color: Colors.black.withValues(alpha: 0.58),
                child: Text(
                  item.noteText,
                  style: LevelStyle.hintStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    // [L-07]
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: nextFunction,
        child: Text(item.buttonText),
      ),
    );
  }

  Widget _buildImageFallback() {
    // [L-08]
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: LevelStyle.imagePlaceholderDecoration,
      child: Center(
        child: Icon(
          item.fallbackIcon,
          size: 88,
          color: LevelStyle.imageIconColor,
          shadows: [
            Shadow(
              color: LevelStyle.imageIconColor.withValues(alpha: 0.95),
              blurRadius: 28,
            ),
            Shadow(color: Colors.white.withValues(alpha: 0.7), blurRadius: 46),
          ],
        ),
      ),
    );
  }
}
