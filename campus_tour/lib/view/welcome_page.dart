import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'game_main_page.dart'; // 跳轉至遊戲主頁

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with WidgetsBindingObserver {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startBgm();
  }

  Future<void> _startBgm() async {
    await _bgmPlayer.setSource(AssetSource('audio/BGM.mp3'));
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.65);
    await _bgmPlayer.resume();
  }

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
          Image.asset('assets/images/Arcana_Background.jpg', 
            width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: .4)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Campus Tour", 
                  style: GoogleFonts.zcoolQingKeHuangYou(
                    fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold,
                    shadows: [const Shadow(color: Colors.pinkAccent, blurRadius: 10)]
                  )),
                const SizedBox(height: 60),
                GestureDetector(
                  onTapDown: (_) => setState(() => _buttonScale = 1.2),
                  onTapUp: (_) async {
                    setState(() => _buttonScale = 1.0);
                    _sfxPlayer.play(AssetSource('audio/startSFX.mp3'));
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (!context.mounted) return;
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GameMainPage()));
                  },
                  child: AnimatedScale(
                    scale: _buttonScale,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.pink.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text("START", style: GoogleFonts.zcoolQingKeHuangYou(fontSize: 26, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}