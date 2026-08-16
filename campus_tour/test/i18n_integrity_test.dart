import 'dart:convert';
import 'dart:io';

import 'package:campus_tour/l10n/app_translations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const intentionalSharedValues = {'Google Maps', 'Email'};
  final source =
      jsonDecode(File('tool/i18n_chinese_strings.json').readAsStringSync())
          as Map<String, dynamic>;
  final entries = (source['entries'] as List).cast<Map<String, dynamic>>();
  final generated = AppTranslations().keys;

  test('translation source has unique, complete three-language entries', () {
    final seen = <String>{};
    for (final entry in entries) {
      final key = entry['key'] as String;
      expect(seen.add(key), isTrue, reason: 'Duplicate key: $key');
      for (final locale in ['zh', 'en', 'ja']) {
        expect(
          (entry[locale] as String).trim(),
          isNotEmpty,
          reason: '$locale is empty for $key',
        );
      }
      if (!intentionalSharedValues.contains(entry['zh'])) {
        expect(
          entry['en'],
          isNot(entry['zh']),
          reason: 'English fallback: $key',
        );
        expect(
          entry['ja'],
          isNot(entry['zh']),
          reason: 'Japanese fallback: $key',
        );
      }
    }
  });

  test('generated translations exactly match source keys and values', () {
    final sourceKeys = entries.map((entry) => entry['key'] as String).toSet();
    for (final locale in ['zh', 'en', 'ja']) {
      expect(generated[locale]!.keys.toSet(), sourceKeys, reason: locale);
      for (final entry in entries) {
        final key = entry['key'] as String;
        expect(generated[locale]![key], entry[locale], reason: '$locale: $key');
      }
    }
  });

  test('interpolation placeholders are identical in all languages', () {
    final placeholder = RegExp(
      r'@[A-Za-z_][A-Za-z0-9_]*|\$[A-Za-z_][A-Za-z0-9_.?]*',
    );
    for (final entry in entries) {
      final expected = placeholder
          .allMatches(entry['zh'] as String)
          .map((match) => match.group(0))
          .toSet();
      for (final locale in ['en', 'ja']) {
        final actual = placeholder
            .allMatches(entry[locale] as String)
            .map((match) => match.group(0))
            .toSet();
        expect(
          actual,
          expected,
          reason: '$locale placeholders: ${entry['key']}',
        );
      }
    }
  });

  test('known UI files contain no untranslated Chinese literals', () {
    const forbidden = [
      '無法開啟文件，請稍後再試',
      '使用者服務協議',
      '隱私權政策',
      '法律文件',
      '需要相機權限',
      '開啟系統設定',
      '需要相簿權限',
      '需要相簿權限才能儲存照片',
      '稍後再說',
      '開啟設定',
    ];
    for (final path in [
      'lib/widgets/login/legal_document_links.dart',
      'lib/view/camera_view.dart',
      'lib/view/photo_preview.dart',
    ]) {
      final source = File(path).readAsStringSync();
      for (final text in forbidden) {
        expect(source, isNot(contains("'$text'")), reason: '$path: $text');
      }
    }
  });

  test('release legal copy contains no placeholder or test wording', () {
    final legalEntries = entries.where(
      (entry) => (entry['key'] as String).startsWith('view.user.protocol.'),
    );
    const forbidden = [
      '暫時替代',
      '準備中',
      '互動測試',
      'Temporary Page',
      'Coming Soon',
      'temporary page',
      '仮ページ',
      '準備中',
    ];
    for (final entry in legalEntries) {
      for (final locale in ['zh', 'en', 'ja']) {
        final value = entry[locale] as String;
        for (final text in forbidden) {
          expect(
            value,
            isNot(contains(text)),
            reason: '${entry['key']} ($locale) contains release placeholder',
          );
        }
      }
    }
  });
}
