import 'package:flutter/material.dart';
import '../constants/asset_paths.dart';
import 'user_name_text.dart';

class UserNameBoard extends StatelessWidget {
  final double width;
  final double height;

  const UserNameBoard({super.key, this.width = 125, this.height = 42});

  @override
  Widget build(BuildContext context) {
    final scale = width / 125;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(AssetPaths.nameBroad, fit: BoxFit.fill),
          ),

          Positioned(
            left: 18 * scale,
            right: 18 * scale,
            top: 6 * scale,
            bottom: 6 * scale,
            child: Center(child: UserNameText(scale: scale)),
          ),
        ],
      ),
    );
  }
}
