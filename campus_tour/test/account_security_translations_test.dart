import 'package:campus_tour/l10n/app_translations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('account security translations', () {
    final translations = AppTranslations().keys;
    final accountKeys = [
      for (var index = 68; index <= 114; index++)
        'view.lhf.setting.page.s${index.toString().padLeft(3, '0')}',
    ];

    test('contains every account security string in zh, en, and ja', () {
      for (final locale in ['zh', 'en', 'ja']) {
        final localeTranslations = translations[locale]!;

        for (final key in accountKeys) {
          expect(
            localeTranslations[key],
            isNotNull,
            reason: '$locale is missing $key',
          );
          expect(
            localeTranslations[key],
            isNotEmpty,
            reason: '$locale has an empty value for $key',
          );
        }
      }
    });

    test('English and Japanese values do not fall back to Chinese', () {
      for (final key in accountKeys) {
        expect(
          translations['en']![key],
          isNot(translations['zh']![key]),
          reason: 'English falls back to Chinese for $key',
        );
        expect(
          translations['ja']![key],
          isNot(translations['zh']![key]),
          reason: 'Japanese falls back to Chinese for $key',
        );
      }
    });

    test('keeps interpolation placeholders in every language', () {
      const placeholders = {
        'view.lhf.setting.page.s073': '@error',
        'view.lhf.setting.page.s075': '@email',
        'view.lhf.setting.page.s085': '@email',
      };

      for (final locale in ['zh', 'en', 'ja']) {
        for (final entry in placeholders.entries) {
          expect(
            translations[locale]![entry.key],
            contains(entry.value),
            reason: '$locale is missing ${entry.value} in ${entry.key}',
          );
        }
      }
    });
  });
}
