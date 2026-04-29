import 'package:flutter/material.dart';
import '../common/user_head.dart';

class UserAvatar extends StatelessWidget {
  final double size;

  const UserAvatar({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: UserHead(size: size),
    );
  }
}