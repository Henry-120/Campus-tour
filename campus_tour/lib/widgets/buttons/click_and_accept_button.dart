import 'package:flutter/material.dart';

class ClickAndAcceptButton extends StatelessWidget {
  const ClickAndAcceptButton({
    super.key,
    required this.movementFuntion,
    required this.accept_info,
    this.AppearanceText,
    this.AppearanceIcon,
    this.AppearanceColor,
    this.AppearanceTextStyle,
    this.AppearanceIconSize,
  });

  final VoidCallback movementFuntion;
  final String accept_info;
  final String? AppearanceText;
  final IconData? AppearanceIcon;
  final Color? AppearanceColor;
  final TextStyle? AppearanceTextStyle;
  final double? AppearanceIconSize;

  Future<void> _showAcceptDialog(BuildContext context) async {
    final shouldMove = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: ClickAndAcceptButtonStyle.barrierColor,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ClickAndAcceptButtonStyle.dialogBackgroundColor,
          shape: ClickAndAcceptButtonStyle.dialogShape,
          content: Text(
            accept_info,
            style: ClickAndAcceptButtonStyle.dialogTextStyle,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ClickAndAcceptButtonStyle.dialogActionStyle,
              child: const Text('確定'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ClickAndAcceptButtonStyle.dialogActionStyle,
              child: const Text('取消'),
            ),
          ],
        );
      },
    );

    if (shouldMove == true) {
      movementFuntion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppearanceColor ?? ClickAndAcceptButtonStyle.defaultColor;
    final textStyle =
        AppearanceTextStyle ?? ClickAndAcceptButtonStyle.buttonTextStyle;
    final iconSize =
        AppearanceIconSize ?? ClickAndAcceptButtonStyle.buttonIconSize;

    return TextButton.icon(
      onPressed: () => _showAcceptDialog(context),
      style: ClickAndAcceptButtonStyle.buttonStyle,
      icon: AppearanceIcon == null
          ? const SizedBox.shrink()
          : Icon(AppearanceIcon, size: iconSize, color: color),
      label: AppearanceText == null
          ? const SizedBox.shrink()
          : Text(AppearanceText!, style: textStyle.copyWith(color: color)),
    );
  }
}

class ClickAndAcceptButtonStyle {
  static const Color defaultColor = Color(0xFF9E3B2F);
  static const Color barrierColor = Color(0x88000000);
  static const Color dialogBackgroundColor = Colors.white;
  static const double buttonIconSize = 16;

  static final ButtonStyle buttonStyle = TextButton.styleFrom(
    minimumSize: const Size(0, 32),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    foregroundColor: defaultColor,
  );

  static const RoundedRectangleBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle dialogTextStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Color(0xFF4D2C27),
  );

  static final ButtonStyle dialogActionStyle = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    foregroundColor: defaultColor,
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );
}
