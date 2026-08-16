import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';

import 'package:get/get.dart';

class FilterBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const FilterBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //首頁+頁碼+末頁
          Text(
            'widgets.encyclopedia.filter.bar.s001'.tr,
            style: AppTheme.titleStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
          ...List.generate(4, (index) => _buildChip(index + 1)),
          Text(
            'widgets.encyclopedia.filter.bar.s002'.tr,
            style: AppTheme.titleStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),

          //根據屬性篩選
          Icon(Icons.filter_list),
        ],
      ),
    );
  }

  Widget _buildChip(int label) {
    bool isSelected = selectedIndex == label;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label',
          style: AppTheme.titleStyle.copyWith(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
