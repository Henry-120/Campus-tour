import 'package:campus_tour/widgets/game/catching_pages/discovered_item_page.dart';
import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';
import 'package:flutter/material.dart';

class PlotLevelPage extends StatefulWidget {
  final PlotLevel plotLevel;
  final VoidCallback nextFunction;

  const PlotLevelPage({
    super.key,
    required this.plotLevel,
    required this.nextFunction,
  });

  @override
  State<PlotLevelPage> createState() => _PlotLevelPageState();
}

class _PlotLevelPageState extends State<PlotLevelPage> {
  int _currentStepIndex = 0;
  bool _hasCalledNext = false;

  @override
  void initState() {
    super.initState();

    if (widget.plotLevel.isPassed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _callNextFunction());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plotLevel.isPassed) {
      return const SizedBox.shrink();
    }

    final step = _currentStep;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advanceStory,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            Container(color: PlotLevelPageStyle.overlayColor),
            SafeArea(
              child: Stack(
                children: [
                  _buildSkipButton(),
                  _buildSpriteStage(step),
                  _buildDialogueBox(step),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PlotDialogueStep get _currentStep {
    return widget.plotLevel.dialogueSteps[_currentStepIndex];
  }

  Widget _buildBackground() {
    return Image.asset(
      PlotLevel.backgroundImageForType(widget.plotLevel.type),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(color: PlotLevelPageStyle.fallbackBackgroundColor);
      },
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: PlotLevelPageStyle.skipPadding,
        child: TextButton(
          onPressed: _callNextFunction,
          style: PlotLevelPageStyle.skipButtonStyle,
          child: Text(
            PlotLevel.passLevel,
            style: PlotLevelPageStyle.skipTextStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildSpriteStage(PlotDialogueStep step) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideWidth =
            constraints.maxWidth * PlotLevelPageStyle.sideSpriteWidthFactor;
        final sideHeight =
            constraints.maxHeight * PlotLevelPageStyle.sideSpriteHeightFactor;
        final centerWidth =
            constraints.maxWidth * PlotLevelPageStyle.centerSpriteWidthFactor;
        final centerHeight =
            constraints.maxHeight * PlotLevelPageStyle.centerSpriteHeightFactor;

        return Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: _buildSprite(
                keyValue: 'left-${widget.plotLevel.leftCharacter.spritePath}',
                imagePath: widget.plotLevel.leftCharacter.spritePath,
                isVisible: step.showLeftSprite,
                isActive: step.speakerSlot == PlotSpeakerSlot.left,
                maxWidth: sideWidth,
                maxHeight: sideHeight,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _buildSprite(
                keyValue: 'right-${widget.plotLevel.rightCharacter.spritePath}',
                imagePath: widget.plotLevel.rightCharacter.spritePath,
                isVisible: step.showRightSprite,
                isActive: step.speakerSlot == PlotSpeakerSlot.right,
                maxWidth: sideWidth,
                maxHeight: sideHeight,
              ),
            ),
            if (step.showsCenterSprite)
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildSprite(
                  keyValue: 'center-${step.centerSpritePath}',
                  imagePath: step.centerSpritePath!,
                  isVisible: true,
                  isActive: step.speakerSlot == PlotSpeakerSlot.center,
                  maxWidth: centerWidth,
                  maxHeight: centerHeight,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSprite({
    required String keyValue,
    required String imagePath,
    required bool isVisible,
    required bool isActive,
    required double maxWidth,
    required double maxHeight,
  }) {
    if (!isVisible || imagePath.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final opacity = isActive
        ? PlotLevelPageStyle.activeSpriteOpacity
        : PlotLevelPageStyle.inactiveSpriteOpacity;

    final sprite = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );

    return AnimatedOpacity(
      key: ValueKey(keyValue),
      opacity: opacity,
      duration: PlotLevel.spriteSwitchDuration,
      child: AnimatedScale(
        scale: isActive ? 1 : 0.96,
        duration: PlotLevel.spriteSwitchDuration,
        curve: Curves.easeOutCubic,
        child: isActive
            ? sprite
            : ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xAA000000),
                  BlendMode.srcATop,
                ),
                child: sprite,
              ),
      ),
    );
  }

  Widget _buildDialogueBox(PlotDialogueStep step) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: PlotLevelPageStyle.dialoguePadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PlotLevelPageStyle.dialogueMaxWidth,
            minHeight: PlotLevelPageStyle.dialogueMinHeight,
          ),
          child: DecoratedBox(
            decoration: PlotLevelPageStyle.dialogueBoxDecoration,
            child: Padding(
              padding: PlotLevelPageStyle.dialogueContentPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSpeakerName(step),
                  AnimatedSwitcher(
                    duration: PlotLevel.dialogueSwitchDuration,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Text(
                      step.text,
                      key: ValueKey('dialogue-$_currentStepIndex-${step.text}'),
                      style: PlotLevelPageStyle.descriptionStyle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _BlinkingPressText(text: _pressText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeakerName(PlotDialogueStep step) {
    if (step.speakerSlot == PlotSpeakerSlot.narrator ||
        step.speakerName.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: PlotLevelPageStyle.speakerNameBottomSpacing,
      ),
      child: Text(step.speakerName, style: PlotLevelPageStyle.speakerNameStyle),
    );
  }

  String get _pressText {
    if (_currentStepIndex < widget.plotLevel.dialogueSteps.length - 1) {
      return PlotLevel.press;
    }

    return widget.plotLevel.type == PlotLevel.battleType
        ? PlotLevel.pressBattle
        : PlotLevel.press;
  }

  void _advanceStory() {
    if (_hasCalledNext) {
      return;
    }

    if (_currentStepIndex < widget.plotLevel.dialogueSteps.length - 1) {
      setState(() => _currentStepIndex++);
      return;
    }

    _callNextFunction();
  }

  void _callNextFunction() {
    if (_hasCalledNext) {
      return;
    }

    _hasCalledNext = true;
    final discoveredItem = widget.plotLevel.discoveredItem;

    // [L-01]
    if (discoveredItem == null || widget.plotLevel.isPassed) {
      widget.nextFunction();
      return;
    }

    // [L-02]
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: discoveredItem.title,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      pageBuilder: (dialogContext, _, _) {
        return DiscoveredItemPage(
          item: discoveredItem,
          nextFunction: () {
            // [L-03]
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
      transitionDuration: const Duration(milliseconds: 220),
    );
  }
}

class _BlinkingPressText extends StatefulWidget {
  const _BlinkingPressText({required this.text});

  final String text;

  @override
  State<_BlinkingPressText> createState() => _BlinkingPressTextState();
}

class _BlinkingPressTextState extends State<_BlinkingPressText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PlotLevel.pressBlinkDuration,
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.35,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        widget.text,
        style: PlotLevelPageStyle.pressTextStyle,
        textAlign: TextAlign.right,
      ),
    );
  }
}
