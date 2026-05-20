import 'package:flutter/material.dart';
import 'elf_section_title.dart';

class ElfStorySection extends StatelessWidget {
  final String name;
  final String? story;
  final bool isLoading;

  const ElfStorySection({
    super.key,
    required this.name,
    required this.story,
    required this.isLoading,
  });

  static const Color primaryColor = Color(0xFF006C49);
  static const Color cardColor = Color(0xFFEFF4FF);
  static const Color subTextColor = Color(0xFF3C4A42);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElfSectionTitle(
              icon: Icons.auto_stories,
              title: "$name傳說故事",
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              )
            else
              Text(
                story ?? "沒有故事資料",
                style: const TextStyle(
                  fontSize: 16,
                  color: subTextColor,
                  height: 1.6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}