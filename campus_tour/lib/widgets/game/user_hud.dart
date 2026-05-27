import 'package:flutter/material.dart';
import '../constants/responsive.dart';
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
    final scale = Responsive.scale(context);

    return SizedBox(
      width: hudWidth * scale,
      height: hudHeight * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(top: 0, child: UserAvatar(size: avatarSize * scale)),

          Positioned(
            top: 108 * scale,
            child: UserNameBoard(
              width: boardWidth * scale,
              height: boardHeight * scale,
            ),
          ),
        ],
      ),
    );
  }
}
