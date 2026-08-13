import 'package:campus_tour/features/ar/controllers/android/android_ar_scene_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Flutter wrapper for the native SceneView/ARCore surface.
class ArCoreSceneView extends StatefulWidget {
  const ArCoreSceneView({
    super.key,
    required this.controller,
    this.onReady,
    this.onPlaneDetected,
    this.onModelPlaced,
    this.onError,
  });

  final AndroidArSceneController controller;
  final VoidCallback? onReady;
  final VoidCallback? onPlaneDetected;
  final VoidCallback? onModelPlaced;
  final ValueChanged<String>? onError;

  @override
  State<ArCoreSceneView> createState() => _ArCoreSceneViewState();
}

class _ArCoreSceneViewState extends State<ArCoreSceneView> {
  static const _viewType = 'campus_tour/arcore_scene';

  @override
  void initState() {
    super.initState();
    _bindCallbacks();
  }

  @override
  void didUpdateWidget(covariant ArCoreSceneView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.detach();
    }
    _bindCallbacks();
  }

  void _bindCallbacks() {
    widget.controller
      ..onReady = widget.onReady
      ..onPlaneDetected = widget.onPlaneDetected
      ..onModelPlaced = widget.onModelPlaced
      ..onError = widget.onError;
  }

  @override
  void dispose() {
    widget.controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return Center(
        child: Text('features.ar.widgets.android.arcore.scene.view.s001'.tr),
      );
    }

    return AndroidView(
      viewType: _viewType,
      onPlatformViewCreated: widget.controller.attach,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
      },
    );
  }
}
