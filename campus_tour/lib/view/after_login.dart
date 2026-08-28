import 'package:flutter/material.dart';

import '../local_information/local_setting.dart';
import '../services/audio_service.dart';
import 'game_main_page.dart';
import 'novice_leading_page.dart';

// [L-01]
Future<void> navigateAfterLogin(BuildContext context) async {
  // The tutorial uses the overlay player, so the login track on the main
  // player must be stopped explicitly before either destination is shown.
  await AudioService().stopMainBgm(onlyIfPlaying: AudioTrack.login);

  if (!context.mounted) return;

  // [L-02]
  if (LocalSettingService.noviceTeaching.hasExperienced) {
    // [L-03]
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameMainPage()),
    );
    return;
  }

  // [L-04]
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (tutorialContext) => NoviceLeadingPage(
        onFinish: () => _finishNoviceTeaching(tutorialContext),
      ),
    ),
  );
}

// [L-05]
Future<void> _finishNoviceTeaching(BuildContext tutorialContext) async {
  // [L-06]
  await LocalSettingService.noviceTeaching.markExperienced();

  // [L-07]
  if (!tutorialContext.mounted) {
    return;
  }

  // [L-08]
  Navigator.pushReplacement(
    tutorialContext,
    MaterialPageRoute(builder: (context) => const GameMainPage()),
  );
}
