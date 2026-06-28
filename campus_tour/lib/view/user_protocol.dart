import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class UserProtocolPage extends StatelessWidget {
  UserProtocolPage({super.key});

  static String get _pageTitle => 'view.lhf.setting.page.s048'.tr;
  static String get _pageSubtitle => 'view.user.protocol.s002'.tr;
  static String get _headline => 'view.user.protocol.s003'.tr;
  static String get _body =>
      '${'view.user.protocol.s004'.tr}${'view.user.protocol.s005'.tr}${'view.user.protocol.s006'.tr}';
  static String get _tipTitle => 'view.user.protocol.s007'.tr;
  static List<String> get _tips => <String>[
    'view.user.protocol.s008'.tr,
    'view.user.protocol.s009'.tr,
    'view.user.protocol.s010'.tr,
  ];

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
                  Container(
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
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            Icons.gavel_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        SizedBox(height: SettingPageStyles.gapLg),
                        Text(
                          _headline,
                          style: SettingPageStyles.cardTitleStyle,
                        ),
                        SizedBox(height: SettingPageStyles.gapSm),
                        Text(_body, style: SettingPageStyles.bodyTextStyle),
                        SizedBox(height: SettingPageStyles.gap2xl),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.72),
                            borderRadius:
                                SettingPageStyles.toggleShellBorderRadius,
                            border: Border.all(
                              color: AppTheme.secondaryColor.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tipTitle,
                                style: SettingPageStyles.toggleTitleStyle(true),
                              ),
                              SizedBox(height: SettingPageStyles.gapSm),
                              for (final String tip in _tips) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 3),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        size: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: SettingPageStyles.gapXs),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: SettingPageStyles.bodyTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: SettingPageStyles.gapSm),
                              ],
                            ],
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
