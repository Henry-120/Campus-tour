import 'package:flutter/material.dart';
import '../../models/item_model.dart';

class ElfCard extends StatelessWidget {
  final ElfItem item;
  final VoidCallback onTap;

  const ElfCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.catching_pokemon,
                size: 40,
                color: item.isUnlocked ? Colors.blue : Colors.grey),
            const SizedBox(height: 8),
            Text('No.${item.id}', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}