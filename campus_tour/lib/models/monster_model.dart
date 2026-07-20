import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_tour/local_information/local_setting.dart';

class MonsterModel {
  static const String waterType = '水';
  static const String fireType = '火';
  static const String grassType = '草';

  static const Map<String, Map<String, String>> _typeTranslations = {
    waterType: {
      LanguageSetting.chinese: waterType,
      LanguageSetting.english: 'Water',
      LanguageSetting.japanese: '水',
    },
    fireType: {
      LanguageSetting.chinese: fireType,
      LanguageSetting.english: 'Fire',
      LanguageSetting.japanese: '火',
    },
    grassType: {
      LanguageSetting.chinese: grassType,
      LanguageSetting.english: 'Grass',
      LanguageSetting.japanese: '草',
    },
  };

  final String id;
  final Map<String, String> names;
  final Map<String, String> types;
  final String imageURL;
  final String? arRef;
  final String? videoRef;
  final DocumentReference? architectureRef;
  final DocumentReference? qaRef;
  final GeoPoint location;

  MonsterModel({
    required this.id,
    required this.names,
    required this.types,
    required this.imageURL,
    this.architectureRef,
    this.qaRef,
    this.arRef,
    this.videoRef,
    required this.location,
  });

  String get name => _localizedValue(names);

  String get canonicalType =>
      types[LanguageSetting.chinese] ?? _firstValue(types);

  String get type {
    final language = LocalSettingService.language.current;
    final stored = types[language];
    if (stored != null && stored.isNotEmpty) return stored;
    return _typeTranslations[canonicalType]?[language] ?? canonicalType;
  }

  factory MonsterModel.fromMap(Map<String, dynamic> data, {String? id}) {
    final loc = data['location'];
    DocumentReference? archRef;
    if (data['architectureRef'] != null) {
      if (data['architectureRef'] is String) {
        // JSON 初始化時是字串路徑
        archRef = FirebaseFirestore.instance.doc(
          data['architectureRef'] as String,
        );
      } else if (data['architectureRef'] is DocumentReference) {
        // Firestore 讀取時就是 DocumentReference
        archRef = data['architectureRef'] as DocumentReference;
      }
    }

    DocumentReference? qaRef;
    if (data['qaRef'] != null && data['qaRef'] != '') {
      if (data['qaRef'] is String) {
        qaRef = FirebaseFirestore.instance.doc(data['qaRef'] as String);
      } else if (data['qaRef'] is DocumentReference) {
        qaRef = data['qaRef'] as DocumentReference;
      }
    }

    GeoPoint location;
    if (loc is GeoPoint) {
      // Firestore 讀取時
      location = loc;
    } else if (loc is Map<String, dynamic>) {
      // JSON 初始化時
      location = GeoPoint(
        (loc['latitude'] ?? 0).toDouble(),
        (loc['longitude'] ?? 0).toDouble(),
      );
    } else {
      // 預設值
      location = const GeoPoint(0, 0);
    }

    return MonsterModel(
      id: id ?? data['id'] ?? '',
      names: _stringMap(data['name']),
      types: _stringMap(data['type']),
      imageURL: data['imageURL'] ?? '',
      arRef: data['ARRef'] ?? '',
      videoRef: data['videoRef'] ?? '',
      architectureRef: archRef,
      qaRef: qaRef,
      location: location,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': names,
      'type': _storedTypes,
      'imageURL': imageURL,
      'architectureRef': architectureRef,
      'qaRef': qaRef,
      'ARRef': arRef,
      'videoRef': videoRef,
      'location': location,
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

  static String _firstValue(Map<String, String> values) =>
      values.isEmpty ? '' : values.values.first;
}
