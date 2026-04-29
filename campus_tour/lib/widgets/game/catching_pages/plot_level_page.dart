import 'dart:async';

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
  final List<Timer> _timers = [];
  bool _showTitle = false;
  bool _showDescription = false;
  bool _showPress = false;
  bool _canContinue = false;
  bool _hasCalledNext = false;

  @override
  void initState() {
    super.initState();

    if (widget.plotLevel.isPassed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _callNextFunction());
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _showTitle = true);
      }
    });

    _timers.add(
      Timer(PlotLevel.titleFadeDuration + PlotLevel.sequenceDelay, () {
        if (mounted) {
          setState(() => _showDescription = true);
        }
      }),
    );

    _timers.add(
      Timer(
        PlotLevel.titleFadeDuration +
            PlotLevel.descriptionFadeDuration +
            PlotLevel.sequenceDelay * 2,
        () {
          if (mounted) {
            setState(() {
              _showPress = true;
              _canContinue = true;
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plotLevel.isPassed) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _canContinue ? _callNextFunction : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            Container(color: PlotLevelPageStyle.overlayColor),
            SafeArea(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: PlotLevelPageStyle.skipPadding,
                      child: TextButton(
                        onPressed: _callNextFunction,
                        style: PlotLevelPageStyle.skipButtonStyle,
                        child: const Text(
                          PlotLevel.passLevel,
                          style: PlotLevelPageStyle.skipTextStyle,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: PlotLevelPageStyle.contentPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedOpacity(
                            opacity: _showTitle ? 1 : 0,
                            duration: PlotLevel.titleFadeDuration,
                            child: Text(
                              widget.plotLevel.title,
                              style: PlotLevelPageStyle.titleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            height: PlotLevelPageStyle.descriptionTopSpacing,
                          ),
                          AnimatedOpacity(
                            opacity: _showDescription ? 1 : 0,
                            duration: PlotLevel.descriptionFadeDuration,
                            child: Text(
                              widget.plotLevel.description,
                              style: PlotLevelPageStyle.descriptionStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: PlotLevelPageStyle.pressPadding,
                      child: AnimatedOpacity(
                        opacity: _showPress ? 1 : 0,
                        duration: PlotLevel.descriptionFadeDuration,
                        child: _BlinkingPressText(
                          isActive: _showPress,
                          text: _pressText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  String get _pressText {
    return widget.plotLevel.type == PlotLevel.battleType
        ? PlotLevel.pressBattle
        : PlotLevel.press;
  }

  void _callNextFunction() {
    if (_hasCalledNext) {
      return;
    }

    _hasCalledNext = true;
    widget.nextFunction();
  }
}

class _BlinkingPressText extends StatefulWidget {
  const _BlinkingPressText({required this.isActive, required this.text});

  final bool isActive;
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
    );
    _opacity = Tween<double>(
      begin: 0.35,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _BlinkingPressText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
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
        textAlign: TextAlign.center,
      ),
    );
  }
}
