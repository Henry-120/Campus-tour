import 'package:flutter/material.dart';

class ElfTypeTag extends StatelessWidget {
  final String type;

  const ElfTypeTag({
    super.key,
    required this.type,
  });

  static const Color primaryColor = Color(0xFF006C49);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              type.toUpperCase(),
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}