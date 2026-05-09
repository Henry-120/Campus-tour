import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../controllers/camera_controller.dart';
import '../../controllers/fairy_video_controller.dart';
import '../../controllers/monster_controller.dart';
import '../../widgets/common/fairy_video.dart';
import '../../widgets/buttons/capture_button.dart';
import '../../services/camera_service.dart';
import '../../view/photo_preview.dart';
import 'package:get/get.dart';

class ArCapturePage extends StatefulWidget {
  const ArCapturePage({super.key});


  @override
  State<ArCapturePage> createState() => _ArCapturePageState();
}

class _ArCapturePageState extends State<ArCapturePage> {
  final ArCameraController _cameraController = ArCameraController();
  final ArVideoController _videoController = ArVideoController();
  final ScreenshotController _screenshotController = ScreenshotController();
  final monsterController = Get.find<MonsterController>();

  // 💡 當前選中的精靈模型路徑 (從 UserMonsterModel.arRef 取得)
  String selectedMonsterUrl = "";

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
      await _videoController.initVideo(selectedMonsterUrl);
      if (mounted) setState(() {});
    } catch (e) {
      print("影片初始化失敗: $e");
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
                // 2. 下方精靈選擇列
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const Text(
                        "選擇要放出的精靈",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 110,
                        child: Obx(() {
                          final collection = monsterController.userMonsterCollection;
                          if (collection.isEmpty) {
                            return const Center(
                              child: Text("目前沒有精靈", style: TextStyle(color: Colors.white)),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: collection.length,
                            itemBuilder: (context, index) {
                              final userMonster = collection[index];
                              String modelFile = userMonster.videoRef ?? ""; // 💡 使用 Model 內的 arRef
                              bool isSelected = selectedMonsterUrl == modelFile;

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    selectedMonsterUrl = modelFile;
                                    debugPrint("💡 已切換精靈模型為: $selectedMonsterUrl");
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 15, top:5, bottom:5),
                                  width: 90,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.black38,
                                    borderRadius: BorderRadius.circular(20),
                                    border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                                    // 💡 強化發光效果
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ] : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // 精靈圖示
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          userMonster.imageURL, // 💡 直接使用 Asset 圖片路徑
                                          height: 55,
                                          width: 55,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        userMonster.name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
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
