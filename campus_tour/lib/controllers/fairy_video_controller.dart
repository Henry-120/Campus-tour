import 'package:video_player/video_player.dart';

class ArVideoController {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;


  Future<void> initVideo(String assetPath) async {
    _controller = VideoPlayerController.asset(assetPath);
    await _controller!.initialize();

    _controller!.setLooping(true); // 讓精靈一直動
    _controller!.play();
    _isInitialized = true;
  }

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }
}