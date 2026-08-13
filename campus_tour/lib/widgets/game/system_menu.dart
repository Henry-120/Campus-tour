import 'package:campus_tour/widgets/game/stone_button.dart';
import 'package:campus_tour/features/ar/ar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/view/encyclopedia_page.dart';
import 'package:campus_tour/view/camera_view.dart';
import 'package:campus_tour/view/lhf_setting_page.dart';

import '../constants/asset_paths.dart';
import '../../widgets/constants/responsive.dart';

import 'package:get/get.dart';

class SystemMenu extends StatelessWidget {
  const SystemMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);
    final supportsAr =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
    final buttonSize = supportsAr ? 90.0 : 110.0;

    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StoneButton(
            img: AssetPaths.pokedexButton,
            text: 'view.encyclopedia.page.s001'.tr,
            scale: scale,
            baseSize: buttonSize,
            onTap: () => _openPokedex(context),
          ),
          StoneButton(
            img: AssetPaths.cameraButton,
            text: 'widgets.game.system.menu.s002'.tr,
            scale: scale,
            baseSize: buttonSize,
            onTap: () => _openCamera(context),
          ),
          if (supportsAr)
            StoneButton(
              img: AssetPaths.cameraButton,
              text: "AR",
              scale: scale,
              baseSize: buttonSize,
              onTap: () => _openARCamera(context),
            ),
          StoneButton(
            img: AssetPaths.settingButton,
            text: 'widgets.game.system.menu.s003'.tr,
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
      MaterialPageRoute(builder: (_) => EncyclopediaPage()),
    );
  }

  void _openCamera(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ArCapturePage()));
  }

  // void _openDrawer(BuildContext context) {
  //   Scaffold.of(context).openDrawer();
  // }

  void _openSettings(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingPage()));
  }

  Future<void> _openARCamera(BuildContext context) async {
    await ArLauncher.open(context);
  }
}
