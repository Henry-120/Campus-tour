import 'package:flutter/material.dart';

class WoodenMenuLabel extends StatelessWidget {
  final String text;
  final double? left;
  final double? right;
  final double? bottom;
  final double? top;
  final double? width;
  final double fontSize;

  const WoodenMenuLabel({
    super.key,
    required this.text,
    required this.fontSize,
    this.left,
    this.right,
    this.bottom,
    this.top,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      bottom: bottom,
      top: top,
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFE0B2),
          shadows: const [
            Shadow(
              color: Color(0xFF3A1F12),
              offset: Offset(1, 2),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}