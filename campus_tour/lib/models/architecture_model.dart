import 'package:cloud_firestore/cloud_firestore.dart';

class ArchitectureModel {
  final String id;
  final String name;          // 架構名稱
  final String type;          // 架構類型 (例如: tag name)
  final String story;
  final String preStory;      // 前置故事或背景文字

  ArchitectureModel({
    required this.id,
    required this.name,
    required this.type,
    required this.story,
    required this.preStory,
  });

  factory ArchitectureModel.fromMap(String id, Map<String, dynamic> data) {
    return ArchitectureModel(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      story: data['story'] ?? '',
      preStory: data['preStory'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'story': story,
      'preStory': preStory,
    };
  }
}
