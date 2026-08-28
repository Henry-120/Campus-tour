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

  test('every literal translation key used by the app exists', () {
    final keyPatterns = <RegExp>[
      RegExp(r'''['"]([a-z0-9]+(?:\.[a-z0-9]+)+\.s\d{3})['"]'''),
      RegExp(r'''['"]([^'"]+)['"]\s*\.tr(?:Params)?\b'''),
    ];
    final missing = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.contains('/l10n/')) {
        continue;
      }
      final source = entity.readAsStringSync();
      final referencedKeys = <String>{
        for (final pattern in keyPatterns)
          for (final match in pattern.allMatches(source)) match.group(1)!,
      };
      for (final key in referencedKeys) {
        for (final locale in locales) {
          if (!translations[locale]!.containsKey(key)) {
            missing.add('$locale $key (${entity.path})');
          }
        }
      }
    }

    expect(missing, isEmpty, reason: missing.join('\n'));
  });

  test('dynamic translation keys remain in every locale', () {
    const dynamicKeys = <String>{
      'features.station.hardware.sakura.page.s008',
      'features.station.hardware.sakura.page.s009',
      'features.station.hardware.sakura.page.s010',
      'features.station.hardware.sakura.page.s011',
      'features.station.hardware.sakura.page.s012',
      'features.station.hardware.sakura.page.s013',
      'widgets.game.game.map.s001',
      'widgets.game.game.map.s002',
      'utils.firebase.auth.error.message.s041',
      'utils.firebase.auth.error.message.s042',
    };

    for (final locale in locales) {
      expect(
        translations[locale]!.keys,
        containsAll(dynamicKeys),
        reason: '$locale is missing a dynamically referenced key',
      );
    }
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
