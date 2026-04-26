import 'package:flutter/material.dart';

import '../constants/responsive.dart';

class GameTitle extends StatelessWidget {
  const GameTitle({
    super.key,
    this.title = "AWAKENING",
    this.baseFontSize = 40,
  });

  final String title;
  final double baseFontSize;

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);
    final fontSize = baseFontSize * scale;

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5 * scale,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8 * scale
              ..color = const Color(0xFF6B3515),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5 * scale,
            color: const Color(0xFFFFD36A),
            shadows: [
              Shadow(
                offset: Offset(0, 3 * scale),
                blurRadius: 0,
                color: const Color(0xFF9A4F1D),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
