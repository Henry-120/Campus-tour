import 'dart:async';
import 'package:flutter/material.dart';

import '../widgets/common/start_background.dart';
import '../widgets/sections/start_menu_group.dart';
import '../services/audio_service.dart';
import '../widgets/constants/responsive.dart';

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
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: StartBackground(
              key: ValueKey(_currentIndex),
              imagePath: _images[_currentIndex],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 46 * scale,
              ),
              child: const StartMenuGroup(),
            ),
          ),
        ],
      ),
    );
  }
}