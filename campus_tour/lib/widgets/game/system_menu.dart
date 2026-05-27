import 'package:campus_tour/widgets/game/stone_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/view/encyclopedia_page.dart';
import 'package:campus_tour/view/camera_view.dart';
import 'package:campus_tour/view/lhf_setting_page.dart';
import 'package:campus_tour/view/real_ar_view.dart';

import '../constants/asset_paths.dart';
import '../../widgets/constants/responsive.dart';

class SystemMenu extends StatelessWidget {
  const SystemMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final buttonSize = isIos ? 90.0 : 110.0;

    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StoneButton(
            img: AssetPaths.pokedexButton,
            text: "圖鑑",
            scale: scale,
            baseSize: buttonSize,
            onTap: () => _openPokedex(context),
          ),
          StoneButton(
            img: AssetPaths.cameraButton,
            text: "相機",
            scale: scale,
            baseSize: buttonSize,
            onTap: () => _openCamera(context),
          ),
          if (isIos)
            StoneButton(
              img: AssetPaths.cameraButton,
              text: "AR",
              scale: scale,
              baseSize: buttonSize,
              onTap: () => _openARCamera(context),
            ),
          StoneButton(
            img: AssetPaths.settingButton,
            text: "設定",
            scale: scale,
            baseSize: buttonSize,
            onTap: () => _openSettings(context),
          ),
        ],
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

  // void _openDrawer(BuildContext context) {
  //   Scaffold.of(context).openDrawer();
  // }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingPage()),
    );
  }

  void _openARCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RealArPage()),
    );
  }
}
