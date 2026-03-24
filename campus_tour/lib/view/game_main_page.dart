import 'package:flutter/material.dart';
import '../widgets/sections/game_hud_overlay.dart';
import '../widgets/game/character.dart';

class GameMainPage extends StatelessWidget {
  const GameMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 背景層 (未來放 Google Map)
          Container(color: Colors.blueGrey[50]),

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