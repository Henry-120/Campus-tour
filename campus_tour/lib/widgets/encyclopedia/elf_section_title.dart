import 'package:flutter/material.dart';

class ElfSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const ElfSectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  static const Color primaryColor = Color(0xFF006C49);
  static const Color textColor = Color(0xFF0B1C30);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}