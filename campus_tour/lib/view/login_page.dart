import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/constants/asset_paths.dart';
import '../widgets/constants/responsive.dart';
import '../widgets/common/snackbar_builder.dart';
import '../widgets/login/game_title.dart';
import '../widgets/login/wood_login_panel.dart';
import 'after_login.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = LoginController();
  final TextEditingController _emailController = TextEditingController(
    text: "test@gmail.com",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "123456",
  );
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
        if (!user.emailVerified) {
          SnackBarBuilder.show(
            context,
            "請先到 ${user.email ?? '你的信箱'} 點擊驗證信後再登入",
            type: AppToastType.warning,
          );
          return;
        }

        if (Get.isRegistered<UserController>()) {
          debugPrint("[LoginPage] 登入成功，正在獲取資料...");
          await Get.find<UserController>().fetchCurrentUser();
        }

        if (!mounted) return;

        navigateAfterLogin(context);
      } else {
        SnackBarBuilder.show(context, "帳號或密碼錯誤", type: AppToastType.error);
      }
    } catch (e) {
      debugPrint("[LoginPage] 登入出錯: $e");

      if (!mounted) return;

      SnackBarBuilder.show(context, "登入發生錯誤，請稍後再試", type: AppToastType.error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final user = await _controller.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        navigateAfterLogin(context);
      } else {
        SnackBarBuilder.show(
          context,
          "Google 登入失敗，請稍後再試",
          type: AppToastType.error,
        );
      }
    } catch (e) {
      debugPrint("[LoginPage] Google 登入出錯: $e");

      if (!mounted) return;

      SnackBarBuilder.show(
        context,
        "Google 登入發生錯誤，請稍後再試",
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            child: Image.asset(AssetPaths.loginBg, fit: BoxFit.cover),
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
                      onGoogleSignIn: _handleGoogleSignIn,
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
