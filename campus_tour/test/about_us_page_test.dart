import 'package:campus_tour/view/about_us_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('about us page shows the complete production credits', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutUsPage()));

    const expectedText = [
      '關於我們',
      '發行單位',
      '國立中央大學國際處',
      '指導監製',
      '王聖翔 老師',
      '國際合作',
      '涉足學園音樂大學',
      '遊戲App開發製作',
      '資管系 郭碩宏',
      '資工系 蔡佳穎',
      '資工系 葉芮丞',
      '經濟系 陸乾甫',
      '財金系 陳俊嘉',
      '光電系 羅靖宥',
    ];

    for (final text in expectedText) {
      expect(find.text(text), findsOneWidget);
    }
  });
}
