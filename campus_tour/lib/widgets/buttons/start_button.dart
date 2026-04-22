import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

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

class _StartButtonState extends State<StartButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      MaterialPageRoute(builder: (context) => widget.destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 獲取螢幕寬度以進行響應式設計
    final screenWidth = MediaQuery.of(context).size.width;

    // 💡 設定按鈕寬度 (例如佔螢幕寬度的 65%)
    final buttonWidth = screenWidth * 1.5;
    // 💡 保持圖片比例
    final buttonHeight = buttonWidth * (80 / 200);

    return GestureDetector(
      onTap: _handleStart,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: const BoxDecoration(
            image: DecorationImage(
              // 💡 修正：明確指向 start_button.png
              image: AssetImage('assets/images/start_button.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
