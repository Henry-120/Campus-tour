import 'package:flutter/material.dart';
import 'game_main_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("[Debug][LoginPage]:前往 GameMainPage");
    return GameMainPage();
  }
}
