import 'package:flutter/material.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
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
        duration: SettingPageStyles.animationDuration,
        decoration: SettingPageStyles.pageBackgroundDecoration,
        child: const DrawerButtonGroup(),
      ),
    );
  }
}
