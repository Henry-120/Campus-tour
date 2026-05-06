import 'package:flutter/material.dart';
import 'elf_info_row.dart';

class ElfInstallationSection extends StatelessWidget {
  final String imagePath;
  final String location;
  final String year;

  const ElfInstallationSection({
    super.key,
    required this.imagePath,
    required this.location,
    required this.year,
  });

  static const Color cardColor = Color(0xFFEFF4FF);
  static const Color textColor = Color(0xFF0B1C30);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Installation Art (裝置藝術)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      ElfInfoRow(
                        icon: Icons.location_on,
                        label: 'Location (設置位置): ',
                        value: location,
                      ),
                      const SizedBox(height: 12),
                      ElfInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Year (設置年代): ',
                        value: year,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}