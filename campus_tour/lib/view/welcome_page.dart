import 'package:campus_tour/view/game_main_page.dart';
import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import 'package:campus_tour/widgets/common/welcome_logo.dart';
import '../widgets/sections/auth_button_group.dart';
import 'login_page.dart';
import 'register_page.dart';
import '../services/google_auth_service.dart';


class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _handleGoogleLogin(BuildContext context) async {
    debugPrint('執行 Google 登入');
    final googleAuthService = GoogleAuthService();
    final user = await googleAuthService.signInWithGoogle();

    if (!context.mounted) return;
    
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            "Google 登入成功！歡迎 ${user.displayName ?? "使用者"}")),
      );
      debugPrint('登入成功');
      _navigateTo(context, 'google_login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google 登入失敗，請再試一次")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.horizontalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const WelcomeLogo(),
              const SizedBox(height: AppTheme.sectionSpacing),
              AuthButtonGroup(
                onLogin: () => _navigateTo(context, 'login'),
                onRegister: () => _navigateTo(context, 'register'),
                onGoogleLogin: () => _handleGoogleLogin(context),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String pageType) {
    debugPrint('[Debug][WelcomePage]Navigating to: $pageType');
    // 宣告一個變數來儲存目標頁面
    Widget destination;

    // 根據傳入的字串判斷要跳轉到哪一個 Widget
    if (pageType == 'login') {
      destination = const LoginPage(); // 這裡請確保你有定義 LoginPage
    } else if (pageType == 'register') {
      destination = const RegisterPage(); // 這裡請確保你有定義 RegisterPage
    } else if (pageType == 'google_login') {
      destination = const GameMainPage(); // 這裡請確保你有定義 GameMainPage
    }
    else {
      // 預設跳轉（例如回主畫面或報錯）
      destination = const WelcomePage();
    }

    debugPrint("[Debug][WelcomePage]:正在導航到 $pageType 頁面");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }
}