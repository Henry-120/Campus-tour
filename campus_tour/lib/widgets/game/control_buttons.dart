import 'package:campus_tour/view/Real_ar_view.dart';
import 'package:campus_tour/widgets/constants/asset_paths.dart';
import 'package:campus_tour/widgets/login/game_link_text.dart';
import 'package:flutter/material.dart';
import '../../view/Camera_view.dart';
import '../../view/encyclopedia_page.dart';
import '../common/scale_button.dart';
import 'package:get/get.dart';

import '../constants/responsive.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);
    final color = Color(0xFFFFE0B2);
    return Column(
      children: [
        //4. AR按鈕
        _buildCuteButton(
          img:AssetPaths.cameraButton,
          onTap: () => _openARCamera(context),
        ),

        const SizedBox(height: 5),
        GameLinkText( text: "AR", onTap: () {}, fontSize: 16 * scale,color:color,),
        const SizedBox(height: 10),

      ],
    );
  }

  Widget _buildCuteButton({
    required String img,
    required VoidCallback onTap,
  }) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          image: DecorationImage(image:AssetImage(img)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
  void _openPokedex(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EncyclopediaPage(),
      ),
    );
  }

  void _openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ArCapturePage(),
      ),
    );
  }

  void _openARCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RealArPage(),
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
}
