import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../profile_edit/profile_edit_dialog.dart';

/// 這是彈出修改個人資料對話框的統一入口
Future<void> showEditProfileDialog(
  BuildContext context,
  UserController controller,
) async {
  final uid = controller.currentUid;
  final user = controller.userModel.value;
  if (uid == null || user == null || user.uid != uid) {
    Get.snackbar(
      'controllers.profile.edit.controller.s002'.tr,
      'utils.firebase.auth.error.message.s026'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => ProfileEditDialog(
      userController: controller,
      initialUser: user,
      editingUid: uid,
    ),
  );
}
