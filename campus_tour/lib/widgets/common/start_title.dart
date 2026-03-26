import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartTitle extends StatelessWidget {
  final String title;
  const StartTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.zcoolQingKeHuangYou(
        fontSize: 60,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: const [
          Shadow(
            color: Colors.blue, 
            blurRadius: 10, 
            offset: Offset(2, 2)
          ),
        ],
      ),
    );
  }
}