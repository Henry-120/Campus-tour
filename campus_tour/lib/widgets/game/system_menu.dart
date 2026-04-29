import 'package:campus_tour/widgets/game/stone_button.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/view/encyclopedia_page.dart';
import 'package:campus_tour/view/Camera_view.dart';

import '../constants/asset_paths.dart';
import '../../widgets/common/scale_button.dart';
import '../../widgets/constants/responsive.dart';
import '../../view/Real_ar_view.dart';

class SystemMenu extends StatelessWidget {
  const SystemMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 25,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StoneButton(
              img: AssetPaths.pokedexButton,
              text: "圖鑑",
              scale: scale,
              onTap: () => _openPokedex(context),
            ),
            StoneButton(
              img: AssetPaths.cameraButton,
              text: "相機",
              scale: scale,
              onTap: () => _openCamera(context),
            ),
            StoneButton(
              img: AssetPaths.settingButton,
              text: "設定",
              scale: scale,
              onTap: () => _openDrawer(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openPokedex(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EncyclopediaPage()),
    );
  }

  void _openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ArCapturePage()),
    );
  }

  void _openARCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RealArPage()),
    );
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
}