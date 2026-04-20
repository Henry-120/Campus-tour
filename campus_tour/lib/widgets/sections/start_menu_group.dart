import 'package:flutter/material.dart';
import '../common/start_title.dart';
import '../buttons/start_button.dart';
import '../../styles/app_theme.dart';
import '/view/login_page.dart';

class StartMenuGroup extends StatelessWidget {
  const StartMenuGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        StartTitle(title: "校園導覽"),
        SizedBox(height: AppTheme.elementSpacing + 100),
        StartButton(
          label: "開始", 
          destination: LoginPage()), // 直接從登入頁開始
      ],
    );
  }
}