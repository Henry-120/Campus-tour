import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';

import 'package:get/get.dart';

class ClickAndAcceptButton extends StatelessWidget {
  const ClickAndAcceptButton({
    super.key,
    required this.movementFunction,
    required this.acceptInfo,
    this.appearanceText,
    this.appearanceIcon,
    this.appearanceColor,
    this.appearanceTextStyle,
    this.appearanceIconSize,
  });

  final VoidCallback movementFunction;
  final String acceptInfo;
  final String? appearanceText;
  final IconData? appearanceIcon;
  final Color? appearanceColor;
  final TextStyle? appearanceTextStyle;
  final double? appearanceIconSize;

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
            acceptInfo,
            style: ClickAndAcceptButtonStyle.dialogTextStyle,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ClickAndAcceptButtonStyle.dialogActionStyle,
              child: Text('widgets.buttons.click.and.accept.button.s001'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ClickAndAcceptButtonStyle.dialogActionStyle,
              child: Text('widgets.buttons.click.and.accept.button.s002'.tr),
            ),
          ],
        );
      },
    );

    if (shouldMove == true) {
      movementFunction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = appearanceColor ?? ClickAndAcceptButtonStyle.defaultColor;
    final textStyle =
        appearanceTextStyle ?? ClickAndAcceptButtonStyle.buttonTextStyle;
    final iconSize =
        appearanceIconSize ?? ClickAndAcceptButtonStyle.buttonIconSize;

    return TextButton.icon(
      onPressed: () => _showAcceptDialog(context),
      style: ClickAndAcceptButtonStyle.buttonStyle,
      icon: appearanceIcon == null
          ? const SizedBox.shrink()
          : Icon(appearanceIcon, size: iconSize, color: color),
      label: appearanceText == null
          ? const SizedBox.shrink()
          : Text(appearanceText!, style: textStyle.copyWith(color: color)),
    );
  }
}

class ClickAndAcceptButtonStyle {
  static const Color defaultColor = Color(0xFF9E3B2F);
  static const Color barrierColor = Color(0x88000000);
  static const Color dialogBackgroundColor = Colors.white;
  static const double buttonIconSize = 16;

  static final ButtonStyle buttonStyle = TextButton.styleFrom(
    minimumSize: Size(0, 32),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    foregroundColor: defaultColor,
  );

  static const RoundedRectangleBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
  );

  static final TextStyle buttonTextStyle = AppTheme.titleStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static final TextStyle dialogTextStyle = AppTheme.titleStyle.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Color(0xFF4D2C27),
    letterSpacing: 0,
  );

  static final ButtonStyle dialogActionStyle = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    foregroundColor: defaultColor,
    textStyle: AppTheme.titleStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
  );
}
