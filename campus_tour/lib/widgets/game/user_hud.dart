import 'package:flutter/material.dart';
import 'user_avatar.dart';
import 'user_name_board.dart';

class UserHud extends StatelessWidget {
  const UserHud({super.key});

  static const double hudWidth = 140;
  static const double hudHeight = 155;

  static const double avatarSize = 125;
  static const double boardWidth = 125;
  static const double boardHeight = 42;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: hudWidth,
      height: hudHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: UserAvatar(size: avatarSize),
          ),

          Positioned(
            top: 108,
            child: UserNameBoard(
              width: boardWidth,
              height: boardHeight,
            ),
          ),
        ],
      ),
    );
  }
}