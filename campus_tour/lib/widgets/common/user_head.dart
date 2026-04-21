import 'package:flutter/material.dart';

class UserHead extends StatelessWidget {
  const UserHead({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.blueAccent),
    );
  }
}