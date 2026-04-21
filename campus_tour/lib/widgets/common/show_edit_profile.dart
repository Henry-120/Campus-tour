import 'package:flutter/material.dart';
import '../../controllers/user_controller.dart';
import '../profile_edit/profile_edit_dialog.dart';

/// 這是彈出修改個人資料對話框的統一入口
void showEditProfileDialog(BuildContext context, UserController controller) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const ProfileEditDialog(),
  );
}
