import 'package:campus_tour/widgets/constants/asset_paths.dart';
import 'package:flutter/material.dart';

class DiscoveredItem {
  // [L-01]
  static const DiscoveredItem strategyBook = DiscoveredItem(
    title: '意外收穫！你找到了攻略秘集',
    noteText: '詳見金屬指示牌',
    imagePath: AssetPaths.book,
    buttonText: '好好研究它',
    fallbackIcon: Icons.menu_book_rounded,
  );

  // [L-02]
  static const DiscoveredItem magicStone = DiscoveredItem(
    title: '發現道具',
    noteText: '一顆發著光的魔法石',
    imagePath: 'assets/images/Plot/magicStone.PNG',
    buttonText: '帶著它',
    fallbackIcon: Icons.diamond_rounded,
  );

  // [L-03]
  final String title;
  final String noteText;
  final String imagePath;
  final String buttonText;
  final IconData fallbackIcon;

  // [L-04]
  const DiscoveredItem({
    required this.title,
    required this.noteText,
    required this.imagePath,
    required this.buttonText,
    required this.fallbackIcon,
  });
}
