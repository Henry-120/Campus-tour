import 'package:campus_tour/features/campus_map/pages/main_campus_map_page.dart';
import 'package:campus_tour/features/google_cappus_map/pages/google_campus_map_page.dart';
import 'package:flutter/material.dart';

enum MainMapVersion { google, mapLibre }

// 整個 App 的主地圖版本只由這個常數決定。
const MainMapVersion appMainMapVersion = MainMapVersion.mapLibre;

class GameMainPage extends StatelessWidget {
  const GameMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (appMainMapVersion) {
      MainMapVersion.google => const GoogleCampusMapPage(),
      MainMapVersion.mapLibre => const MainCampusMapPage(),
    };
  }
}
