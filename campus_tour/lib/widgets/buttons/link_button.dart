import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

class LinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const LinkButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: AppTheme.linkTextStyle),
    );
  }
}