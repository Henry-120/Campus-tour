import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';
import '../constants/responsive.dart';

class CaptureButton extends StatelessWidget {
  final VoidCallback onPressed; // 定義點擊後要執行的動作

  const CaptureButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 72 * scale,
        height: 72 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.whiteTextColor, width: 5 * scale),
          color: AppTheme.whiteTextColor.withValues(alpha: 0.3),
        ),
        child: Container(
          margin: EdgeInsets.all(5 * scale),
          decoration: const BoxDecoration(
            color: AppTheme.whiteTextColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.camera_alt,
            color: AppTheme.cameraButtonIconColor,
            size: 40 * scale,
          ),
        ),
      ),
    );
  }
}
