import 'package:campus_tour/widgets/sections/start_menu_group.dart';
import 'package:flutter/material.dart';
import '../widgets/common/start_background.dart'; // 開始頁面背景 
import '../services/audio_service.dart'; // 撥放器
import '../styles/app_theme.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    
    AudioService().play(
      fileName: 'audio/BGM.mp3',
      isBgm: true,
      isLooping: true,
      volume: 0.65,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService().pauseBgm(); 
      debugPrint("App 進入背景，音樂已暫停");
    } 
    else if (state == AppLifecycleState.resumed) {
      AudioService().resumeBgm();
      debugPrint("歡迎回來，音樂繼續播放");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StartBackground(imagePath: 'assets/images/Arcana_Background.jpg'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.horizontalPadding, 
            ),
            child: const Center(
              child: StartMenuGroup(),
            ),
          ),
        ]
      )
    );
  }
}