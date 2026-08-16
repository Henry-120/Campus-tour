import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_edit_controller.dart';
import '../../styles/app_theme.dart';
import '../constants/asset_paths.dart';
import 'avatar_preview.dart';
import 'game_dialog_button.dart';
import 'nickname_field.dart';
import '../constants/responsive.dart';

class ProfileEditDialog extends StatelessWidget {
  const ProfileEditDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileEditController());

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 28)),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(context, 35),
          Responsive.h(context, 34),
          Responsive.w(context, 35),
          Responsive.h(context, 50),
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.changeNameBg),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(Responsive.s(context, 24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            SizedBox(height: Responsive.h(context, 20)),
            AvatarPreview(controller: controller),
            SizedBox(height: Responsive.h(context, 12)),
            Text(
              'widgets.profile.edit.profile.edit.dialog.s001'.tr,
              style: AppTheme.titleStyle.copyWith(
                color: Colors.brown,
                fontSize: Responsive.s(context, 14),
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: Responsive.h(context, 25)),
            NicknameField(controller: controller),
            SizedBox(height: Responsive.h(context, 25)),
            _buildActions(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome,
          color: Colors.orange.shade400,
          size: Responsive.s(context, 28),
        ),
        SizedBox(width: Responsive.w(context, 8)),
        Flexible(
          child: Text(
            'widgets.profile.edit.profile.edit.dialog.s002'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.titleStyle.copyWith(
              fontSize: Responsive.s(context, 22),
              fontWeight: FontWeight.bold,
              color: Colors.brown,
              letterSpacing: 0,
            ),
          ),
        ),
        SizedBox(width: Responsive.w(context, 8)),
        Icon(
          Icons.auto_awesome,
          color: Colors.orange.shade400,
          size: Responsive.s(context, 28),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ProfileEditController controller) {
    return Row(
      children: [
        Expanded(
          child: GameDialogButton(
            text: 'widgets.profile.edit.profile.edit.dialog.s003'.tr,
            icon: Icons.menu_book_rounded,
            backgroundColor: Color(0xFFDCE8E2),
            borderColor: Color(0xFF7E9188),
            textColor: Color(0xFF4F5F5A),
            onTap: () => Navigator.pop(context),
          ),
        ),
        SizedBox(width: Responsive.w(context, 18)),
        Expanded(
          child: GameDialogButton(
            text: 'widgets.profile.edit.profile.edit.dialog.s004'.tr,
            icon: Icons.edit_document,
            backgroundColor: Color(0xFFEFA640),
            borderColor: Color(0xFFB86E22),
            textColor: Colors.white,
            onTap: () async {
              await controller.saveProfile();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
