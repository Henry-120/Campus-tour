// 處理精靈資料讀取與匯入
// 從json檔載入db
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/monster_model.dart';
import '../models/architecture_model.dart';
import '../models/qa_model.dart';


class LoadDbService {

  //monsters db
  Future<void> loadMonsters() async {
    final String response = await rootBundle.loadString('assets/json/monster.json');
    final List<dynamic> data = json.decode(response);

    for (var monsterData in data) {
      MonsterModel monster = MonsterModel.fromMap(id:monsterData['id'], monsterData);
      await FirebaseFirestore.instance
          .collection("monsters")
          .doc(monster.id)
          .set(monster.toMap());
    }
  }

  //architectures db
  Future<void> loadArchitecture() async {
    final String response = await rootBundle.loadString('assets/json/architecture.json');
    final List<dynamic> data = json.decode(response);

    for (var architectureData in data) {
      ArchitectureModel architecture = ArchitectureModel.fromMap(id:architectureData['id'], architectureData);
      await FirebaseFirestore.instance
          .collection("architectures")
          .doc(architecture.id)
          .set(architecture.toMap());
    }
  }

  //qa db
  Future<void> loadQA() async {
    final String response = await rootBundle.loadString('assets/json/qa.json');
    final List<dynamic> data = json.decode(response);

    for (var qaData in data) {
      QAModel qa = QAModel.fromMap(qaData['id'], qaData);
      await FirebaseFirestore.instance
          .collection("questions")
          .doc(qa.id)
          .set(qa.toMap());
    }
  }
}
