import 'package:flutter/material.dart';

import '../constants/asset_paths.dart';
import '../constants/responsive.dart';
import 'game_button.dart';
import 'game_link_text.dart';
import 'login_text_field.dart';

class WoodLoginPanel extends StatelessWidget {
  const WoodLoginPanel({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onRegister,
    required this.onForgotPassword,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return SizedBox(
      width: 390 * scale,
      height: 560 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              AssetPaths.woodBoard,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              76 * scale,
              72 * scale,
              60 * scale,
              42 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabel(context, "Username"),
                SizedBox(height: 8 * scale),
                LoginTextField(
                  controller: emailController,
                  hintText: "Enter your Username",
                  icon: Icons.eco,
                  height: 46 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 13 * scale,
                ),
                SizedBox(height: 18 * scale),
                _buildLabel(context, "Password"),
                SizedBox(height: 8 * scale),
                LoginTextField(
                  controller: passwordController,
                  hintText: "Enter your Password",
                  icon: Icons.lock,
                  isPasswordField: true,
                  height: 46 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 13 * scale,
                ),
                SizedBox(height: 28 * scale),
                GameButton(
                  text: "LOGIN",
                  isLoading: isLoading,
                  onTap: onLogin,
                  bg: AssetPaths.buttonGreen,
                  height: 66 * scale,
                  fontSize: 27 * scale,
                  loadingSize: 26 * scale,
                ),
                SizedBox(height: 14 * scale),
                GameButton(
                  text: "REGISTER",
                  onTap: onRegister,
                  bg: AssetPaths.buttonBlue,
                  height: 66 * scale,
                  fontSize: 27 * scale,
                  loadingSize: 26 * scale,
                ),
                SizedBox(height: 18 * scale),
                GameLinkText(
                  text: "Forgot Password?",
                  onTap: onForgotPassword,
                  fontSize: 18 * scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final scale = Responsive.scale(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: 21 * scale,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: [
          Shadow(
            offset: Offset(2 * scale, 2 * scale),
            blurRadius: 1 * scale,
            color: Colors.black.withValues(alpha: 0.75),
          ),
        ],
      ),
    );
  }
}
