import 'package:campus_tour/styles/level_style.dart';
import 'package:campus_tour/widgets/game/catching_pages/strategy_book_level.dart';
import 'package:flutter/material.dart';

class StrategyBookLevelPage extends StatelessWidget {
  const StrategyBookLevelPage({
    super.key,
    required this.level,
    required this.nextFunction,
  });

  final StrategyBookLevel level;
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
            level.title,
            style: LevelStyle.titleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LevelStyle.bodySpacing),
          _buildStrategyBookImage(),
          const SizedBox(height: LevelStyle.bodySpacing),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildStrategyBookImage() {
    final imagePath = level.imagePath.trim();

    // [L-03]
    if (imagePath.isEmpty) {
      return _buildBookImageFrame(child: _buildImageFallback());
    }

    // [L-04]
    return _buildBookImageFrame(
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildImageFallback(),
      ),
    );
  }

  Widget _buildBookImageFrame({required Widget child}) {
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
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: Colors.black.withValues(alpha: 0.58),
              child: Text(
                level.noteText,
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
    // [L-06]
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: nextFunction,
        child: Text(level.buttonText),
      ),
    );
  }

  Widget _buildImageFallback() {
    // [L-07]
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: LevelStyle.imagePlaceholderDecoration,
      child: Icon(
        Icons.menu_book_rounded,
        size: 72,
        color: LevelStyle.imageIconColor,
      ),
    );
  }
}
