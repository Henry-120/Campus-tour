import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple-guideline Sign in with Apple button used only to start Apple auth.
class OfficialAppleSignInButton extends StatelessWidget {
  const OfficialAppleSignInButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width = 170,
    this.height = 44,
    this.disabled = false,
    this.logoOnly = false,
  });

  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;
  final bool disabled;
  final bool logoOnly;

  @override
  Widget build(BuildContext context) {
    if (logoOnly) {
      return Semantics(
        button: true,
        enabled: !disabled,
        label: text,
        child: SizedBox(
          width: width,
          height: height,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(height / 2),
            color: Colors.black,
            disabledColor: Colors.black.withValues(alpha: 0.55),
            onPressed: disabled ? null : onPressed,
            child: Center(
              child: SizedBox(
                width: height * 0.42,
                height: height * 0.5,
                child: CustomPaint(
                  painter: AppleLogoPainter(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: SignInWithAppleButton(
        onPressed: disabled ? null : onPressed,
        text: text,
        height: height,
        style: SignInWithAppleButtonStyle.black,
        borderRadius: BorderRadius.circular(8),
        iconAlignment: SignInWithAppleIconAlignment.center,
      ),
    );
  }
}
