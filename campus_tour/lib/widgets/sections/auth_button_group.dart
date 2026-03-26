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
        PrimaryButton(text: 'Login', onPressed: onLogin),
        const SizedBox(height: AppTheme.elementSpacing),
        SecondaryButton(text: 'Register', onPressed: onRegister),
        const SizedBox(height: AppTheme.elementSpacing + 10),
        LinkButton(text: 'Google Login', onPressed: onGoogleLogin),
      ],
    );
  }
}