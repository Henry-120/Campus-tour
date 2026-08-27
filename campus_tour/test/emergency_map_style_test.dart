import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emergency map inline style starts with a JSON object', () {
    final source = File('lib/view/AED_map_Android.dart').readAsStringSync();

    expect(source, contains("static const String _blankStyle = '''{"));
  });
}
