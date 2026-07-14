import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../controllers/monster_controller.dart';
import 'package:get/get.dart';
import '../styles/app_theme.dart';
import '../utils/monster_image_path.dart';
import '../widgets/common/snackbar_builder.dart';
import '../widgets/constants/responsive.dart';
import 'package:campus_tour/widgets/ar_control/ar_control_view.dart';

class RealArPage extends StatefulWidget {
  const RealArPage({super.key});

  @override
  State<RealArPage> createState() => _RealArPageState();
}

class _RealArPageState extends State<RealArPage> {
  ARKitController? arkitController;
  final monsterController = Get.find<MonsterController>();

  // 💡 當前選中的精靈模型路徑 (從 UserMonsterModel.arRef 取得)
  String selectedMonsterUrl = "";
  double selectedScale = 0.05; // 預設縮放比例

  @override
  void dispose() {
    arkitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'view.real.ar.view.s001'.tr,
          style: AppTheme.emptyStateStyle(20 * scale),
        ),
        backgroundColor: AppTheme.transparentColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.whiteTextColor,
            size: 24 * scale,
          ),
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
            bottom: 40 * scale,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'view.camera.view.s003'.tr,
                  style: AppTheme.overlayTextStyle(18 * scale),
                ),
                SizedBox(height: 15 * scale),
                SizedBox(
                  height: 110 * scale,
                  child: Obx(() {
                    final collection = monsterController.userMonsterCollection;
                    if (collection.isEmpty) {
                      return Center(
                        child: Text(
                          'view.camera.view.s004'.tr,
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
                        String modelFile =
                            userMonster.arRef ?? ""; // 💡 使用 Model 內的 arRef
                        bool isSelected = selectedMonsterUrl == modelFile;
                        bool isSpecialMonster =
                            userMonster.name == 'view.real.ar.view.s004'.tr;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              selectedMonsterUrl = modelFile;
                              selectedScale = (modelFile == "Elephant.usdz")
                                  ? 8
                                  : 0.05;
                              debugPrint("💡 已切換精靈模型為: $selectedMonsterUrl");
                            });
                            if (selectedMonsterUrl == "YMCA.usdz") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ArPage()),
                              );
                            }
                          },
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
                                  : isSpecialMonster
                                  ? Colors.pink.shade100.withValues(alpha: 0.7)
                                  : AppTheme.arUnselectedTileColor,
                              borderRadius: BorderRadius.circular(20 * scale),
                              border: isSelected
                                  ? Border.all(
                                      color: AppTheme.whiteTextColor,
                                      width: 3 * scale,
                                    )
                                  : null,
                              // 💡 強化發光效果
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.whiteTextColor
                                            .withValues(alpha: 0.8),
                                        blurRadius: 10 * scale,
                                        spreadRadius: 1 * scale,
                                      ),
                                      BoxShadow(
                                        color: AppTheme.whiteTextColor
                                            .withValues(alpha: 0.4),
                                        blurRadius: 20 * scale,
                                        spreadRadius: 2 * scale,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 精靈圖示
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    10 * scale,
                                  ),
                                  child: Image.asset(
                                    MonsterImagePath.staticImage(
                                      userMonster.imageURL,
                                    ),
                                    height: 55 * scale,
                                    width: 55 * scale,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                Text(
                                  userMonster.name,
                                  style: AppTheme.emptyStateStyle(12 * scale)
                                      .copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
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
    controller.onARTap = (List<ARKitTestResult> arTapResults) {
      if (selectedMonsterUrl.isEmpty) {
        SnackBarBuilder.show(
          context,
          'view.real.ar.view.s006'.tr,
          type: AppToastType.warning,
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

  void _addMonster(ARKitTestResult planeTap) async {
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
      scale: vector.Vector3(selectedScale, selectedScale, selectedScale),
    );

    arkitController?.add(node);
  }
}
