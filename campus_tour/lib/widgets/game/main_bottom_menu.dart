import 'package:flutter/material.dart';
import '../common/scale_button.dart';
import 'system_menu.dart';
import '../../styles/app_theme.dart';

class MainBottomMenu extends StatelessWidget {
  const MainBottomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleButton(
        onTap: null, // SystemMenu 內部已有自己的按鈕邏輯
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            boxShadow: AppTheme.softShadow,
          ),
          child: const SystemMenu(),
        ),
      ),
    );
  }
}
