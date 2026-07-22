import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../styles/app_theme.dart';

class CatchingFaildPage extends StatefulWidget {
  const CatchingFaildPage({super.key});

  @override
  State<CatchingFaildPage> createState() => _CatchingFaildPageState();
}

class _CatchingFaildPageState extends State<CatchingFaildPage> {
  late final VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/video/faiedl_anime.mp4',
    );
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await _videoController.initialize();
    await _videoController.setLooping(true);
    await _videoController.setVolume(1);
    await _videoController.play();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // if (_videoController.value.isInitialized)
                //   ConstrainedBox(
                //     constraints: const BoxConstraints(
                //       maxWidth: 320,
                //       maxHeight: 260,
                //     ),
                //     child: AspectRatio(
                //       aspectRatio: _videoController.value.aspectRatio,
                //       child: VideoPlayer(_videoController),
                //     ),
                //   )
                // else
                //   const SizedBox(
                //     width: 120,
                //     height: 120,
                //     child: Center(child: CircularProgressIndicator()),
                //   ),
                Image.asset(
                  'assets/images/failed_image/Fall_off_transparent2.png',
                  width: 320,
                  height: 260,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 24),
                Text(
                  'widgets.game.catching.pages.catching.faild.s001'.tr,
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'widgets.game.catching.pages.catching.faild.s002'.tr,
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 18,
                    color: Colors.black54,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'widgets.game.catching.pages.catching.faild.s003'.tr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
