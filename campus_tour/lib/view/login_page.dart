import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../styles/app_theme.dart';
import '../controllers/login_controller.dart';
import '../controllers/user_controller.dart'; // 💡 引入 UserController
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

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final user = await _controller.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        // 💡 關鍵修正：登入成功後，手動等待 UserController 抓取完資料
        if (Get.isRegistered<UserController>()) {
          debugPrint("[LoginPage] 登入成功，正在抓取使用者資料...");
          await Get.find<UserController>().fetchCurrentUser();
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GameMainPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("帳號或密碼錯誤")),
        );
      }
    } catch (e) {
      debugPrint("[LoginPage] 登入發生錯誤: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.warmGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Text("Campus Tour", style: AppTheme.titleStyle),
              const SizedBox(height: 8),
              const Text("開啟你的校園冒險之旅", 
                style: TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(AppTheme.cardPadding * 1.5),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    const Text("登入遊戲", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: AppTheme.inputDecoration("電子郵件", Icons.email_outlined),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: AppTheme.inputDecoration("密碼", Icons.lock_outline),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text("進入冒險", style: AppTheme.buttonTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: const Text("還沒有帳號？立即加入冒險", style: AppTheme.linkTextStyle),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
