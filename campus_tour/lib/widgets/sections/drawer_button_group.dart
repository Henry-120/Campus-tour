import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_tour/controllers/login_controller.dart';
import 'package:campus_tour/controllers/user_controller.dart';
import 'package:campus_tour/styles/lhf_drawer_styles.dart';
import 'package:campus_tour/view/map_suggestions.dart';
import 'package:campus_tour/view/novice_leading_page.dart';
import 'package:campus_tour/view/start_page.dart';
import 'package:campus_tour/widgets/buttons/drawer_button.dart';
import 'package:campus_tour/widgets/common/snackbar_builder.dart';
import 'package:campus_tour/widgets/common/user_head.dart';
import 'package:campus_tour/view/AED_map.dart';

class DrawerButtonGroup extends StatelessWidget {
  DrawerButtonGroup({super.key});
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
                              // const _SettingButton(),
                              const _TutorialButton(),
                              const _PanoramaMapButton(),
                              const _IssueReportButton(),
                              const _SecurityButton(),
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
                    children: [
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

    return UserHead(size: DrawerStyles.drawerAvatarSize);
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
      child: Icon(Icons.person_rounded, color: Colors.white, size: 34),
    );
  }
}

class _DrawerUserName extends StatelessWidget {
  const _DrawerUserName();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserController>()) {
      return Text(
        'widgets.sections.drawer.button.group.s001'.tr,
        style: DrawerStyles.userNameText,
      );
    }

    final userController = Get.find<UserController>();

    return Obx(() {
      final nickname = userController.userModel.value?.nickname.trim();
      final displayName = nickname == null || nickname.isEmpty
          ? 'widgets.sections.drawer.button.group.s001'.tr
          : nickname;

      return Text(displayName, style: DrawerStyles.userNameText);
    });
  }
}

// class _SettingButton extends StatelessWidget {
//   const _SettingButton();

//   //設定按鈕實體化
//   void onPress(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => SettingPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DrawerSecondaryButton(
//       text: '設定',
//       onPressedToDo: () => onPress(context),
//     );
//   }
// }

class _TutorialButton extends StatelessWidget {
  const _TutorialButton();

  void _onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoviceLeadingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: 'widgets.sections.drawer.button.group.s003'.tr,
      onPressedToDo: () => _onPress(context),
    );
  }
}

class _PanoramaMapButton extends StatelessWidget {
  const _PanoramaMapButton();

  void _onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapSuggestionsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: 'widgets.sections.drawer.button.group.s004'.tr,
      onPressedToDo: () => _onPress(context),
    );
  }
}

class _IssueReportButton extends StatelessWidget {
  const _IssueReportButton();

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: 'widgets.sections.drawer.button.group.s005'.tr,
      onPressedToDo: () => _showFeatureNotImplementedMessage(context),
    );
  }
}

class _SecurityButton extends StatelessWidget {
  const _SecurityButton();

  void _onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AEDMap()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerSecondaryButton(
      text: '校園安全',
      onPressedToDo: () => _onPress(context),
    );
  }
}

void _showFeatureNotImplementedMessage(BuildContext context) {
  SnackBarBuilder.show(
    context,
    'widgets.sections.drawer.button.group.s006'.tr,
    type: AppToastType.info,
  );
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton();

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      await LoginController().logout();

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => StartPage()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarBuilder.show(
        context,
        'widgets.sections.drawer.button.group.s007'.tr,
        type: AppToastType.error,
      );
      setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: DrawerStyles.logoutButtonStyle,
      onPressed: _isLoggingOut ? null : _logout,
      icon: _isLoggingOut
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.logout_rounded),
      label: Text(
        _isLoggingOut
            ? 'widgets.sections.drawer.button.group.s008'.tr
            : 'widgets.sections.drawer.button.group.s009'.tr,
        style: DrawerStyles.logoutButtonText,
      ),
    );
  }
}
