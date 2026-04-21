import 'package:campus_tour/controllers/NFC_api.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/nfc_leading_style.dart';

class NfcButton1 extends StatelessWidget {
  final Icon nfc_icon = NfcLeadingStyle.nfc_icon;
  final String text;
  final VoidCallback onPressedToDo;
  final ButtonStyle now_style;

  const NfcButton1({
    super.key,
    required this.text,
    required this.onPressedToDo,
    required this.now_style,
  });
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: nfc_icon,
      style: now_style,
      onPressed: onPressedToDo,
      label: Text(text, style: NfcLeadingStyle.primaryButtonText),
    );
  }
}
