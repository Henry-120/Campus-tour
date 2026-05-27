import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          title,
          style: AppTheme.gameTitleStrokeStyle(scale).copyWith(
            fontSize: baseFontSize * scale,
            letterSpacing: 1.5 * scale,
          ),
        ),
        Text(
          title,
          style: AppTheme.gameTitleFillStyle(scale).copyWith(
            fontSize: baseFontSize * scale,
            letterSpacing: 1.5 * scale,
          ),
        ),
      ],
    );
  }
}
