import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';

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
        style: AppTheme.gameLinkStyle(fontSize, color).copyWith(height: 1.25),
      ),
    );
  }
}
