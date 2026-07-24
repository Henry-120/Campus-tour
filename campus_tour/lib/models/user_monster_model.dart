import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_tour/local_information/local_setting.dart';

class UserMonsterModel {
  String? docId;
  final DocumentReference monsterRef;
  final Map<String, String> names;
  final Map<String, String> types;
  final String imageURL;
  final String? arRef; // 💡 加入 AR 模型檔名
  final String? videoRef;
  final DateTime caughtAt;

  UserMonsterModel({
    this.docId,
    required this.names,
    this.types = const {},
    required this.imageURL,
    this.arRef,
    required this.monsterRef,
    this.videoRef,
    required this.caughtAt,
  });

  String get name {
    final localized = names[LocalSettingService.language.current];
    if (localized != null && localized.isNotEmpty) return localized;
    return names[LanguageSetting.chinese] ?? _firstValue(names);
  }

  String get type => types[LanguageSetting.chinese] ?? _firstValue(types);

  factory UserMonsterModel.fromMap(Map<String, dynamic> data, {String? docId}) {
    return UserMonsterModel(
      docId: docId,
      monsterRef: data['monsterRef'] as DocumentReference,
      caughtAt: (data['caughtAt'] as Timestamp).toDate(),
      names: _stringMap(data['name']),
      types: _stringMap(data['type']),
      imageURL: data['imageURL'] ?? '',
      arRef: data['ARRef'] ?? '', // 💡 讀取 ARRef
      videoRef: data['videoRef'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monsterRef': monsterRef,
      'caughtAt': caughtAt,
      'name': names,
      'type': types,
      'imageURL': imageURL,
      'ARRef': arRef, // 💡 存入 ARRef
      'videoRef': videoRef,
    };
  }

  UserMonsterModel withTranslations({
    required Map<String, String> names,
    required Map<String, String> types,
  }) {
    return UserMonsterModel(
      docId: docId,
      monsterRef: monsterRef,
      names: names,
      types: types,
      imageURL: imageURL,
      arRef: arRef,
      videoRef: videoRef,
      caughtAt: caughtAt,
    );
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
