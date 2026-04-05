import 'package:flutter/material.dart';

import '../../models/user_monster_model.dart';

class ElfCard extends StatelessWidget {
  final UserMonsterModel item;
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
                color:Colors.blue),
            const SizedBox(height: 8),
            Text(item.name, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}