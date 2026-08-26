import 'package:campus_tour/features/station_hardware/models/station_hardware_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('page message is serialized with the backend cardText key', () {
    const input = StationHardwareInput(message: '  給今日も努力的自己加油🌸  ');

    final eventData = MqttEventData.fromInput(
      input: input,
      displayName: ' Sakura ',
    );

    expect(input.message, '  給今日も努力的自己加油🌸  ');
    expect(eventData.cardText, '給今日も努力的自己加油🌸');
    expect(eventData.toJson(), {
      'displayName': 'Sakura',
      'cardText': '給今日も努力的自己加油🌸',
    });
    expect(eventData.toJson(), isNot(contains('message')));
  });
}
