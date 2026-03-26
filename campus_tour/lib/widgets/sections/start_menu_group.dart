import 'package:flutter/material.dart';
import '../common/start_title.dart';
import '../buttons/start_button.dart';
import '../../styles/app_theme.dart';

class StartMenuGroup extends StatelessWidget {
  const StartMenuGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        StartTitle(title: "Campus Tour"),
        SizedBox(height: AppTheme.elementSpacing + 100),
        StartButton(),
      ],
    );
  }
}