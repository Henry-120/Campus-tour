import 'package:campus_tour/local_information/local_setting.dart';

class ArchitectureModel {
  static const String departmentBuilding = '系館';
  static const String installationArt = '裝置藝術';
  static const String scenicSpot = '景點';

  static const Map<String, Map<String, String>> _typeTranslations = {
    departmentBuilding: {
      LanguageSetting.chinese: departmentBuilding,
      LanguageSetting.english: 'Department Building',
      LanguageSetting.japanese: '学部棟',
    },
    installationArt: {
      LanguageSetting.chinese: installationArt,
      LanguageSetting.english: 'Public Art',
      LanguageSetting.japanese: 'パブリックアート',
    },
    scenicSpot: {
      LanguageSetting.chinese: scenicSpot,
      LanguageSetting.english: 'Scenic Spot',
      LanguageSetting.japanese: '観光スポット',
    },
  };

  final String id;
  final Map<String, String> names;
  final Map<String, String> stories;
  final Map<String, String> types;
  final Map<String, List<String>> majorSets;
  final Map<String, String> authors;
  final String? imageURL;
  final String? date;

  ArchitectureModel({
    required this.id,
    required this.names,
    required this.stories,
    required this.types,
    required this.majorSets,
    required this.authors,
    this.imageURL,
    this.date,
  });

  String get name => _localizedValue(names);

  String get story => _localizedValue(stories);

  String get author => _localizedValue(authors);

  String get canonicalType =>
      types[LanguageSetting.chinese] ?? _firstValue(types);

  String get type {
    final language = LocalSettingService.language.current;
    final stored = types[language];
    if (stored != null && stored.isNotEmpty) return stored;
    return _typeTranslations[canonicalType]?[language] ?? canonicalType;
  }

  List<String> get major =>
      majorSets[LocalSettingService.language.current] ??
      majorSets[LanguageSetting.chinese] ??
      const [];

  factory ArchitectureModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return ArchitectureModel(
      id: id ?? data['id']?.toString() ?? '',
      names: _stringMap(data['name']),
      stories: _stringMap(data['story']),
      types: _stringMap(data['type']),
      majorSets: _stringListMap(data['major']),
      authors: _stringMap(data['author']),
      imageURL: data['imageURL']?.toString() ?? '',
      date: data['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': names,
      'type': _storedTypes,
      'story': stories,
      'imageURL': imageURL,
      'author': authors,
      'date': date,
      'major': majorSets,
    };
  }

  Map<String, String> get _storedTypes {
    final knownTranslations = _typeTranslations[canonicalType];
    return knownTranslations == null ? types : {...knownTranslations, ...types};
  }

  String _localizedValue(Map<String, String> values) {
    final localized = values[LocalSettingService.language.current];
    if (localized != null && localized.isNotEmpty) return localized;
    return values[LanguageSetting.chinese] ?? _firstValue(values);
  }

  static Map<String, String> _stringMap(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
      );
    }
    return {LanguageSetting.chinese: value?.toString() ?? ''};
  }

  static Map<String, List<String>> _stringListMap(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, items) => MapEntry(
          key.toString(),
          items is List ? items.map((item) => item.toString()).toList() : [],
        ),
      );
    }
    return {
      LanguageSetting.chinese: value is List
          ? value.map((item) => item.toString()).toList()
          : [],
    };
  }

  static String _firstValue(Map<String, String> values) =>
      values.isEmpty ? '' : values.values.first;
}
