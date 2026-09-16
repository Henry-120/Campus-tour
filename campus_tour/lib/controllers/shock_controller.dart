import 'package:campus_tour/local_information/local_setting.dart';
import 'package:vibration/vibration.dart';

class ShockControllerSettings {
  const ShockControllerSettings({
    required this.wrongAnswerDuration,
    required this.wrongAnswerAmplitude,
  });

  static const ShockControllerSettings defaultSettings =
      ShockControllerSettings(
        wrongAnswerDuration: Duration(milliseconds: 140),
        wrongAnswerAmplitude: 180,
      );

  final Duration wrongAnswerDuration;
  final int wrongAnswerAmplitude;
}

class ShockController {
  const ShockController({
    this.settings = ShockControllerSettings.defaultSettings,
  });

  final ShockControllerSettings settings;

  Future<void> wrongAnswerShock() async {
    if (!LocalSettingService.vibration.isEnabled) {
      return;
    }

    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) {
      return;
    }

    final hasAmplitudeControl = await Vibration.hasAmplitudeControl();
    await Vibration.vibrate(
      duration: settings.wrongAnswerDuration.inMilliseconds,
      amplitude: hasAmplitudeControl ? settings.wrongAnswerAmplitude : -1,
    );
  }
}
