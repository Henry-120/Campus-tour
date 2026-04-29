import 'package:flutter/material.dart';
import '../../widgets/common/scale_button.dart';

class StoneButton extends StatelessWidget {
  final String img;
  final String text;
  final double scale;
  final VoidCallback onTap;

  const StoneButton({
    super.key,
    required this.img,
    required this.text,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = 110*scale;
    return ScaleButton(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              img,
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
            Positioned(
              bottom: 15 * scale,
              left: 6 * scale,
              right: 6 * scale,
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A2318),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}