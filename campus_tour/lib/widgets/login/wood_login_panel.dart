import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';
import '../constants/asset_paths.dart';
import '../constants/responsive.dart';
import 'game_button.dart';
import 'apple_sign_in_button.dart';
import 'game_link_text.dart';
import 'google_image_button.dart';
import 'login_text_field.dart';

class WoodLoginPanel extends StatelessWidget {
  const WoodLoginPanel({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onRegister,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return SizedBox(
      width: 390 * scale,
      height: 580 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(AssetPaths.woodBoard, fit: BoxFit.fill),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              76 * scale,
              64 * scale,
              60 * scale,
              80 * scale,
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
                  height: 50 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 0,
                ),
                SizedBox(height: 18 * scale),
                _buildLabel(context, "Password"),
                SizedBox(height: 8 * scale),
                LoginTextField(
                  controller: passwordController,
                  hintText: "Enter your Password",
                  icon: Icons.lock,
                  isPasswordField: true,
                  height: 50 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 0,
                ),
                SizedBox(height: 22 * scale),
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
                SizedBox(height: 12 * scale),
                GameLinkText(
                  text: "-- OR LOGIN VIA --",
                  onTap: () {},
                  fontSize: 16 * scale,
                  color: AppTheme.loginGlowColor,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10 * scale,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GoogleImageButton(
                  imagePath: AssetPaths.googleLogo,
                  size: 88 * scale,
                  disabled: isLoading,
                  onTap: onGoogleSignIn,
                ),
                SizedBox(width: 14 * scale),
                AppleSignInButton(
                  size: 66 * scale,
                  disabled: isLoading,
                  onTap: onAppleSignIn,
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

    return Text(text, style: AppTheme.loginLabelStyle(scale));
  }
}
