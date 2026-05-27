import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';
import '../../widgets/common/scale_button.dart';

class StoneButton extends StatelessWidget {
  final String img;
  final String text;
  final double scale;
  final double baseSize;
  final VoidCallback onTap;

  const StoneButton({
    super.key,
    required this.img,
    required this.text,
    required this.scale,
    this.baseSize = 90,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = baseSize * scale;
    return ScaleButton(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(img, width: size, height: size, fit: BoxFit.contain),
            Positioned(
              bottom: 10 * scale,
              left: 6 * scale,
              right: 6 * scale,
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.gameTextStyle(20 * scale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
