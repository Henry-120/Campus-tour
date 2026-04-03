import 'package:flutter/material.dart';
import '../widgets/login/login_text_field.dart';
import '../widgets/buttons/login_buttons.dart';
import 'game_main_page.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = LoginController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final user = await _controller.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (user != null) {
      debugPrint("[Debug][LoginPage]: 登入成功 →");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameMainPage()),
      );
    } else {
      debugPrint("[Debug][LoginPage]: 登入失敗");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("帳號或密碼錯誤")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("遊戲登入")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LoginTextField(controller: _emailController, label: "帳號"),
            LoginTextField(controller: _passwordController, label: "密碼", obscure: true),
            const SizedBox(height: 20),
            LoginButton(onPressed: _login,label:"登入"),
          ],
        ),
      ),
    );
  }
}
