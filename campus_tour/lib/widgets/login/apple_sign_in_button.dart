import 'package:flutter/material.dart';

class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
    required this.onTap,
    required this.size,
    this.disabled = false,
  });

  final VoidCallback onTap;
  final double size;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sign in with Apple',
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: Material(
          color: Colors.black,
          shape: const CircleBorder(
            side: BorderSide(color: Colors.white, width: 2),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: disabled ? null : onTap,
            child: SizedBox.square(
              dimension: size,
              child: Icon(Icons.apple, color: Colors.white, size: size * 0.62),
            ),
          ),
        ),
      ),
    );
  }
}
