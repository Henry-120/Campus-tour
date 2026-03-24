import 'package:flutter/material.dart';
import '../common/user_head.dart';

class UserHud extends StatelessWidget {
  final String userName;
  const UserHud({super.key, this.userName = "冒險者"});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 大頭貼
        UserHead(),
        const SizedBox(width: 10),
        // 名字
        Text(
          userName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            // shadows: [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1))],
          ),
        ),
      ],
    );
  }
}