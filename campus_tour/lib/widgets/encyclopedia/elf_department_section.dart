import 'package:flutter/material.dart';

class ElfDepartmentSection extends StatelessWidget {
  final List<String>? major;

  const ElfDepartmentSection({
    super.key,
    required this.major,
  });

  static const Color primaryColor = Color(0xFF006C49);
  static const Color cardColor = Color(0xFFEFF4FF);
  static const Color textColor = Color(0xFF0B1C30);

  @override
  Widget build(BuildContext context) {
    final majors = major ?? [];

    if (majors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 40, bottom: 20, left: 8),
            child: Text(
              'College Departments (學院系館)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          ...majors.asMap().entries.map((entry) {
            final index = entry.key;
            final name = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == majors.length - 1 ? 0 : 16,
              ),
              child: _buildDepartmentItem(name: name),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDepartmentItem({
    required String name,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance,
              color: primaryColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}