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
      style: OutlinedButton.styleFrom(
        foregroundColor: DrawerStyles.sbutton_font_color,
        backgroundColor: DrawerStyles.sbutton_bg_color,
        side: const BorderSide(
          color: DrawerStyles.sbutton_side_color, // 邊框也設為橘色
          width: DrawerStyles.sbutton_side_width, // 邊框粗細
        ),
        minimumSize: DrawerStyles.sbutton_size,
      ),
      onPressed: onPressedToDo,
      child: Text(text, style: DrawerStyles.second_button_text),
    );
  }
}
