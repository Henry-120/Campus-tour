import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FairyImageWidget extends StatelessWidget {
  final String imagePath;
  final double width;
  final Alignment alignment; // 新增：決定角色要在螢幕的哪邊

  const FairyImageWidget({
    super.key,
    required this.imagePath,
    this.width = 250,
    this.alignment = Alignment.center, // 預設放在中間
  });

  @override
  Widget build(BuildContext context) {
        return Align(
          alignment: alignment, // 這裡決定位置 (例如 Alignment.bottomRight)
          child: IgnorePointer(
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                1, 0, 0, 0, 0,
                0, 1, 0, 0, 0,
                0, 0, 1, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: SizedBox(
                width: width,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
  }
}
