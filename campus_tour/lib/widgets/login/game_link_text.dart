import 'package:flutter/material.dart';

class GameLinkText extends StatelessWidget {
  const GameLinkText({
    super.key,
    required this.text,
    required this.onTap,
    this.fontSize = 18,
    this.color = Colors.white,
  });

  final String text;
  final VoidCallback onTap;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.25,
          fontWeight: FontWeight.w900,
          color: color,
          shadows: [
            Shadow(
              offset: Offset(fontSize * 0.11, fontSize * 0.11),
              blurRadius: fontSize * 0.06,
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ],
        ),
      ),
    );
  }
}
