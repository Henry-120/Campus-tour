import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/user_head.dart';
import '../../controllers/user_controller.dart';

class UserHud extends StatelessWidget {
  const UserHud({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        // 1. 後方的名稱底色氣泡
        Padding(
          // 💡 修正錯誤：使用 EdgeInsets.only(left: 45)
          padding: const EdgeInsets.only(left: 45), 
          child: Obx(() {
            final nickname = userController.userModel.value?.nickname ?? "冒險者";
            return Container(
              padding: const EdgeInsets.fromLTRB(50, 8, 20, 8), 
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(242), // 0.95 opacity
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                border: Border.all(color: Colors.orange.shade300, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withAlpha(51), // 0.2 opacity
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nickname,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange.shade900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),

        // 2. 前方的大頭貼 (加大到 85)
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38), // 0.15 opacity
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const UserHead(size: 85),
        ),
      ],
    );
  }
}
