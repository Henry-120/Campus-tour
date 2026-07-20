import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../styles/app_theme.dart';
import '../../../services/audio_service.dart';

class CatchingFaildPage extends StatefulWidget {
  const CatchingFaildPage({super.key});

  @override
  State<CatchingFaildPage> createState() => _CatchingFaildPageState();
}

class _CatchingFaildPageState extends State<CatchingFaildPage> {
  @override
  void initState() {
    super.initState();
    AudioService().playSfx(
      fileName: 'audio/M10_catch_fail.wav',
      pauseBgmUntilComplete: true,
    );
  }

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
