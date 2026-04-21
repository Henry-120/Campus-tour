import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FairyVideoWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final double width;

  const FairyVideoWidget({
    super.key,
    required this.controller,
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ColorFiltered(
        // 💡 把參數放在 child 之前
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.dstOut, // 嘗試過濾白色背景
        ),
        child: Opacity(
          opacity: 0.9,
          child: SizedBox(
            width: width,
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
        ),
      ),
    );

  }
}