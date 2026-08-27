import 'package:flutter/material.dart';
import '../../controllers/profile_edit_controller.dart';
import '../../styles/app_theme.dart';
import '../constants/asset_paths.dart';
import '../constants/responsive.dart';

import 'package:get/get.dart';

class NicknameField extends StatelessWidget {
  final ProfileEditController controller;

  const NicknameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: Responsive.w(context, 8),
            bottom: Responsive.h(context, 8),
          ),
          child: Text(
            'widgets.profile.edit.nickname.field.s001'.tr,
            style: AppTheme.titleStyle.copyWith(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
              fontSize: Responsive.s(context, 14),
              letterSpacing: 0,
            ),
          ),
        ),

        SizedBox(
          height: Responsive.h(context, 66),
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(AssetPaths.textDialog, fit: BoxFit.fill),
              ),

              Padding(
                padding: EdgeInsets.only(
                  left: Responsive.w(context, 70),
                  right: Responsive.w(context, 10),
                ),
                child: TextField(
                  controller: controller.nameController,
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: Responsive.s(context, 20),
                    color: Colors.brown.shade800,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
                  cursorColor: Colors.brown,
                  decoration: InputDecoration(
                    hintText:
                        '目前的暱稱：${controller.userController.userModel.value?.nickname ?? "冒險者"}',
                    hintStyle: AppTheme.titleStyle.copyWith(
                      color: Colors.brown.shade300,
                      fontSize: Responsive.s(context, 20),
                      letterSpacing: 0,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: Responsive.h(context, 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
