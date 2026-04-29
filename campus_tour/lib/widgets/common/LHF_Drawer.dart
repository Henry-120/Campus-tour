import 'package:flutter/material.dart';
import 'package:campus_tour/styles/LHF_drawer_styles.dart';
import 'package:campus_tour/widgets/sections/drawer_button_group.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AppDrawerState();
  }
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: DrawerStyles.drawerAnimTime),
        decoration: DrawerStyles.drawerBackgroundDecoration,
        child: Stack(children: const [_DrawerGlowLayer(), _DarwerButton()]),
      ),
    );
  }
}

class _DrawerGlowLayer extends StatelessWidget {
  const _DrawerGlowLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: DrawerStyles.drawerGlowDecoration,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DarwerButton extends StatelessWidget {
  // 按鈕都在這裡 // 在sections裡面
  const _DarwerButton();

  @override
  Widget build(BuildContext context) {
    return const DrawerButtonGroup();
  }
}
