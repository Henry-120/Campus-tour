import 'package:flutter/material.dart';

class StartBackground extends StatelessWidget {
  final String imagePath;
  const StartBackground({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        Container(color: Colors.black.withValues(alpha: 0.2)),
      ],
    );
  }
}