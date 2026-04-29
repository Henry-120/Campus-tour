import 'package:flutter/material.dart';
import '../constants/asset_paths.dart';
import 'system_menu.dart';

class MainBottomMenu extends StatelessWidget {
  const MainBottomMenu({super.key});

  static const double boardWidth = 380;
  static const double boardHeight = 150;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: boardWidth,
        height: boardHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                AssetPaths.bottomWoodBoard,
                fit: BoxFit.contain,
              ),
            ),

            const Positioned.fill(
              child: SystemMenu(),
            ),
          ],
        ),
      ),
    );
  }
}