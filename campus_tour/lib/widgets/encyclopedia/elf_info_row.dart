import 'package:flutter/material.dart';

class ElfInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ElfInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color primaryColor = Color(0xFF006C49);
  static const Color textColor = Color(0xFF0B1C30);
  static const Color subTextColor = Color(0xFF3C4A42);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: subTextColor,
            ),
          ),
        ),
      ],
    );
  }
}