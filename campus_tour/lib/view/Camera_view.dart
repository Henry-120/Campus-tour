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

  String selectedMonsterUrl = "";
  String selectedMonsterImageUrl = "";
  String selectedMonsterId = "";

  // 修改此處：將精靈位置往右 (x=0.6) 且往上 (y=0.4) 移動
  Alignment fairyPosition = const Alignment(0.0, 0.4);

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
          // 📸 1. 拍照區域 (Screenshot) - 只包含相機、底圖、精靈
          Screenshot(
            controller: _screenshotController,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final controller = _cameraController.controller!;
                return Stack(
                  children: [
                    // 📸 1. 最底層：相機畫面
                    Padding(
                      padding: EdgeInsets.only(
                        left: constraints.maxWidth * 0.05, // 寬度的 5%
                        right: constraints.maxWidth * 0.05,
                        top: constraints.maxHeight * 0.08, // 高度的 8%
                        bottom: constraints.maxHeight * 0.06,
                      ), // 💡 根據相框粗細調整，讓相機不超出邊界
                      child: Center(
                        // 💡 使用 AspectRatio 確保相機「比例不變」且「不被裁切」
                        // 它會自動判斷橫向或縱向哪個先達到邊界就停住
                        child: AspectRatio(
                          aspectRatio: 9/16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            // 稍微圓角配合相框風格
                            child: CameraPreview(controller),
                          ),
                        ),
                      ),
                    ),

                    // 2. 中層：相框 (img_frame)
                    if (selectedMonsterUrl.isNotEmpty)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Image.asset(
                            selectedMonsterUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                    // 3. 最上層：精靈本身的圖片
                    if (selectedMonsterImageUrl.isNotEmpty)
                      FairyImageWidget(
                        imagePath: selectedMonsterImageUrl,
                        alignment: fairyPosition,
                        width: 150, // 精靈的大小
                      ),
                  ],
                );
              },
            ),
          ),

          // 🔘 2. 拍照按鈕 (放在選擇列上方)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 180), // 💡 移高一點，避開下方的選擇列
              child: _buildCaptureButton(),
            ),
          ),

          // 🛠️ 3. 下方精靈選擇列
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
                        child: Text(
                          "目前沒有精靈",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: collection.length,
                      itemBuilder: (context, index) {
                        final userMonster = collection[index];
                        String modelFile = userMonster.videoRef ?? "";
                        bool isSelected = selectedMonsterId == userMonster.name;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMonsterId = userMonster.name;
                              selectedMonsterUrl = modelFile;
                              selectedMonsterImageUrl = userMonster.imageURL;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              right: 15,
                              top: 5,
                              bottom: 5,
                            ),
                            width: 90,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black38,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    userMonster.imageURL,
                                    height: 55,
                                    width: 55,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userMonster.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
            final String imagePath =
                '${directory.path}/ar_photo_${DateTime.now().millisecondsSinceEpoch}.png';
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
