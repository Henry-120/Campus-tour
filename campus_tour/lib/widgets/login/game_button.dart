import 'package:flutter/material.dart';

class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.bg,
    this.isLoading = false,
    this.height = 66,
    this.fontSize = 27,
    this.loadingSize = 26,
  });

  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final String bg;
  final double height;
  final double fontSize;
  final double loadingSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bg),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: loadingSize,
                height: loadingSize,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 5
                        ..color = const Color(0xFF1D2A2F),
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
