import 'package:flutter/material.dart';
import '../constants/asset_paths.dart';
import 'user_name_text.dart';

class UserNameBoard extends StatelessWidget {
  final double width;
  final double height;

  const UserNameBoard({
    super.key,
    this.width = 125,
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              AssetPaths.nameBroad,
              fit: BoxFit.fill,
            ),
          ),

          const Positioned(
            left: 18,
            right: 18,
            top: 6,
            bottom: 6,
            child: Center(
              child: UserNameText(),
            ),
          ),
        ],
      ),
    );
  }
}