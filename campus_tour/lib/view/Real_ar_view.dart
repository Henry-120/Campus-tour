import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class RealArPage extends StatefulWidget {
  const RealArPage({super.key});

  @override
  State<RealArPage> createState() => _RealArPageState();
}

class _RealArPageState extends State<RealArPage> {
  late ARKitController arkitController;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('召喚精靈吧！'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: ARKitSceneView(
        showFeaturePoints: true, // 顯示特徵點，方便確認是否有偵測到平面
        planeDetection: ARPlaneDetection.horizontal, // 偵測水平面（地面）
        onARKitViewCreated: onARKitViewCreated,
        enableTapRecognizer: true, // 開啟點擊偵測
      ),
    );
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;

    // 當使用者點擊螢幕時
    arkitController.onARTap = (List<ARKitTestResult> arTapResults) {
      // 尋找點擊位置是否在已偵測到的平面範圍內
      final point = arTapResults.firstWhere(
            (tap) => tap.type == ARKitHitTestResultType.existingPlaneUsingExtent,
        orElse: () => arTapResults.first, // 如果找不到精確平面，取第一個點
      );

      if (arTapResults.isNotEmpty) {
        _addSphere(point);
      }
    };
  }

  // 這裡修正了類別名稱為 ARKitTestResult
  void _addSphere(ARKitTestResult planeTap) {
    // 取得點擊位置的 3D 空間座標 (x, y, z)
    final position = vector.Vector3(
      planeTap.worldTransform.getColumn(3).x,
      planeTap.worldTransform.getColumn(3).y,
      planeTap.worldTransform.getColumn(3).z,
    );

    // 建立一個紅色小球 (直徑 10 公分)
    final node = ARKitNode(
      geometry: ARKitSphere(
        radius: 0.05,
        materials: [
          ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.red))
        ],
      ),
      position: position,
    );

    // 將小球加入 AR 場景
    arkitController.add(node);
  }
}