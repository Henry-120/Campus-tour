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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. 背景圖片 (填滿全螢幕)
          Positioned(
            top: 150,      // 💡 往下移動 60 像素，可根據需求調整
            left: 0,
            right: 0,
            bottom: 10,   // 💡 負值確保圖片下方不會留白
            child: Image.asset(
              "assets/images/login_monster_white-removebg-preview.png",
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. 登入內容
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 標題 (白色 + 陰影)
                  Text(
                    "Campus Tour", 
                    style: AppTheme.titleStyle.copyWith(
                      color: Colors.white,
                      shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                    )
                  ),
                  const SizedBox(height: 250),
                  
                  // 登入卡片 (💡 已去背)
                  Container(
                    padding: const EdgeInsets.all(AppTheme.cardPadding * 2),
                    decoration: const BoxDecoration(
                      color: Colors.transparent, // 💡 完全透明
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 30, width: double.infinity*2),
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: AppTheme.inputDecoration("電子郵件", Icons.email_outlined).copyWith(
                            fillColor: Colors.transparent,
                            labelStyle: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: AppTheme.inputDecoration("密碼", Icons.lock_outline).copyWith(
                            fillColor: Colors.transparent,
                            labelStyle: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 200,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
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
                    child: const Text(
                      "還沒有帳號？立即加入冒險", 
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
