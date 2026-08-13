import 'dart:math' as math;
import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/features/ar/widgets/shared/ar_dance_button.dart';
import 'package:campus_tour/features/ar/widgets/shared/ar_joystick.dart';
import 'package:campus_tour/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:get/get.dart';

class IosFairyControlPage extends StatefulWidget {
  const IosFairyControlPage({super.key, this.inheritArAudio = false});

  /// 從已播放 M12 的 AR 頁面進入時設為 true，避免重播或誤停父頁音樂。
  final bool inheritArAudio;

  @override
  State<IosFairyControlPage> createState() => _IosFairyControlPageState();
}

class _IosFairyControlPageState extends State<IosFairyControlPage>
    with WidgetsBindingObserver {
  ARKitController? arkitController;
  final monsterController = Get.find<MonsterController>();

  String selectedMonsterUrl = "assets/images/img_frame/grass.png";

  // 追蹤目前的精靈節點，以便操控
  ARKitNode? currentMonsterNode;

  // 操控參數
  double speed = 0.003; // 移動速度
  String _currentFairyUrl = "Fairy_walking.usdz";

  @override
  void initState() {
    super.initState();
    if (!widget.inheritArAudio) {
      WidgetsBinding.instance.addObserver(this);
      AudioService().playOverlayBgm(fileName: 'audio/M12_AR_camera.flac');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.inheritArAudio) return;

    if (state == AppLifecycleState.paused) {
      AudioService().pauseAllBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioService().resumeAllBgm();
    }
  }

  @override
  void dispose() {
    if (!widget.inheritArAudio) {
      WidgetsBinding.instance.removeObserver(this);
      AudioService().stopOverlayBgm();
    }
    arkitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'widgets.ar.control.ar.control.view.s001'.tr,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. AR 視圖
          ARKitSceneView(
            showFeaturePoints: true,
            planeDetection: ARPlaneDetection.horizontal,
            onARKitViewCreated: onARKitViewCreated,
            enableTapRecognizer: true,
          ),
          // Positioned.fill(
          //   child: IgnorePointer(
          //     child: Image.asset(
          //       selectedMonsterUrl,
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),

          // 2. 虛擬搖桿與跳舞鍵 - 只有當場上有精靈時才顯示
          if (currentMonsterNode != null) ...[
            Positioned(left: 40, bottom: 180, child: _buildJoystick()),
            Positioned(
              right: 40, // 放在右下角，跟左邊的搖桿對稱
              bottom: 180,
              child: ArDanceButton(
                onTap: () {
                  _switchFairyModel("Fairy_dancing.usdz"); // 💡 觸發跳舞動畫
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 💡 使用外部定義的 ArJoystick 組件
  Widget _buildJoystick() {
    return ArJoystick(
      onMove: (dx, dy) => _moveMonster(dx, dy),
      onEnd: () => _switchFairyModel("Fairy_walking.usdz"), // 手指放開時，換回走路動畫
    );
  }

  void _moveMonster(double dx, double dy) {
    if (currentMonsterNode == null) return;

    // 💡 當搖桿偏移量超過門檻時，切換到跑步模型
    if (dx.abs() > 0.1 || dy.abs() > 0.1) {
      _switchFairyModel("Fairy_running.usdz");
    }

    // 使用 dynamic 避開 Vector3 沒有 .value 的編譯錯誤
    final dynamic node = currentMonsterNode;

    try {
      final vector.Vector3 currentPos = node.position;
      node.position = vector.Vector3(
        currentPos.x + (dx * speed),
        currentPos.y,
        currentPos.z + (dy * speed),
      );

      if (dx.abs() > 0.1 || dy.abs() > 0.1) {
        double angle = math.atan2(dx, dy) + math.pi / 2;
        node.eulerAngles = vector.Vector3(-1.5708, -1.5708, angle);
      }
    } catch (e) {
      // 備用方案
      try {
        node.position.x += dx * speed;
        node.position.z += dy * speed;
      } catch (_) {}
    }
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    controller.onARTap = (List<ARKitTestResult> arTapResults) {
      final point = arTapResults.firstWhere(
        (tap) => tap.type == ARKitHitTestResultType.existingPlaneUsingExtent,
        orElse: () => arTapResults.first,
      );
      if (arTapResults.isNotEmpty) {
        _addMonster(point);
      }
    };
  }

  void _addMonster(ARKitTestResult planeTap) {
    final position = vector.Vector3(
      planeTap.worldTransform.getColumn(3).x,
      planeTap.worldTransform.getColumn(3).y,
      planeTap.worldTransform.getColumn(3).z,
    );

    if (currentMonsterNode != null) {
      arkitController?.remove(currentMonsterNode!.name);
    }

    currentMonsterNode = ARKitReferenceNode(
      url: "Fairy_walking.usdz",
      position: position,
      eulerAngles: vector.Vector3(0, -1.5708, 0),
      scale: vector.Vector3(0.05, 0.05, 0.05),
    );

    arkitController?.add(currentMonsterNode!);
    _currentFairyUrl = "Fairy_walking.usdz";
    setState(() {}); // 刷新 UI 顯示搖桿
  }

  void _switchFairyModel(String newUrl) {
    // 如果模型沒變，就不執行切換
    if (_currentFairyUrl == newUrl || currentMonsterNode == null) return;

    // 💡 使用 dynamic 轉型 node，並移除 .value 存取
    final dynamic node = currentMonsterNode;

    // 1. 記錄目前精靈的位置、轉向與縮放
    final vector.Vector3 position = node.position;
    final vector.Vector3 rotation = node.eulerAngles;
    final vector.Vector3 scale = node.scale;
    final String nodeName = node.name;

    // 2. 移除舊的 Node
    arkitController?.remove(nodeName);

    // 3. 建立新的 Node
    currentMonsterNode = ARKitReferenceNode(
      url: newUrl,
      position: position,
      eulerAngles: rotation,
      scale: scale,
    );

    // 4. 加入場景並更新狀態
    arkitController?.add(currentMonsterNode!);
    _currentFairyUrl = newUrl;

    debugPrint("💡 模型已切換至: $newUrl");
  }
}
