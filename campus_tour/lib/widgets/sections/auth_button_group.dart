import 'package:flutter/material.dart';
import '../buttons/action_buttons.dart';
import '../buttons/link_button.dart';
import '../../styles/app_theme.dart';

class AuthButtonGroup extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onGoogleLogin;

  const AuthButtonGroup({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(text: '登入', onPressed: onLogin),
        const SizedBox(height: AppTheme.elementSpacing),
        SecondaryButton(text: '註冊', onPressed: onRegister),
        const SizedBox(height: AppTheme.elementSpacing + 10),
        LinkButton(text: '使用 google 登入', onPressed: onGoogleLogin),
      ],
    );
  }
}