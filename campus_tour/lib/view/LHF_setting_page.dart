import 'package:campus_tour/local_information/local_setting.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SteeingPageStrings {
  // State
  static const loadErrorTitle = '設定載入失敗';
  static const loadErrorMessage = '本機設定暫時無法讀取，請稍後再試。';
  static const loadingTitle = '設定載入中';
  static const loadingMessage = '正在同步本機設定，請稍候。';

  // Header
  static const backTooltip = '返回';
  static const pageTitle = '設定中心';
  static const pageSubtitle = '';

  // Hero
  static const heroTitle = '冒險體驗偏好';
  static const heroDescription = '這些設定會直接影響你在遊戲中的聲音與震動體驗，適合依照目前環境快速調整。';
  static const heroLocalStorageBadge = '本機儲存';
  static const heroInstantApplyBadge = '立即套用';

  // Volume
  static const volumeTitle = '音量';
  static const volumeDescription = '調整遊戲內音效與背景音樂的預設音量。';
  static const volumeMuteLabel = '靜音';
  static const volumeMaxLabel = '最大';

  // Vibration
  static const vibrationTitle = '振動';
  static const vibrationDescription = '控制支援裝置上的觸覺回饋提示。';
  static const vibrationEnabledStatus = '已開啟';
  static const vibrationDisabledStatus = '已關閉';
  static const vibrationEnabledTitle = '觸覺提示開啟中';
  static const vibrationDisabledTitle = '觸覺提示已關閉';
  static const vibrationEnabledMessage = '在支援振動的情境中，遊戲可以提供更明顯的回饋。';
  static const vibrationDisabledMessage = '目前不會發出震動提示，適合需要安靜的使用情境。';

  static String volumePercentage(int volume) => '$volume%';

  static String currentVolume(int volume) => '目前音量 ${volumePercentage(volume)}';

  static String vibrationStatus(bool enabled) =>
      enabled ? vibrationEnabledStatus : vibrationDisabledStatus;

  static String vibrationPanelTitle(bool enabled) =>
      enabled ? vibrationEnabledTitle : vibrationDisabledTitle;

  static String vibrationPanelMessage(bool enabled) =>
      enabled ? vibrationEnabledMessage : vibrationDisabledMessage;
}

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: SettingPageStyles.pageBackgroundDecoration,
        child: SafeArea(
          child: FutureBuilder<void>(
            future: LocalSettingService.initBox(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _StatePanel(
                  icon: Icons.error_outline_rounded,
                  title: SteeingPageStrings.loadErrorTitle,
                  message: SteeingPageStrings.loadErrorMessage,
                );
              }

              if (snapshot.connectionState != ConnectionState.done) {
                return const _LoadingPanel();
              }

              return ValueListenableBuilder(
                valueListenable: LocalSettingService.settingsBox.listenable(),
                builder: (context, box, child) {
                  final int volume = LocalSettingService.volume.current;
                  final bool vibrationEnabled =
                      LocalSettingService.vibration.isEnabled;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: SettingPageStyles.pageContentConstraints,
                      child: ListView(
                        padding: SettingPageStyles.pagePadding,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const _PageHeader(),
                          const SizedBox(
                            height: SettingPageStyles.sectionSpacing,
                          ),
                          // const _HeroPanel(),
                          const SizedBox(height: SettingPageStyles.cardSpacing),
                          // 音量設定卡
                          _SettingCard(
                            icon: Icons.volume_up_rounded,
                            title: SteeingPageStrings.volumeTitle,
                            description: SteeingPageStrings.volumeDescription,
                            status: _StatusChip(
                              label: SteeingPageStrings.volumePercentage(
                                volume,
                              ),
                              enabled: volume > 0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SliderTheme(
                                  data: SettingPageStyles.sliderTheme(context),
                                  child: Slider(
                                    value: volume.toDouble(),
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    label: SteeingPageStrings.volumePercentage(
                                      volume,
                                    ),
                                    onChanged: (value) async {
                                      await LocalSettingService.volume.update(
                                        value.round(),
                                      );
                                    },
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      SteeingPageStrings.volumeMuteLabel,
                                      style: SettingPageStyles.scaleHintStyle,
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          SteeingPageStrings.currentVolume(
                                            volume,
                                          ),
                                          style:
                                              SettingPageStyles.toggleTitleStyle(
                                                volume > 0,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      SteeingPageStrings.volumeMaxLabel,
                                      style: SettingPageStyles.scaleHintStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: SettingPageStyles.cardSpacing),
                          // 振動設定卡
                          _SettingCard(
                            icon: Icons.vibration_rounded,
                            title: SteeingPageStrings.vibrationTitle,
                            description:
                                SteeingPageStrings.vibrationDescription,
                            status: _StatusChip(
                              label: SteeingPageStrings.vibrationStatus(
                                vibrationEnabled,
                              ),
                              enabled: vibrationEnabled,
                            ),
                            child: AnimatedContainer(
                              duration: SettingPageStyles.animationDuration,
                              padding: SettingPageStyles.toggleShellPadding,
                              decoration:
                                  SettingPageStyles.toggleShellDecoration(
                                    vibrationEnabled,
                                  ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          SteeingPageStrings.vibrationPanelTitle(
                                            vibrationEnabled,
                                          ),
                                          style:
                                              SettingPageStyles.toggleTitleStyle(
                                                vibrationEnabled,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: SettingPageStyles.gap2xs,
                                        ),
                                        Text(
                                          SteeingPageStrings.vibrationPanelMessage(
                                            vibrationEnabled,
                                          ),
                                          style:
                                              SettingPageStyles.bodyTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: SettingPageStyles.gapMd,
                                  ),
                                  Switch(
                                    value: vibrationEnabled,
                                    activeThumbColor: SettingPageStyles
                                        .switchActiveThumbColor,
                                    activeTrackColor: SettingPageStyles
                                        .switchActiveTrackColor,
                                    inactiveThumbColor: SettingPageStyles
                                        .switchInactiveThumbColor,
                                    inactiveTrackColor: SettingPageStyles
                                        .switchInactiveTrackColor,
                                    onChanged: (value) async {
                                      await LocalSettingService.vibration
                                          .update(value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: SettingPageStyles.navigationButtonDecoration,
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: SettingPageStyles.mutedIconColor,
            tooltip: SteeingPageStrings.backTooltip,
          ),
        ),
        const SizedBox(width: SettingPageStyles.gapMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SteeingPageStrings.pageTitle,
                style: SettingPageStyles.pageTitleStyle,
              ),
              const SizedBox(height: SettingPageStyles.gap2xs),
              Text(
                SteeingPageStrings.pageSubtitle,
                style: SettingPageStyles.pageSubtitleStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// class _HeroPanel extends StatelessWidget {
//   const _HeroPanel();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: SettingPageStyles.heroCardDecoration,
//       padding: SettingPageStyles.heroPadding,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final bool isCompact =
//               constraints.maxWidth < SettingPageStyles.heroCompactBreakpoint;
//           final Widget content = Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 SteeingPageStrings.heroTitle,
//                 style: SettingPageStyles.heroTitleStyle,
//               ),
//               const SizedBox(height: SettingPageStyles.gapXs),
//               Text(
//                 SteeingPageStrings.heroDescription,
//                 style: SettingPageStyles.bodyTextStyle,
//               ),
//               const SizedBox(height: SettingPageStyles.gapLg),
//               const Wrap(
//                 spacing: SettingPageStyles.gapSm,
//                 runSpacing: SettingPageStyles.gapSm,
//                 children: [
//                   _InfoBadge(
//                     icon: Icons.save_outlined,
//                     label: SteeingPageStrings.heroLocalStorageBadge,
//                     highlighted: true,
//                   ),
//                   _InfoBadge(
//                     icon: Icons.flash_on_rounded,
//                     label: SteeingPageStrings.heroInstantApplyBadge,
//                     highlighted: false,
//                   ),
//                 ],
//               ),
//             ],
//           );

//           final Widget iconPanel = Container(
//             width: SettingPageStyles.heroIconSize,
//             height: SettingPageStyles.heroIconSize,
//             decoration: SettingPageStyles.heroIconDecoration,
//             child: const Icon(
//               Icons.settings_suggest_rounded,
//               color: SettingPageStyles.surfaceIconColor,
//               size: SettingPageStyles.heroIconGlyphSize,
//             ),
//           );

//           if (isCompact) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 content,
//                 const SizedBox(height: SettingPageStyles.gapXl),
//                 Align(alignment: Alignment.centerRight, child: iconPanel),
//               ],
//             );
//           }

//           return Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(child: content),
//               const SizedBox(width: SettingPageStyles.gapXl),
//               iconPanel,
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SettingPageStyles.settingCardDecoration,
      padding: SettingPageStyles.cardPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact =
              constraints.maxWidth <
              SettingPageStyles.settingCardCompactBreakpoint;
          final Widget titleBlock = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SettingPageStyles.cardTitleStyle),
                const SizedBox(height: SettingPageStyles.gap2xs),
                Text(description, style: SettingPageStyles.bodyTextStyle),
              ],
            ),
          );

          final Widget iconBlock = Container(
            width: SettingPageStyles.settingIconSize,
            height: SettingPageStyles.settingIconSize,
            decoration: SettingPageStyles.settingIconDecoration,
            child: Icon(
              icon,
              color: SettingPageStyles.surfaceIconColor,
              size: SettingPageStyles.settingIconGlyphSize,
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        iconBlock,
                        const SizedBox(width: SettingPageStyles.gapMd),
                        titleBlock,
                      ],
                    ),
                    const SizedBox(height: SettingPageStyles.gapMd),
                    status,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBlock,
                    const SizedBox(width: SettingPageStyles.gapLg),
                    titleBlock,
                    const SizedBox(width: SettingPageStyles.gapLg),
                    status,
                  ],
                ),
              const SizedBox(height: SettingPageStyles.gap2xl),
              child,
            ],
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SettingPageStyles.statusChipPadding,
      decoration: SettingPageStyles.infoBadgeDecoration(highlighted: enabled),
      child: Text(label, style: SettingPageStyles.statusChipStyle(enabled)),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SettingPageStyles.infoBadgePadding,
      decoration: SettingPageStyles.infoBadgeDecoration(
        highlighted: highlighted,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: SettingPageStyles.badgeIconSize,
            color: SettingPageStyles.mutedIconColor,
          ),
          const SizedBox(width: SettingPageStyles.gapXs),
          Text(label, style: SettingPageStyles.badgeTextStyle),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const _StatePanel(
      icon: Icons.tune_rounded,
      title: SteeingPageStrings.loadingTitle,
      message: SteeingPageStrings.loadingMessage,
      showLoading: true,
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.showLoading = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: SettingPageStyles.pagePadding,
        child: ConstrainedBox(
          constraints: SettingPageStyles.statePanelConstraints,
          child: Container(
            decoration: SettingPageStyles.heroCardDecoration,
            padding: SettingPageStyles.heroPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: SettingPageStyles.heroIconSize,
                  height: SettingPageStyles.heroIconSize,
                  decoration: SettingPageStyles.heroIconDecoration,
                  child: Icon(
                    icon,
                    color: SettingPageStyles.surfaceIconColor,
                    size: SettingPageStyles.stateIconGlyphSize,
                  ),
                ),
                const SizedBox(height: SettingPageStyles.gapXl),
                Text(title, style: SettingPageStyles.heroTitleStyle),
                const SizedBox(height: SettingPageStyles.gapXs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: SettingPageStyles.bodyTextStyle,
                ),
                if (showLoading) ...[
                  const SizedBox(height: SettingPageStyles.gapXl),
                  const CircularProgressIndicator(
                    color: SettingPageStyles.loadingIndicatorColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
