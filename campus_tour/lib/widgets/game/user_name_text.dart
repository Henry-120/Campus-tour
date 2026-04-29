import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/user_controller.dart';

class UserNameText extends StatelessWidget {
  const UserNameText({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Align(
      alignment: Alignment.center,
      child: Obx(() {
        final nickname =
            userController.userModel.value?.nickname ?? "冒險者";

        return Text(
          nickname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A2318),
            letterSpacing: 0.8,
          ),
        );
      }),
    );
  }
}