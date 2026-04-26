import 'package:flutter/material.dart';

import '../controllers/login_controller.dart';
import '../widgets/constants/asset_paths.dart';
import '../widgets/constants/responsive.dart';
import '../widgets/login/game_link_text.dart';
import '../widgets/login/game_title.dart';
import '../widgets/login/wood_register_panel.dart';
import 'game_main_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LoginController _controller = LoginController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("請確認註冊資料是否正確")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _controller.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("註冊成功！歡迎加入冒險之旅")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const GameMainPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("註冊失敗，該 Email 可能已被使用或網路異常")),
        );
      }
    } catch (e) {
      debugPrint("[RegisterPage] 註冊出錯: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("註冊失敗: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final user = await _controller.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google 註冊成功！歡迎加入冒險之旅")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const GameMainPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google 註冊失敗，請稍後再試")),
        );
      }
    } catch (e) {
      debugPrint("[RegisterPage] Google 登入失敗: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google 登入失敗: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goBackToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 12 * scale),
                      const GameTitle(title: "REGISTER"),
                      SizedBox(height: 10 * scale),
                      WoodRegisterPanel(
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmController: _confirmController,
                        isLoading: _isLoading,
                        onRegister: _register,
                        onGoogleSignIn: _handleGoogleSignIn,
                        onBackToLogin: _goBackToLogin,
                      ),
                      GameLinkText(
                        text: "Already have account?",
                        onTap: () {},
                        fontSize: 14 * scale,
                      ),
                      GameLinkText(
                        text: "Return to Login",
                        onTap: _isLoading ? () {} : _goBackToLogin,
                        fontSize: 14 * scale,
                      ),
                      SizedBox(height: 24 * scale),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
