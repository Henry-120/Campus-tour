import 'package:flutter/material.dart';

import '../../services/audio_service.dart';
import '../constants/responsive.dart';

class StartButton extends StatefulWidget {
  final String label;
  final Widget destination;

  const StartButton({
    super.key,
    required this.label,
    required this.destination,
  });

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    AudioService().play(
      fileName: 'audio/startSFX.mp3',
      volume: 1.0,
      isLooping: false,
    );

    await _controller.forward();
    await _controller.reverse();

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => widget.destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    // 以你的手機畫面為基準，不會因為網頁變超大
    final buttonWidth = 500 * scale;
    final buttonHeight = buttonWidth * (80 / 200);

    return GestureDetector(
      onTap: _handleStart,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: Image.asset(
            'assets/images/component/start_button.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}