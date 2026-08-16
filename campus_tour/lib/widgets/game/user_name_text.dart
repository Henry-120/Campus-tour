import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/user_controller.dart';
import '../../styles/app_theme.dart';

class UserNameText extends StatelessWidget {
  final double scale;

  const UserNameText({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Align(
      alignment: Alignment.center,
      child: Obx(() {
        final nickname =
            userController.userModel.value?.nickname ??
            'controllers.login.controller.s004'.tr;

        return Text(
          nickname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.gameTextStyle(20 * scale),
        );
      }),
    );
  }
}
