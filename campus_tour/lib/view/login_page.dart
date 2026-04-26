import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/constants/asset_paths.dart';
import '../widgets/constants/responsive.dart';
import '../widgets/login/game_title.dart';
import '../widgets/login/wood_login_panel.dart';
import 'game_main_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = LoginController();
  final TextEditingController _emailController = TextEditingController(text: "test@gmail.com");
  final TextEditingController _passwordController = TextEditingController(text: "123456");
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final user = await _controller.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        if (Get.isRegistered<UserController>()) {
          debugPrint("[LoginPage] 登入成功，正在獲取資料...");
          await Get.find<UserController>().fetchCurrentUser();
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const GameMainPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("帳號或密碼錯誤")),
        );
      }
    } catch (e) {
      debugPrint("[LoginPage] 登入出錯: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("登入發生錯誤，請稍後再試")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("尚未實作忘記密碼功能")),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AssetPaths.loginBg,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 12 * scale),
                    const GameTitle(title: "LOGIN"),
                    SizedBox(height: 10 * scale),
                    WoodLoginPanel(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isLoading: _isLoading,
                      onLogin: _login,
                      onRegister: _goToRegister,
                      onForgotPassword: _forgotPassword,
                    ),
                    SizedBox(height: 30 * scale),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
