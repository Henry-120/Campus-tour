// 處理精靈資料讀取與匯入
// 從json檔載入db
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/monster_model.dart';
import '../models/architecture_model.dart';
import '../models/qa_model.dart';
import 'firestore_service.dart';

class LoadDbService {
  final FirestoreService _firestoreService = FirestoreService();

  //monsters db
  Future<void> loadMonsters() async {
    final String response = await rootBundle.loadString(
      'assets/json/monster.json',
    );
    final List<dynamic> data = json.decode(response);

    for (var monsterData in data) {
      final monster = MonsterModel.fromMap(id: monsterData['id'], monsterData);
      await _firestoreService.setMonster(monster);
    }
  }

  //architectures db
  Future<void> loadArchitecture() async {
    final String response = await rootBundle.loadString(
      'assets/json/architecture.json',
    );
    final List<dynamic> data = json.decode(response);

    for (var architectureData in data) {
      final architecture = ArchitectureModel.fromMap(
        id: architectureData['id'],
        architectureData,
      );
      await _firestoreService.setArchitecture(architecture);
    }
  }

  //qa db
  Future<void> loadQA() async {
    final String response = await rootBundle.loadString('assets/json/qa.json');
    final List<dynamic> data = json.decode(response);

    for (var qaData in data) {
      final qa = QAModel.fromMap(qaData['id'], qaData);
      await _firestoreService.setQA(qa);
    }
  }
}
