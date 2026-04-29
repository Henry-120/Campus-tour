import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../controllers/monster_controller.dart';
import 'package:get/get.dart';

class RealArPage extends StatefulWidget {
  const RealArPage({super.key});

  @override
  State<RealArPage> createState() => _RealArPageState();
}

class _RealArPageState extends State<RealArPage> {
  late ARKitController arkitController;
  final monsterController = Get.find<MonsterController>();

  // 💡 當前選中的精靈模型路徑 (從 UserMonsterModel.arRef 取得)
  String selectedMonsterUrl = "";

  @override
  void initState() {
    super.initState();
    // 💡 預設選中玩家擁有的第一個精靈
    final collection = monsterController.userMonsterCollection;
  }

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("放置精靈", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        String modelFile = userMonster.arRef; // 💡 使用 Model 內的 arRef
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
    );
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController.onARTap = (List<ARKitTestResult> arTapResults) {
      if (selectedMonsterUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("請先選擇一隻精靈！")),
        );
        return;
      }

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

    // 💡 放置選中的精靈模型
    final node = ARKitReferenceNode(
      url: selectedMonsterUrl,
      position: position,
      eulerAngles: vector.Vector3(0, -1.5708, 0), // 修正躺下的問題
      scale: vector.Vector3(0.05, 0.05, 0.05),
    );

    arkitController.add(node);
  }
}
