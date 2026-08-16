import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProtocolPage extends StatelessWidget {
  const UserProtocolPage({super.key});

  static String get _pageTitle => 'view.lhf.setting.page.s048'.tr;
  static String get _pageSubtitle => 'view.user.protocol.s002'.tr;
  static String get _headline => 'view.user.protocol.s003'.tr;
  static String get _body => 'view.user.protocol.s004'.tr;
  static String get _termsTitle => 'view.user.protocol.s005'.tr;
  static String get _termsDescription => 'view.user.protocol.s006'.tr;
  static String get _privacyTitle => 'view.user.protocol.s007'.tr;
  static String get _privacyDescription => 'view.user.protocol.s008'.tr;
  static String get _contact => 'view.user.protocol.s009'.tr;
  static String get _lastUpdated => 'view.user.protocol.s010'.tr;

  static final Uri _termsUri = Uri.parse(
    'https://campus-tour-679e9.web.app/terms.html',
  );
  static final Uri _privacyUri = Uri.parse(
    'https://campus-tour-679e9.web.app/privacy.html',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: SettingPageStyles.pageBackgroundDecoration,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: SettingPageStyles.pageContentConstraints,
              child: ListView(
                padding: SettingPageStyles.pagePadding,
                physics: BouncingScrollPhysics(),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration:
                            SettingPageStyles.navigationButtonDecoration,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Icon(Icons.arrow_back_rounded),
                          color: SettingPageStyles.mutedIconColor,
                          tooltip: 'view.camera.view.s010'.tr,
                        ),
                      ),
                      SizedBox(width: SettingPageStyles.gapMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pageTitle,
                              style: SettingPageStyles.pageTitleStyle,
                            ),
                            SizedBox(height: SettingPageStyles.gap2xs),
                            Text(
                              _pageSubtitle,
                              style: SettingPageStyles.pageSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SettingPageStyles.sectionSpacing),
                  _LegalHeroCard(headline: _headline, body: _body),
                  SizedBox(height: SettingPageStyles.gapLg),
                  _LegalSummaryCard(
                    icon: Icons.gavel_rounded,
                    title: _termsTitle,
                    description: _termsDescription,
                    uri: _termsUri,
                  ),
                  SizedBox(height: SettingPageStyles.gapMd),
                  _LegalSummaryCard(
                    icon: Icons.privacy_tip_rounded,
                    title: _privacyTitle,
                    description: _privacyDescription,
                    uri: _privacyUri,
                  ),
                  SizedBox(height: SettingPageStyles.gapLg),
                  Container(
                    decoration: SettingPageStyles.settingCardDecoration,
                    padding: SettingPageStyles.cardPadding,
                    child: Column(
                      children: [
                        Text(
                          _contact,
                          textAlign: TextAlign.center,
                          style: SettingPageStyles.bodyTextStyle,
                        ),
                        SizedBox(height: SettingPageStyles.gapSm),
                        Text(
                          _lastUpdated,
                          textAlign: TextAlign.center,
                          style: SettingPageStyles.bodyTextStyle.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalHeroCard extends StatelessWidget {
  const _LegalHeroCard({required this.headline, required this.body});

  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SettingPageStyles.settingCardDecoration,
      padding: SettingPageStyles.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.policy_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          SizedBox(height: SettingPageStyles.gapLg),
          Text(headline, style: SettingPageStyles.cardTitleStyle),
          SizedBox(height: SettingPageStyles.gapSm),
          Text(body, style: SettingPageStyles.bodyTextStyle),
        ],
      ),
    );
  }
}

class _LegalSummaryCard extends StatelessWidget {
  const _LegalSummaryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.uri,
  });

  final IconData icon;
  final String title;
  final String description;
  final Uri uri;

  Future<void> _openDocument(BuildContext context) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('widgets.login.legal.document.links.s001'.tr)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SettingPageStyles.settingCardDecoration,
      padding: SettingPageStyles.cardPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          SizedBox(width: SettingPageStyles.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _openDocument(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    iconAlignment: IconAlignment.end,
                    label: Text(
                      title,
                      style: SettingPageStyles.cardTitleStyle.copyWith(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: SettingPageStyles.gapSm),
                Text(description, style: SettingPageStyles.bodyTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
