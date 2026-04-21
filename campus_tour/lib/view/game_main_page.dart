import 'package:flutter/material.dart';
import '../widgets/game/user_hud.dart';
import '../widgets/sections/game_hud_overlay.dart';
import '../widgets/game/character.dart';
import '../widgets/game/game_map.dart';
import '../widgets/game/control_buttons.dart';
import '../widgets/game/main_bottom_menu.dart';
import '../widgets/common/scale_button.dart';
import '../services/audio_service.dart';
import 'package:get/get.dart';
import '../controllers/monster_controller.dart';
import 'package:campus_tour/widgets/common/LHF_Drawer.dart';

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
    return Scaffold(
      drawer: AppDrawer(),
      body: Stack(
        children: [
          const GameMap(),

          // 2. 左上角：使用者頭像與狀態
          const Positioned(
            top: 50,
            left: 20,
            child: ScaleButton(
              onTap: null, // UserHud 內部已有點擊邏輯
              child: UserHud(),
            ),
          ),

          // 3. 右上角：控制按鈕 (定位、圖層)
          const Positioned(
            top: 50,
            right: 20,
            child: ControlButtons(),
          ),

          // 4. 中間：角色小人
          const Center(
            child: Character(),
          ),

          // 5. 下方：主選單
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: MainBottomMenu(),
          ),
        ],
      ),
    );
  }
}
