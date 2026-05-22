// import 'package:flutter/material.dart';
// import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
// import 'package:vector_math/vector_math_64.dart' as vector;
//
// class RealArPageAndroid extends StatefulWidget {
//   @override
//   _RealArPageAndroidState createState() => _RealArPageAndroidState();
// }
//
// class _RealArPageAndroidState extends State<RealArPageAndroid> {
//   ArCoreController? arCoreController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ArCoreView(
//         onArCoreViewCreated: _onArCoreViewCreated,
//         enableTapRecognizer: true, // 開啟點擊偵測
//       ),
//     );
//   }
//
//   void _onArCoreViewCreated(ArCoreController controller) {
//     arCoreController = controller;
//     // 點擊事件
//     arCoreController?.onPlaneTap = _handleOnPlaneTap;
//   }
//
//   void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
//     final hit = hits.first;
//     _addModel(hit);
//   }
//
//   void _addModel(ArCoreHitTestResult hit) {
//     final modelNode = ArCoreReferenceNode(
//       objectUrl: "assets/models/fairy_beauty.glb",
//       position: hit.pose.translation,
//       rotation: hit.pose.rotation,
//       scale: vector.Vector3(0.05, 0.05, 0.05),
//     );
//     arCoreController?.addArCoreNodeWithAnchor(modelNode);
//   }
//
//   @override
//   void dispose() {
//     arCoreController?.dispose();
//     super.dispose();
//   }
// }