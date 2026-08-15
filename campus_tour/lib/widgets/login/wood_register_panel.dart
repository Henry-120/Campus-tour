import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';
import '../constants/asset_paths.dart';
import '../constants/responsive.dart';
import 'game_button.dart';
import 'apple_sign_in_button.dart';
import 'game_link_text.dart';
import 'google_image_button.dart';
import 'login_text_field.dart';

import 'package:get/get.dart';

class WoodRegisterPanel extends StatelessWidget {
  WoodRegisterPanel({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.isLoading,
    required this.onRegister,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    required this.onBackToLogin,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  final bool isLoading;

  final VoidCallback onRegister;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return SizedBox(
      width: 390 * scale,
      height: 680 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(AssetPaths.rWoodBoard, fit: BoxFit.fill),
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
                _buildLabel(context, "Name"),
                SizedBox(height: 6 * scale),
                LoginTextField(
                  controller: nameController,
                  hintText: "Enter your Name",
                  icon: Icons.person,
                  height: 50 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 0,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'widgets.login.wood.register.panel.s001'.tr;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 11 * scale),

                _buildLabel(context, "Email"),
                SizedBox(height: 6 * scale),
                LoginTextField(
                  controller: emailController,
                  hintText: "Enter your Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  height: 50 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 0,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'widgets.login.wood.register.panel.s002'.tr;
                    }

                    final emailRegex = RegExp(
                      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                    );

                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'widgets.login.wood.register.panel.s003'.tr;
                    }

                    return null;
                  },
                ),

                SizedBox(height: 11 * scale),

                _buildLabel(context, "Password"),
                SizedBox(height: 6 * scale),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'widgets.login.wood.register.panel.s004'.tr;
                    }

                    if (value.length < 6) {
                      return 'widgets.login.wood.register.panel.s005'.tr;
                    }

                    return null;
                  },
                ),

                SizedBox(height: 11 * scale),

                _buildLabel(context, "Confirm"),
                SizedBox(height: 6 * scale),
                LoginTextField(
                  controller: confirmController,
                  hintText: "Confirm Password",
                  icon: Icons.verified_user,
                  isPasswordField: true,
                  height: 50 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 0,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'widgets.login.wood.register.panel.s006'.tr;
                    }

                    if (value != passwordController.text) {
                      return 'widgets.login.wood.register.panel.s007'.tr;
                    }

                    return null;
                  },
                ),

                SizedBox(height: 20 * scale),

                GameButton(
                  text: "REGISTER",
                  isLoading: isLoading,
                  onTap: isLoading ? null : onRegister,
                  bg: AssetPaths.buttonGreen,
                  height: 66 * scale,
                  fontSize: 27 * scale,
                  loadingSize: 26 * scale,
                ),

                SizedBox(height: 14 * scale),

                GameLinkText(
                  text: "-- OR REGISTRATION VIA --",
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
                  size: 100 * scale,
                  disabled: isLoading,
                  onTap: onGoogleSignIn,
                ),
                SizedBox(width: 12 * scale),
                AppleSignInButton(
                  size: 70 * scale,
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
