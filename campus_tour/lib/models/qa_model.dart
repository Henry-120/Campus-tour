class QAModel {
  final String id;
  final String question;       // 問題文字
  final List<String> options;  // 選項
  final String answer;         // 正確答案

  QAModel({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QAModel.fromMap(String id, Map<String, dynamic> data) {
    return QAModel(
      id: id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      answer: data['answer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
    };
  }
}
