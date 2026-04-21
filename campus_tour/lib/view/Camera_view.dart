import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../controllers/camera_controller.dart';
import '../../controllers/fairy_video_controller.dart';
import '../../widgets/common/fairy_video.dart';
import '../../widgets/buttons/capture_button.dart';
import '../../services/camera_service.dart';
import '../../view/photo_preview.dart';

class ArCapturePage extends StatefulWidget {
  const ArCapturePage({super.key});

  @override
  State<ArCapturePage> createState() => _ArCapturePageState();
}

class _ArCapturePageState extends State<ArCapturePage> {
  final ArCameraController _cameraController = ArCameraController();
  final ArVideoController _videoController = ArVideoController();
  final ScreenshotController _screenshotController = ScreenshotController();

  // 初始設定
  String currentFairyPath = 'assets/images/fairy_video/management.mp4';
  Alignment fairyPosition = Alignment.center;

  @override
  void initState() {
    super.initState();
    _startArMode();
  }

  Future<void> _startArMode() async {
    try {
      await _cameraController.initCamera();
      if (mounted) setState(() {});
    } catch (e) {
      print("相機初始化失敗: $e");
    }

    try {
      await _videoController.initVideo(currentFairyPath);
      if (mounted) setState(() {});
    } catch (e) {
      print("影片初始化失敗: $e");
    }
  }

  void changeFairy(String newPath, Alignment newPos) async {
    try {
      await _videoController.initVideo(newPath);
      if (mounted) {
        setState(() {
          currentFairyPath = newPath;
          fairyPosition = newPos;
        });
      }
    } catch (e) {
      print("更換精靈失敗: $e");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          //  使用 Screenshot 包住要拍下來的內容（相機 + 角色）
          Screenshot(
            controller: _screenshotController,
            child: Stack(
              children: [
                SizedBox.expand(
                  child: CameraPreview(_cameraController.controller!),
                ),
                if (_videoController.isInitialized)
                  FairyVideoWidget(
                    controller: _videoController.controller!,
                    alignment: fairyPosition,
                    width: 350,
                  ),
              ],
            ),
          ),

          //拍照按鈕放在 Screenshot 之外，以免按鈕本身出現在照片中
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: _buildCaptureButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return CaptureButton(
      onPressed: () async {
        try {
          // 使用截圖功能來同時拍到「相機畫面」與「精靈角色」
          final imageBytes = await _screenshotController.capture();

          if (imageBytes != null) {
            // 取得暫存目錄並將截圖存為檔案
            final directory = await getTemporaryDirectory();
            final String imagePath = '${directory.path}/ar_photo_${DateTime.now().millisecondsSinceEpoch}.png';
            final File imageFile = File(imagePath);
            await imageFile.writeAsBytes(imageBytes);

            // 跳轉到預覽頁面顯示拍好的照片
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoPreviewPage(imagePath: imagePath),
                ),
              );
            }
          }
        } catch (e) {
          print("拍照截圖失敗: $e");
        }
      },
    );
  }
}
