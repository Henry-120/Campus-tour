import 'package:campus_tour/widgets/constants/asset_paths.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DiscoveredItem {
  // [L-01]
  static DiscoveredItem get strategyBook => DiscoveredItem(
    title: 'widgets.game.catching.pages.discovered.item.s001'.tr,
    noteText: 'widgets.game.catching.pages.discovered.item.s002'.tr,
    imagePath: AssetPaths.book,
    buttonText: 'widgets.game.catching.pages.discovered.item.s003'.tr,
    fallbackIcon: Icons.menu_book_rounded,
  );

  // [L-02]
  final String title;
  final String noteText;
  final String imagePath;
  final String buttonText;
  final IconData fallbackIcon;

  // [L-03]
  DiscoveredItem({
    required this.title,
    required this.noteText,
    required this.imagePath,
    required this.buttonText,
    required this.fallbackIcon,
  });
}
