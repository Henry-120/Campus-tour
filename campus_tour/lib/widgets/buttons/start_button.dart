import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartButton extends StatefulWidget {
  final VoidCallback onPressed;

  const StartButton({super.key, required this.onPressed});

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  double _buttonScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _buttonScale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.pinkAccent.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.withValues(alpha: 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          onPressed: () async {
            setState(() => _buttonScale = 1.2);
            await Future.delayed(const Duration(milliseconds: 150));
            setState(() => _buttonScale = 1.0);
            widget.onPressed();
          },
          child: Text(
            "START",
            style: GoogleFonts.zcoolQingKeHuangYou(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}