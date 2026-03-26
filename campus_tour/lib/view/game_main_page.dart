import 'package:flutter/material.dart';
import '../widgets/sections/game_hud_overlay.dart';
import '../widgets/game/character.dart';
import '../widgets/game/game_map.dart';
import '../services/audio_service.dart';

class GameMainPage extends StatefulWidget {
  const GameMainPage({super.key});

  @override
  State<GameMainPage> createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  Future<void> _playIntro() async {
    await AudioService().play(
      fileName: 'audio/intro.mp3',
      volume: 1.0,
      isLooping: false, // 通常 Intro 只播一次
    );
  }

  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 背景層 (未來放 Google Map)
          GameMap(),

          // 2. UI 層
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const GameHudOverlay(), // 呼叫剛建立的 Section
                  const Spacer(),
                  const Character(), // 呼叫中間的小人
                  const Spacer(flex: 2), // 讓下方留白多一點，平衡視覺
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}