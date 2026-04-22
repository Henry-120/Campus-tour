import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../view/login_page.dart';
import '../../styles/app_theme.dart';
// import '../../view/login_page.dart'; // 直接從登入頁開始

class StartButton extends StatefulWidget {
  final String label;           // 按鈕文字
  final Widget destination;     // 跳轉目標頁面
  const StartButton({
    super.key,
    required this.label,
    required this.destination,
  });

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  double _buttonScale = 1.0;

  Future<void> _handleStart() async {
    AudioService().play(
      fileName: 'audio/startSFX.mp3',
      volume: 1.0,
      isLooping: false,
    );
    
    setState(() => _buttonScale = 1.2);
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() => _buttonScale = 1.0);
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;
    debugPrint("[Debug][StartButton]:開始按鈕被按下，正在導航到 WelcomePage");
    Navigator.pushReplacement(
      context,
      // MaterialPageRoute(builder: (context) => const LoginPage()),
      MaterialPageRoute(builder: (context) => widget.destination), // 使用傳入的目標頁面
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _buttonScale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5
            )
          ]
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:AppTheme.primaryColor.withValues(alpha: 0.7),
            //backgroundColor: Color(0xFF64B5F6),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35), 
              side: const BorderSide(color: Colors.white, width: 2), 
            ),
          ),
          onPressed: _handleStart, // 💡 執行封裝好的邏輯
          child: Text(
            widget.label,
            style: AppTheme.buttonTextStyle,
          ),
        ),
      ),
    );
  }
}