import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_tour/controllers/user_controller.dart';
import 'package:campus_tour/styles/LHF_drawer_styles.dart';
import 'package:campus_tour/widgets/buttons/LHF_drawer_button.dart';
import 'package:campus_tour/widgets/common/user_head.dart';
import 'package:campus_tour/view/LHF_setting_page.dart';

class DrawerButtonGroup extends StatelessWidget {
  const DrawerButtonGroup({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: DrawerStyles.drawerPadding,
        child: Column(
          crossAxisAlignment: DrawerStyles.drawerCrossAlignment,
          children: [
            const _DrawerUserHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buttonWidth = constraints.maxWidth.clamp(
                    0.0,
                    DrawerStyles.drawerButtonWidth,
                  );

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: buttonWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: DrawerStyles.drawerMainAlignment,
                            crossAxisAlignment:
                                DrawerStyles.drawerCrossAlignment,
                            //填滿格式設定
                            children: [
                              const _SettingButton(),
                              const _TutorialButton(),
                              const _IssueReportButton(),
                            ], //左選單按鈕列,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final buttonWidth = constraints.maxWidth.clamp(
                  0.0,
                  DrawerStyles.drawerButtonWidth,
                );

                return Center(
                  child: SizedBox(
                    width: buttonWidth,
                    child: const _LogoutButton(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerUserHeader extends StatelessWidget {
  const _DrawerUserHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: DrawerStyles.drawerHeaderPadding,
          child: Row(
            children: [
              const _DrawerUserAvatar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _DrawerUserName(),
                      // Text('Campus Tour', style: DrawerStyles.userSubtitleText),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: DrawerStyles.drawerDividerHeight,
          color: DrawerStyles.drawerPanelBorderColor,
        ),
      ],
    );
  }
}

class _DrawerUserAvatar extends StatelessWidget {
  const _DrawerUserAvatar();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserController>()) {
      return const _DefaultDrawerAvatar();
    }

    return const UserHead(size: DrawerStyles.drawerAvatarSize);
  }
}

class _DefaultDrawerAvatar extends StatelessWidget {
  const _DefaultDrawerAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DrawerStyles.drawerAvatarSize,
      height: DrawerStyles.drawerAvatarSize,
      decoration: DrawerStyles.avatarDecoration,
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 34),
    );
  }
}

class _DrawerUserName extends StatelessWidget {
  const _DrawerUserName();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserController>()) {
      return Text('使用者名稱', style: DrawerStyles.userNameText);
    }

    final userController = Get.find<UserController>();

    return Obx(() {
      final nickname = userController.userModel.value?.nickname.trim();
      final displayName = nickname == null || nickname.isEmpty
          ? '使用者名稱'
          : nickname;

      return Text(displayName, style: DrawerStyles.userNameText);
    });
  }
}

class _SettingButton extends StatelessWidget {
  const _SettingButton();

  //設定按鈕實體化
  void onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: '設定',
      onPressedToDo: () => onPress(context),
    );
  }
}

class _TutorialButton extends StatelessWidget {
  const _TutorialButton();

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: '新手教學',
      onPressedToDo: () => _showFeatureNotImplementedMessage(context),
    );
  }
}

class _IssueReportButton extends StatelessWidget {
  const _IssueReportButton();

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: '問題回報',
      onPressedToDo: () => _showFeatureNotImplementedMessage(context),
    );
  }
}

void _showFeatureNotImplementedMessage(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(const SnackBar(content: Text('此功能尚未實做，有問題歡迎聯繫：創作團隊')));
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  void _onPress() {
    debugPrint('[Drawer] logout pressed');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: DrawerStyles.logoutButtonStyle,
      onPressed: _onPress,
      icon: const Icon(Icons.logout_rounded),
      label: Text('登出', style: DrawerStyles.logoutButtonText),
    );
  }
}
