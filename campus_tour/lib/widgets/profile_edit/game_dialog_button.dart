import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';
import '../constants/responsive.dart';

class GameDialogButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const GameDialogButton({
    super.key,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Responsive.s(context, 58),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(Responsive.s(context, 28)),
          border: Border.all(
            color: borderColor,
            width: Responsive.s(context, 2.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              offset: Offset(0, Responsive.s(context, 4)),
              blurRadius: Responsive.s(context, 4),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.45),
              offset: Offset(0, -Responsive.s(context, 2)),
              blurRadius: Responsive.s(context, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: -0.25,
              child: Icon(
                icon,
                size: Responsive.s(context, 30),
                color: textColor,
              ),
            ),
            SizedBox(width: Responsive.w(context, 8)),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.titleStyle.copyWith(
                  fontSize: Responsive.s(context, 18),
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: Responsive.s(context, 1.2),
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      offset: Offset(
                        Responsive.s(context, 1),
                        Responsive.s(context, 1),
                      ),
                      blurRadius: Responsive.s(context, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
