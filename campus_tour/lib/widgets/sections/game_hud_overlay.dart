import 'package:flutter/material.dart';
import '../game/user_hud.dart';
import '../game/system_menu.dart';

class GameHudOverlay extends StatelessWidget {
  const GameHudOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserHud(),     // 來自 lib/widgets/game/
        SystemMenu(),  // 來自 lib/widgets/game/
      ],
    );
  }
}