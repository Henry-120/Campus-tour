import 'dart:async';

import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/level_style.dart';
import 'package:flutter/material.dart';

class BattleStartTransition extends StatefulWidget {
  const BattleStartTransition({
    super.key,
    required this.monsterImagePath,
    required this.monsterType,
    required this.playerImagePath,
    required this.onClosed,
    required this.onFinished,
  });

  final String monsterImagePath;
  final String monsterType;
  final String playerImagePath;
  final VoidCallback onClosed;
  final VoidCallback onFinished;

  @override
  State<BattleStartTransition> createState() => _BattleStartTransitionState();
}

class _BattleStartTransitionState extends State<BattleStartTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  bool _hasCalledClosed = false;
  bool _hasCalledFinished = false;

  @override
  void initState() {
    super.initState();
    // [L-01]
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    // [L-02]
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    // [L-03]
    unawaited(_runTransition());
  }

  @override
  void dispose() {
    // [L-04]
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runTransition() async {
    // [L-05]
    await _controller.forward();
    // [L-06]
    if (!mounted) {
      return;
    }

    // [L-07]
    _callClosedOnce();
    // [L-08]
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // [L-09]
    if (!mounted) {
      return;
    }

    // [L-10]
    await _controller.reverse();
    // [L-11]
    if (!mounted) {
      return;
    }

    // [L-12]
    _callFinishedOnce();
  }

  void _callClosedOnce() {
    // [L-13]
    if (_hasCalledClosed) {
      return;
    }

    // [L-14]
    _hasCalledClosed = true;
    // [L-15]
    widget.onClosed();
  }

  void _callFinishedOnce() {
    // [L-16]
    if (_hasCalledFinished) {
      return;
    }

    // [L-17]
    _hasCalledFinished = true;
    // [L-18]
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    // [L-19]
    return Positioned.fill(
      child: AbsorbPointer(
        child: AnimatedBuilder(
          animation: _curve,
          builder: (context, child) {
            // [L-20]
            final progress = _curve.value;
            // [L-21]
            final monsterTheme = LevelStyle.battleThemeForType(
              widget.monsterType,
            );
            // [L-22]
            return Stack(
              fit: StackFit.expand,
              children: [
                _SlidingBattlePanel(
                  progress: progress,
                  isTopPanel: true,
                  imagePath: widget.monsterImagePath,
                  backgroundColors: [
                    monsterTheme.primary,
                    monsterTheme.secondary,
                  ],
                ),
                _SlidingBattlePanel(
                  progress: progress,
                  isTopPanel: false,
                  imagePath: widget.playerImagePath,
                  backgroundColors: const [
                    AppTheme.accentColor,
                    AppTheme.primaryColor,
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlidingBattlePanel extends StatelessWidget {
  const _SlidingBattlePanel({
    required this.progress,
    required this.isTopPanel,
    required this.imagePath,
    required this.backgroundColors,
  });

  final double progress;
  final bool isTopPanel;
  final String imagePath;
  final List<Color> backgroundColors;

  @override
  Widget build(BuildContext context) {
    // [L-23]
    final size = MediaQuery.sizeOf(context);
    // [L-24]
    final travelX = size.width * 1.05;
    // [L-25]
    final travelY = size.height * 0.18;
    // [L-26]
    final offset = Offset(
      isTopPanel ? -travelX * (1 - progress) : travelX * (1 - progress),
      isTopPanel ? -travelY * (1 - progress) : travelY * (1 - progress),
    );

    // [L-27]
    return Transform.translate(
      offset: offset,
      child: ClipPath(
        clipper: _BattlePanelClipper(isTopPanel: isTopPanel),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isTopPanel ? Alignment.topLeft : Alignment.bottomRight,
              end: isTopPanel ? Alignment.bottomRight : Alignment.topLeft,
              colors: backgroundColors,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.18,
                  child: _TransitionImage(imagePath: imagePath),
                ),
              ),
              Align(
                alignment: isTopPanel
                    ? const Alignment(-0.35, -0.58)
                    : const Alignment(0.34, 0.42),
                child: FractionallySizedBox(
                  widthFactor: 0.42,
                  heightFactor: 0.34,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _TransitionImage(imagePath: imagePath),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransitionImage extends StatelessWidget {
  const _TransitionImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    // [L-28]
    final trimmedPath = imagePath.trim();
    // [L-29]
    final isNetworkImage =
        trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://');

    // [L-30]
    if (trimmedPath.isEmpty) {
      return const Icon(Icons.auto_awesome, color: Colors.white);
    }

    // [L-31]
    return isNetworkImage
        ? Image.network(
            trimmedPath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.auto_awesome, color: Colors.white),
          )
        : Image.asset(
            trimmedPath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.auto_awesome, color: Colors.white),
          );
  }
}

class _BattlePanelClipper extends CustomClipper<Path> {
  const _BattlePanelClipper({required this.isTopPanel});

  final bool isTopPanel;

  @override
  Path getClip(Size size) {
    // [L-32]
    final diagonalStart = size.height * 0.48;
    // [L-33]
    final diagonalEnd = size.height * 0.34;

    // [L-34]
    if (isTopPanel) {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, diagonalEnd)
        ..lineTo(0, diagonalStart)
        ..close();
    }

    // [L-35]
    return Path()
      ..moveTo(0, diagonalStart)
      ..lineTo(size.width, diagonalEnd)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _BattlePanelClipper oldClipper) {
    // [L-36]
    return oldClipper.isTopPanel != isTopPanel;
  }
}
