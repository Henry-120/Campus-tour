import 'package:flutter/material.dart';
import '../common/scale_button.dart';
import 'package:get/get.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 定位按鈕 (藍藍可愛風)
        _buildCuteButton(
          icon: Icons.gps_fixed_rounded,
          color: Colors.blue.shade400,
          onTap: () => debugPrint("定位按鈕被按下"),
        ),
        const SizedBox(height: 15),
        // 2. 系統設定按鈕 (橘橘可愛風)
        _buildCuteButton(
          icon: Icons.settings_rounded,
          color: Colors.orange.shade400,
          onTap: () {
            // 打開侧邊欄 (Scaffold.of(context).openDrawer())
            Scaffold.of(context).openDrawer();
          },
        ),
      ],
    );
  }

  Widget _buildCuteButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color.withAlpha(80), width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
      ),
    );
  }
}
