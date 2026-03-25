import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/buttons/start_button.dart';
import 'game_main_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with WidgetsBindingObserver {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 監聽 App 生命週期
    _startBgm();
  }

  Future<void> _startBgm() async {
    await _bgmPlayer.setSource(AssetSource('audio/BGM.mp3'));
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.65);
    await _bgmPlayer.resume();
  }

  // 處理 App 進入背景或回到前景的音樂切換
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      _bgmPlayer.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 背景層
          Image.asset(
            'assets/images/Arcana_Background.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.4)), // 遮罩層

          // 2. 內容層
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Campus Tour",
                  style: GoogleFonts.zcoolQingKeHuangYou(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.pinkAccent, blurRadius: 10, offset: Offset(2, 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // 使用抽離出來的 StartButton 組件
                StartButton(
                  onPressed: () async {
                    _sfxPlayer.play(AssetSource('audio/startSFX.mp3'));
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const GameMainPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}