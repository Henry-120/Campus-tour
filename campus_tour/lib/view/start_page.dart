import 'dart:async';
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
  static const List<String> _images = [
    'assets/images/NCU/0.jpg',
    'assets/images/NCU/1.jpg',
    'assets/images/NCU/2.jpg',
    'assets/images/NCU/3.jpg',
    'assets/images/NCU/4.jpg',
    'assets/images/NCU/5.jpg',
    'assets/images/NCU/6.jpg',
    'assets/images/NCU/7.jpg',
    'assets/images/NCU/8.jpg',
    'assets/images/NCU/9.jpg',
  ];

  int _currentIndex = 0;
  Timer? _timer;

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

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService().pauseBgm(); 
      debugPrint("[StartPage]:App 進入背景，音樂已暫停");
    } 
    else if (state == AppLifecycleState.resumed) {
      AudioService().resumeBgm();
      debugPrint("[StartPage]:歡迎回來，音樂繼續播放");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000), // 淡出/淡入各 1 秒
            child: StartBackground(
              key: ValueKey(_currentIndex), // key 變了才會觸發動畫
              imagePath: _images[_currentIndex],
            ),
          ),
          // const StartBackground(imagePath: 'assets/images/NCU/0.jpg'),
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