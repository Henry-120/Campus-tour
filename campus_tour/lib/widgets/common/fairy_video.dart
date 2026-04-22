import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FairyVideoWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final double width;
  final Alignment alignment; // 新增：決定角色要在螢幕的哪邊

  const FairyVideoWidget({
    super.key,
    required this.controller,
    this.width = 250,
    this.alignment = Alignment.center, // 預設放在中間
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        // 如果影片還沒準備好，不顯示任何東西，避免白框
        if (!value.isInitialized) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: alignment, // 這裡決定位置 (例如 Alignment.bottomRight)
          child: IgnorePointer(
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                1, 0, 0, 0, 0,
                0, 1, 0, 0, 0,
                0, 0, 1, 0, 0,
                -5, -5, -5, 14.8, 0,
              ]),
              child: SizedBox(
                width: width,
                child: AspectRatio(
                  aspectRatio: value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
