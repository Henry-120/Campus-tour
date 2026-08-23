import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_tour/controllers/login_controller.dart';
import 'package:campus_tour/controllers/user_controller.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:campus_tour/view/MQTT_test.dart';
import 'package:campus_tour/view/map_suggestions.dart';
import 'package:campus_tour/view/novice_leading_page.dart';
import 'package:campus_tour/view/start_page.dart';
import 'package:campus_tour/widgets/common/snackbar_builder.dart';
import 'package:campus_tour/widgets/common/user_head.dart';
import 'package:campus_tour/view/campus_safty.dart';

class DrawerButtonGroup extends StatelessWidget {
  const DrawerButtonGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: SettingPageStyles.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DrawerUserHeader(),
            const SizedBox(height: SettingPageStyles.gapXl),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 244),
                    child: Column(
                      children: const [
                        _TutorialButton(),
                        SizedBox(height: SettingPageStyles.gapMd),
                        _PanoramaMapButton(),
                        SizedBox(height: SettingPageStyles.gapMd),
                        _IssueReportButton(),
                        SizedBox(height: SettingPageStyles.gapMd),
                        _MqttTestButton(),
                        SizedBox(height: SettingPageStyles.gapMd),
                        _SecurityButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SettingPageStyles.gapLg),
            const Center(child: _LogoutButton()),
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 18),
            child: Row(
              children: [
                const _DrawerUserAvatar(),
                const SizedBox(width: SettingPageStyles.gapMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [_DrawerUserName()],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1.2,
            color: AppTheme.secondaryColor.withValues(alpha: 0.22),
          ),
        ],
      ),
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

    return const UserHead(size: 58);
  }
}

class _DefaultDrawerAvatar extends StatelessWidget {
  const _DefaultDrawerAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.82),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_rounded,
        color: AppTheme.primaryColor,
        size: 34,
      ),
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
        style: SettingPageStyles.heroTitleStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final userController = Get.find<UserController>();

    return Obx(() {
      final nickname = userController.userModel.value?.nickname.trim();
      final displayName = nickname == null || nickname.isEmpty
          ? 'widgets.sections.drawer.button.group.s001'.tr
          : nickname;

      return Text(
        displayName,
        style: SettingPageStyles.heroTitleStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    });
  }
}

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
    return _DrawerActionTile(
      icon: Icons.school_rounded,
      title: 'widgets.sections.drawer.button.group.s003'.tr,
      onTap: () => _onPress(context),
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
    return _DrawerActionTile(
      icon: Icons.map_rounded,
      title: 'widgets.sections.drawer.button.group.s004'.tr,
      onTap: () => _onPress(context),
    );
  }
}

class _IssueReportButton extends StatelessWidget {
  const _IssueReportButton();

  @override
  Widget build(BuildContext context) {
    return _DrawerActionTile(
      icon: Icons.report_problem_rounded,
      title: 'widgets.sections.drawer.button.group.s005'.tr,
      onTap: () => _showFeatureNotImplementedMessage(context),
    );
  }
}

class _MqttTestButton extends StatelessWidget {
  const _MqttTestButton();

  void _onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MqttTestPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DrawerActionTile(
      icon: Icons.sensors_rounded,
      title: 'widgets.sections.drawer.button.group.s011'.tr,
      onTap: () => _onPress(context),
    );
  }
}

class _DrawerActionTile extends StatelessWidget {
  const _DrawerActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: SettingPageStyles.toggleShellBorderRadius,
        onTap: onTap,
        child: Ink(
          decoration: SettingPageStyles.toggleShellDecoration(true),
          child: Padding(
            padding: SettingPageStyles.toggleShellPadding,
            child: Row(
              children: [
                Container(
                  width: SettingPageStyles.settingIconSize,
                  height: SettingPageStyles.settingIconSize,
                  decoration: SettingPageStyles.settingIconDecoration,
                  child: Icon(
                    icon,
                    color: SettingPageStyles.surfaceIconColor,
                    size: SettingPageStyles.settingIconGlyphSize,
                  ),
                ),
                const SizedBox(width: SettingPageStyles.gapMd),
                Expanded(
                  child: Text(
                    title,
                    style: SettingPageStyles.toggleTitleStyle(true),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: SettingPageStyles.gapSm),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textColor.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityButton extends StatelessWidget {
  const _SecurityButton();

  void _onPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CampusSafetyPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DrawerActionTile(
      icon: Icons.health_and_safety_rounded,
      title: 'widgets.sections.drawer.button.group.s010'.tr,
      onTap: () => _onPress(context),
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
    return SizedBox(
      width: 176,
      height: 52,
      child: OutlinedButton(
        onPressed: _isLoggingOut ? null : _logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE85D75),
          backgroundColor: AppTheme.cardColor.withValues(alpha: 0.88),
          side: BorderSide(
            color: const Color(0xFFE85D75).withValues(alpha: 0.5),
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTheme.buttonTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        child: _isLoggingOut
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, size: 22),
                  const SizedBox(width: SettingPageStyles.gapXs),
                  Text('widgets.sections.drawer.button.group.s009'.tr),
                ],
              ),
      ),
    );
  }
}
