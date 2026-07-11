import 'package:flutter/material.dart';
import '../../../styles/app_theme.dart';

import 'package:get/get.dart';

class CatchingFaildPage extends StatelessWidget {
  CatchingFaildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sentiment_dissatisfied,
                  size: 120,
                  color: Colors.grey,
                ),
                SizedBox(height: 24),
                Text(
                  'widgets.game.catching.pages.catching.faild.s001'.tr,
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'widgets.game.catching.pages.catching.faild.s002'.tr,
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 18,
                    color: Colors.black54,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'widgets.game.catching.pages.catching.faild.s003'.tr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
