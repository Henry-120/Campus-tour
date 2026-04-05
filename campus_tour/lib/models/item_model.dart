import 'package:campus_tour/models/monster_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ElfItem {
  final String id;
  final String name;
  final String imageUrl;
  final bool isUnlocked;
  final DocumentReference monsterRef;


  ElfItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isUnlocked,
    required this.monsterRef,
  });
}