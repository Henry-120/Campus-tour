import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import 'package:campus_tour/widgets/common/welcome_logo.dart';
import '../widgets/sections/auth_button_group.dart';
import 'login_page.dart';
import 'register_page.dart';


class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.horizontalPadding,
          ),
          child: Center(
            child: SingleChildScrollView(
              // 防止內容過多時溢出
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const WelcomeLogo(),
                  const SizedBox(height: AppTheme.sectionSpacing),
                  AuthButtonGroup(
                    onLogin: () => _navigateTo(context, 'login'),
                    onRegister: () => _navigateTo(context, 'register'),
                    onGoogleLogin: () => _handleGoogleLogin(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String pageType) {
    // 宣告一個變數來儲存目標頁面
    Widget destination;

    // 根據傳入的字串判斷要跳轉到哪一個 Widget
    if (pageType == 'login') {
      destination = const LoginPage(); // 這裡請確保你有定義 LoginPage
    } else if (pageType == 'register') {
      destination = const RegisterPage(); // 這裡請確保你有定義 RegisterPage
    } else {
      // 預設跳轉（例如回主畫面或報錯）
      destination = const WelcomePage();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  void _handleGoogleLogin() {
    debugPrint('執行 Google 登入');
  }
}