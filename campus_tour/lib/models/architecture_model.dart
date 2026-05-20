import 'package:cloud_firestore/cloud_firestore.dart';

class ArchitectureModel {
  final String id;
  final String name;
  final String type;
  final String story;
  final String preStory;
  final String? imageURL;
  final String? author;
  final String? date;
  final List<String> major; // 改為非 nullable，因為 fromMap 會給空陣列

  ArchitectureModel({
    required this.id,
    required this.name,
    required this.type,
    required this.story,
    required this.preStory,
    this.imageURL,
    this.author,
    this.date,
    required this.major, // 這裡也要改為 required
  });

  factory ArchitectureModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return ArchitectureModel(
      id: id ?? data['id'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      story: data['story'] ?? '',
      preStory: data['preStory'] ?? '',
      imageURL: data['imageURL'] ?? "",
      author: data['author'] ?? "",
      date: data['date'] ?? "",
      // 安全地轉換 List<dynamic> 到 List<String>
      major: data['major'] is List
          ? List<String>.from(data['major'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'story': story,
      'preStory': preStory,
      'imageURL': imageURL,
      'author': author,
      'date': date,
      'major': major,
    };
  }
}
