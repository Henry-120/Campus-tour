import 'package:campus_tour/local_information/local_setting.dart';

class QAModel {
  final String id;
  final Map<String, String> questions;
  final Map<String, List<String>> optionSets;
  final Map<String, String> answers;

  QAModel({
    required this.id,
    required this.questions,
    required this.optionSets,
    required this.answers,
  });

  String get question => _localizedValue(questions);

  List<String> get options =>
      optionSets[LocalSettingService.language.current] ??
      optionSets[LanguageSetting.chinese] ??
      const [];

  String get answer => _localizedValue(answers);

  String _localizedValue(Map<String, String> values) {
    final localized = values[LocalSettingService.language.current];
    if (localized != null && localized.isNotEmpty) return localized;
    return values[LanguageSetting.chinese] ?? '';
  }

  factory QAModel.fromMap(String id, Map<String, dynamic> data) {
    return QAModel(
      id: id,
      questions: _stringMap(data['question']),
      optionSets: _stringListMap(data['options']),
      answers: _stringMap(data['answer']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'question': questions, 'options': optionSets, 'answer': answers};
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
}
