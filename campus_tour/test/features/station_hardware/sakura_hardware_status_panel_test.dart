import 'package:campus_tour/features/station_hardware/view_models/station_hardware_view_model.dart';
import 'package:campus_tour/features/station_hardware/widgets/sakura_card_view.dart';
import 'package:campus_tour/l10n/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cooldown display updates only when the shown minute changes', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 8, 26, 12);
    final deadline = now.add(const Duration(minutes: 1, seconds: 1));

    await tester.pumpWidget(
      _testApp(
        SakuraHardwareStatusPanel(
          phase: StationHardwarePhase.cooldown,
          lastTriggerTime: now.subtract(const Duration(hours: 23)),
          errorMessage: null,
          cooldownDeadline: deadline,
          confirmationDeadline: null,
          now: () => now,
        ),
      ),
    );

    expect(find.text('冷卻中：00:02'), findsOneWidget);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('冷卻中：00:01'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hardware confirmation display updates every second', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 8, 26, 12);
    final deadline = now.add(const Duration(minutes: 2));

    await tester.pumpWidget(
      _testApp(
        SakuraHardwareStatusPanel(
          phase: StationHardwarePhase.waitingForHardware,
          lastTriggerTime: null,
          errorMessage: null,
          cooldownDeadline: null,
          confirmationDeadline: deadline,
          now: () => now,
        ),
      ),
    );

    expect(find.text('等待硬體回應：02:00'), findsOneWidget);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('等待硬體回應：01:59'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Widget _testApp(Widget child) {
  return GetMaterialApp(
    translations: AppTranslations(),
    locale: const Locale('zh'),
    home: Scaffold(body: child),
  );
}
