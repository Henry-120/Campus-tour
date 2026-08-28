import 'package:campus_tour/view/about_us_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('about us page shows the complete production credits', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutUsPage()));

    const expectedTextCounts = {
      '關於咚谷粒': 2,
      '發行單位': 1,
      '國立中央大學國際處': 1,
      '指導監製': 1,
      '王聖翔 老師': 1,
      '國際合作': 1,
      '洗足學園音樂大學': 1,
      '遊戲App開發製作': 1,
      '資管系 郭碩宏': 1,
      '資工系 蔡佳穎': 1,
      '資工系 葉芮丞': 1,
      '經濟系 陸竑甫': 1,
      '財金系 陳俊嘉': 1,
      '光電系 羅靖宥': 1,
    };

    for (final entry in expectedTextCounts.entries) {
      expect(find.text(entry.key), findsNWidgets(entry.value));
    }
  });
}
