import 'package:flutter/material.dart';
import '../common/user_head.dart';
import '../../styles/app_theme.dart';

class UserHud extends StatelessWidget {
  final String userName;
  const UserHud({super.key, this.userName = "Adventurer"});

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
          style: AppTheme.hudNameStyle,
        ),
      ],
    );
  }
}