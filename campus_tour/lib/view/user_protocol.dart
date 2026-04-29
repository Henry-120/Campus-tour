import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:flutter/material.dart';

class UserProtocolPage extends StatelessWidget {
  const UserProtocolPage({super.key});

  static const String _pageTitle = '使用者協議';
  static const String _pageSubtitle = '暫時替代頁面';
  static const String _headline = '協議內容準備中';
  static const String _body =
      '這裡之後會放正式的使用者協議、服務條款與相關說明。'
      '\n\n目前這是一個暫時性的替代頁面，用來先完成設定頁的跳轉流程與互動測試。'
      '\n\n之後只要把這裡的內容替換成正式協議即可，不需要再修改設定頁按鈕的跳轉邏輯。';
  static const String _tipTitle = '目前可先確認';
  static const List<String> _tips = <String>[
    '按鈕按下時會先縮小，放開後回彈再跳轉。',
    '返回設定頁後，不需要額外處理狀態。',
    '之後可直接在這個檔案補上正式協議內容。',
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
                physics: const BouncingScrollPhysics(),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: SettingPageStyles.navigationButtonDecoration,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: SettingPageStyles.mutedIconColor,
                          tooltip: '返回',
                        ),
                      ),
                      const SizedBox(width: SettingPageStyles.gapMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pageTitle,
                              style: SettingPageStyles.pageTitleStyle,
                            ),
                            const SizedBox(height: SettingPageStyles.gap2xs),
                            Text(
                              _pageSubtitle,
                              style: SettingPageStyles.pageSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SettingPageStyles.sectionSpacing),
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
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.gavel_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: SettingPageStyles.gapLg),
                        Text(
                          _headline,
                          style: SettingPageStyles.cardTitleStyle,
                        ),
                        const SizedBox(height: SettingPageStyles.gapSm),
                        Text(
                          _body,
                          style: SettingPageStyles.bodyTextStyle,
                        ),
                        const SizedBox(height: SettingPageStyles.gap2xl),
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
                              const SizedBox(height: SettingPageStyles.gapSm),
                              for (final String tip in _tips) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 3),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        size: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: SettingPageStyles.gapXs,
                                    ),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: SettingPageStyles.bodyTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: SettingPageStyles.gapSm),
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
