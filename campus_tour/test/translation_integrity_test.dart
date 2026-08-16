import 'dart:convert';
import 'dart:io';

import 'package:campus_tour/l10n/app_translations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final translations = AppTranslations().keys;
  const locales = ['zh', 'en', 'ja'];

  test('all locales contain the same non-empty translation keys', () {
    final expectedKeys = translations['zh']!.keys.toSet();
    for (final locale in locales) {
      final values = translations[locale]!;
      expect(values.keys.toSet(), expectedKeys, reason: '$locale key mismatch');
      for (final entry in values.entries) {
        expect(entry.value.trim(), isNotEmpty, reason: '$locale ${entry.key}');
      }
    }
  });

  test('every literal .tr key used by the app exists', () {
    final keyPattern = RegExp(r'''['"]([^'"]+)['"]\s*\.tr(?:Params)?\b''');
    final missing = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.contains('/l10n/')) {
        continue;
      }
      final source = entity.readAsStringSync();
      for (final match in keyPattern.allMatches(source)) {
        final key = match.group(1)!;
        for (final locale in locales) {
          if (!translations[locale]!.containsKey(key)) {
            missing.add('$locale $key (${entity.path})');
          }
        }
      }
    }

    expect(missing, isEmpty, reason: missing.join('\n'));
  });

  test('generated Dart translations match the JSON source of truth', () {
    final decoded =
        jsonDecode(File('tool/i18n_chinese_strings.json').readAsStringSync())
            as Map<String, dynamic>;
    final entries = (decoded['entries'] as List).cast<Map<String, dynamic>>();
    final keys = entries.map((entry) => entry['key'] as String).toList();

    expect(keys.toSet().length, keys.length, reason: 'duplicate JSON keys');
    expect(decoded['totalUniqueStrings'], entries.length);

    for (final locale in locales) {
      final expected = <String, String>{
        for (final entry in entries)
          entry['key']
              as String: ((entry[locale] as String?)?.isNotEmpty == true)
              ? entry[locale] as String
              : entry['zh'] as String,
      };
      expect(translations[locale], expected, reason: '$locale source mismatch');
    }
  });

  test('parameter placeholders are consistent across locales', () {
    final placeholderPattern = RegExp(r'@[A-Za-z][A-Za-z0-9_]*');
    for (final key in translations['zh']!.keys) {
      final expected = placeholderPattern
          .allMatches(translations['zh']![key]!)
          .map((match) => match.group(0))
          .toSet();
      for (final locale in locales.skip(1)) {
        final actual = placeholderPattern
            .allMatches(translations[locale]![key]!)
            .map((match) => match.group(0))
            .toSet();
        expect(actual, expected, reason: '$locale placeholder mismatch: $key');
      }
    }
  });
}
