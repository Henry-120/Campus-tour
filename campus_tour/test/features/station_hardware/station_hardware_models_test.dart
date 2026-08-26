import 'package:campus_tour/features/station_hardware/models/station_hardware_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('message stays in page input until the MQTT contract accepts it', () {
    const input = StationHardwareInput(message: '給努力的自己加油');

    final eventData = MqttEventData.fromInput(
      input: input,
      displayName: ' Sakura ',
    );

    expect(input.message, '給努力的自己加油');
    expect(eventData.toJson(), {'displayName': 'Sakura'});
    expect(eventData.toJson(), isNot(contains('message')));
  });
}
