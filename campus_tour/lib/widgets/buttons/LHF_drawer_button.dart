import 'package:flutter/material.dart';
import "package:campus_tour/styles/LHF_drawer_styles.dart";

// Abc for class
// a_b_c for var
//aBc for funtion

class DrawerSecondaryButton extends StatelessWidget {
  // 按鈕殼
  final String text;
  final VoidCallback onPressedToDo;
  const DrawerSecondaryButton({
    super.key,
    required this.text,
    required this.onPressedToDo,
  });
  //drawer按鈕
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: DrawerStyles.drawer_button_style,
      onPressed: onPressedToDo,
      child: Text(text, style: DrawerStyles.second_button_text),
    );
  }
}
