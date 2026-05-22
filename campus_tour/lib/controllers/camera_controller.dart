import 'package:camera/camera.dart';

class ArCameraController {
  CameraController? _controller;
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first, // 預設使用主鏡頭
      // 💡 優化 1: 改用 high (1080p)，流暢度會大幅提升，對手機螢幕預覽已非常足夠
      ResolutionPreset.high,
      enableAudio: false,
      // 💡 優化 2: 在 iOS 上 bgra8888 的預覽效能遠高於 jpeg
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    _isInitialized = true;
  }

  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    return await _controller!.takePicture();
  }

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }
}
