import 'package:flutter/material.dart';

import '../constants/asset_paths.dart';
import '../constants/responsive.dart';
import 'game_button.dart';
import 'game_link_text.dart';
import 'google_image_button.dart';
import 'login_text_field.dart';

class WoodRegisterPanel extends StatelessWidget {
  const WoodRegisterPanel({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.isLoading,
    required this.onRegister,
    required this.onGoogleSignIn,
    required this.onBackToLogin,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  final bool isLoading;

  final VoidCallback onRegister;
  final VoidCallback onGoogleSignIn;
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
            child: Image.asset(
              AssetPaths.rWoodBoard,
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
                _buildLabel(context, "Name"),
                SizedBox(height: 6 * scale),
                LoginTextField(
                  controller: nameController,
                  hintText: "Enter your Name",
                  icon: Icons.person,
                  height: 46 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 13 * scale,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "請輸入名稱";
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
                  height: 46 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 13 * scale,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "請輸入 Email";
                    }

                    final emailRegex = RegExp(
                      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                    );

                    if (!emailRegex.hasMatch(value.trim())) {
                      return "Email 格式不正確";
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
                  height: 46 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 13 * scale,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "請輸入密碼";
                    }

                    if (value.length < 6) {
                      return "密碼至少需要 6 位";
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
                  height: 46 * scale,
                  fontSize: 16 * scale,
                  hintFontSize: 14 * scale,
                  iconSize: 22 * scale,
                  radius: 12 * scale,
                  verticalPadding: 13 * scale,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "請再次輸入密碼";
                    }

                    if (value != passwordController.text) {
                      return "兩次密碼不一致";
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
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 10 * scale,
            child: GoogleImageButton(
              imagePath: AssetPaths.googleLogo,
              size: 100 * scale,
              disabled: isLoading,
              onTap: onGoogleSignIn,
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
