import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../controllers/camera_controller.dart';
import '../../controllers/fairy_video_controller.dart';
import '../../controllers/monster_controller.dart';
import '../../models/user_monster_model.dart';
import '../../styles/app_theme.dart';
import '../../widgets/common/fairy_video.dart';
import '../../widgets/buttons/capture_button.dart';
import '../../view/photo_preview.dart';
import '../../widgets/constants/responsive.dart';
import 'package:get/get.dart';
import '../../services/audio_service.dart';

class ArCapturePage extends StatefulWidget {
  const ArCapturePage({super.key});

  @override
  State<ArCapturePage> createState() => _ArCapturePageState();
}

class _ArCapturePageState extends State<ArCapturePage> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    AudioService().playOverlayBgm(fileName: 'audio/M12_AR_camera.wav');
    _startArMode();
  }

  Future<void> _startArMode() async {
    try {
      await _cameraController.initCamera();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("相機初始化失敗: $e");
    }

    try {
      await _videoController.initVideo(selectedMonsterUrl);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("影片初始化失敗: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService().pauseAllBgm();
    } else if (state == AppLifecycleState.resumed) {  
      AudioService().resumeAllBgm();
    }
  }

  @override
  void dispose() {
    AudioService().stopOverlayBgm();
    _cameraController.dispose();
    _videoController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    if (!_cameraController.isInitialized) {
      return Scaffold(
        backgroundColor: AppTheme.overlayBackgroundColor,
        body: Stack(
          children: [
            const Center(
              child: CircularProgressIndicator(color: AppTheme.whiteTextColor),
            ),
            _buildBackButton(scale),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.overlayBackgroundColor,
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
                        left: constraints.maxWidth * 0.04, // 寬度的 5%
                        right: constraints.maxWidth * 0.04,
                        top: constraints.maxHeight * 0.08, // 高度的 8%
                        bottom: constraints.maxHeight * 0.06,
                      ), // 💡 根據相框粗細調整，讓相機不超出邊界
                      child: Center(
                        // 💡 使用 AspectRatio 確保相機「比例不變」且「不被裁切」
                        // 它會自動判斷橫向或縱向哪個先達到邊界就停住
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15 * scale),
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
                        width: 150 * scale, // 精靈的大小
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
              padding: EdgeInsets.only(bottom: 180 * scale), // 💡 移高一點，避開下方的選擇列
              child: _buildCaptureButton(),
            ),
          ),

          // 🛠️ 3. 下方精靈選擇列
          Positioned(
            bottom: 40 * scale,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text("選擇要放出的精靈", style: AppTheme.overlayTextStyle(18 * scale)),
                SizedBox(height: 15 * scale),
                SizedBox(
                  height: 110 * scale,
                  child: Obx(() {
                    final collection = monsterController.userMonsterCollection;
                    if (collection.isEmpty) {
                      return Center(
                        child: Text(
                          "目前沒有精靈",
                          style: AppTheme.emptyStateStyle(14 * scale),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                      itemCount: collection.length,
                      itemBuilder: (context, index) {
                        final userMonster = collection[index];
                        bool isSelected = selectedMonsterId == userMonster.name;

                        return GestureDetector(
                          onTap: () => _selectMonster(userMonster),
                          child: Container(
                            margin: EdgeInsets.only(
                              right: 15 * scale,
                              top: 5 * scale,
                              bottom: 5 * scale,
                            ),
                            width: 90 * scale,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.arSelectedTileColor.withValues(
                                      alpha: 0.2,
                                    )
                                  : AppTheme.arUnselectedTileColor,
                              borderRadius: BorderRadius.circular(20 * scale),
                              border: isSelected
                                  ? Border.all(
                                      color: AppTheme.whiteTextColor,
                                      width: 3 * scale,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    10 * scale,
                                  ),
                                  child: Image.asset(
                                    userMonster.imageURL,
                                    height: 55 * scale,
                                    width: 55 * scale,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                Text(
                                  userMonster.name,
                                  style: AppTheme.emptyStateStyle(12 * scale),
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
          _buildBackButton(scale),
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
          debugPrint("拍照截圖失敗: $e");
        }
      },
    );
  }

  Future<void> _selectMonster(UserMonsterModel userMonster) async {
    var framePath = _framePathForUserMonster(userMonster);

    if (framePath.isEmpty) {
      framePath = await _loadFramePathFromMonsterRef(userMonster);
    }

    if (!mounted) return;

    setState(() {
      selectedMonsterId = userMonster.name;
      selectedMonsterUrl = framePath;
      selectedMonsterImageUrl = userMonster.imageURL;
    });
  }

  String _framePathForUserMonster(UserMonsterModel userMonster) {
    final videoRef = userMonster.videoRef?.trim() ?? '';
    if (videoRef.isNotEmpty) return videoRef;

    return _framePathForType(userMonster.type);
  }

  Future<String> _loadFramePathFromMonsterRef(
    UserMonsterModel userMonster,
  ) async {
    try {
      final snapshot = await userMonster.monsterRef.get();
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return '';

      final videoRef = (data['videoRef'] ?? '').toString().trim();
      if (videoRef.isNotEmpty) return videoRef;

      return _framePathForType((data['type'] ?? '').toString());
    } catch (e) {
      debugPrint("[CameraView] 讀取精靈相框資料失敗: $e");
      return '';
    }
  }

  String _framePathForType(String type) {
    switch (type.trim()) {
      case '火':
        return 'assets/images/img_frame/fire.png';
      case '水':
        return 'assets/images/img_frame/water.png';
      case '草':
        return 'assets/images/img_frame/grass.png';
      default:
        return '';
    }
  }

  Widget _buildBackButton(double scale) {
    return Positioned(
      top: 16 * scale,
      left: 16 * scale,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: '返回',
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.whiteTextColor,
              size: 34 * scale,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
