import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../controllers/camera_controller.dart';
import '../../controllers/fairy_video_controller.dart';
import '../../widgets/common/fairy_video.dart';
import '../../widgets/buttons/capture_button.dart';
import '../../services/camera_service.dart';


class ArCapturePage extends StatefulWidget {
  const ArCapturePage({super.key});

  @override
  State<ArCapturePage> createState() => _ArCapturePageState();
}

class _ArCapturePageState extends State<ArCapturePage> {
  final ArCameraController _cameraController = ArCameraController();
  final ArVideoController _videoController = ArVideoController();

  @override
  void initState() {
    super.initState();
    _startArMode();
  }

  Future<void> _startArMode() async {
    // 同時啟動相機與影片
    await Future.wait([
      _cameraController.initCamera(),
      _videoController.initVideo('assets/videos/monster.mp4'),
    ]);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // 記得都要釋放
    _cameraController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.isInitialized || !_videoController.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 呼叫相機零件
          CameraPreview(_cameraController.controller!),

          // 呼叫你抽出去的自定義 Widget 零件
          FairyVideoWidget(controller: _videoController.controller!),

          // 呼叫按鈕零件
          _buildCaptureButton(),
        ],
      ),
    );
  }


  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 50,
      child: CaptureButton( // 這是你放在 widgets/buttons 的組件
        onPressed: () async {
          final photo = await _cameraController.takePicture();
          if (photo != null) {
            CameraService().handleCapturedPath(photo.path);
            // 可以加個震動回饋或跳轉
          }
        },
      ),
    );
  }
}