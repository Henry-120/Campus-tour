import 'package:campus_tour/widgets/game/system_menu.dart';
import 'package:flutter/material.dart';
import '../widgets/game/user_hud.dart';
import '../widgets/game/game_map.dart';
import '../widgets/common/scale_button.dart';
import '../services/audio_service.dart';
import 'package:campus_tour/widgets/common/drawer.dart';
import '../widgets/game/player_sprite.dart';
import '../widgets/game/nearest_monster_arrow.dart';
import '../widgets/constants/responsive.dart';

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
      isLooping: false,
    );
  }

  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        drawer: const AppDrawer(),
        drawerEnableOpenDragGesture: true,
        body: Stack(
          children: [
            const GameMap(),

            // 2. 左上角：使用者頭像與狀態
            Positioned(
              top: 50 * scale,
              left: 20 * scale,
              child: ScaleButton(
                onTap: null, // UserHud 內部已有點擊邏輯
                child: const UserHud(),
              ),
            ),

            // 4. 中間：松鼠
            Center(child: PlayerSprite(size: 90 * scale)),

            // 5. 中間：最近怪物箭頭
            const NearestMonsterArrow(),

            // 6. 下方：主選單
            Positioned(
              bottom: 30 * scale,
              left: 0,
              right: 0,
              child: const SystemMenu(),
            ),
          ],
        ),
      ),
    );
  }
}
