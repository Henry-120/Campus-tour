import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/widgets/login/legal_document_links.dart';

import 'package:get/get.dart';

class UserProtocolPage extends StatelessWidget {
  const UserProtocolPage({super.key});

  static String get _pageTitle => 'view.lhf.setting.page.s048'.tr;
  static String get _pageSubtitle => 'view.user.protocol.s002'.tr;
  static String get _headline => 'view.user.protocol.s003'.tr;
  static String get _body => 'view.user.protocol.s004'.tr;

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
                        SizedBox(height: SettingPageStyles.gapLg),
                        const LegalDocumentLinks(darkText: true),
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
