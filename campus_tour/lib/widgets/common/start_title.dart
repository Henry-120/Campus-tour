import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

class StartTitle extends StatelessWidget {
  final String title;
  const StartTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTheme.titleStyle,
    );
  }
}