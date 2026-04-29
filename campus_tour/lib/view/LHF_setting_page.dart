import 'package:campus_tour/local_information/local_setting.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:campus_tour/view/user_protocol.dart';
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

  // Auto skip story
  static const autoSkipStoryTitle = '跳過劇情';
  static const autoSkipStoryDescription = '控制是否自動略過劇情對話，快速進入遊戲流程。';
  static const autoSkipStoryEnabledStatus = '已開啟';
  static const autoSkipStoryDisabledStatus = '已關閉';
  static const autoSkipStoryEnabledTitle = '自動跳過劇情中';
  static const autoSkipStoryDisabledTitle = '保留劇情播放';
  static const autoSkipStoryEnabledMessage = '進入關卡時會略過劇情段落，適合重複挑戰時使用。';
  static const autoSkipStoryDisabledMessage = '劇情段落會正常顯示，適合第一次體驗故事內容。';

  // Language
  static const languageTitle = '語言';
  static const languageDescription = '選擇遊戲介面的顯示語言。';
  static const languageChineseLabel = '中文';
  static const languageEnglishLabel = 'English';
  static const languageDropdownLabel = '目前語言';

  // Protocol
  static const userProtocolTitle = '使用者協議';
  static const userProtocolDescription = '查看目前版本的使用者協議與說明內容。';
  static const userProtocolButtonHint = '點擊前往閱讀協議內容';

  static String volumePercentage(int volume) => '$volume%';

  static String currentVolume(int volume) => '目前音量 ${volumePercentage(volume)}';

  static String vibrationStatus(bool enabled) =>
      enabled ? vibrationEnabledStatus : vibrationDisabledStatus;

  static String vibrationPanelTitle(bool enabled) =>
      enabled ? vibrationEnabledTitle : vibrationDisabledTitle;

  static String vibrationPanelMessage(bool enabled) =>
      enabled ? vibrationEnabledMessage : vibrationDisabledMessage;

  static String autoSkipStoryStatus(bool enabled) =>
      enabled ? autoSkipStoryEnabledStatus : autoSkipStoryDisabledStatus;

  static String autoSkipStoryPanelTitle(bool enabled) =>
      enabled ? autoSkipStoryEnabledTitle : autoSkipStoryDisabledTitle;

  static String autoSkipStoryPanelMessage(bool enabled) =>
      enabled ? autoSkipStoryEnabledMessage : autoSkipStoryDisabledMessage;

  static String languageLabel(String language) {
    return language == LanguageSetting.english
        ? languageEnglishLabel
        : languageChineseLabel;
  }
}

class FullPageList {
  static const List<Widget> stttingList = [
    FullPageList.pageHeader,
    FullPageList.sectionGap,
    FullPageList.firstCardGap,
    FullPageList.volumeSetCard,
    FullPageList.cardGap,
    FullPageList.vibrationSetCard,
    FullPageList.cardGap,
    FullPageList.autoSkipStorySetCard,
    FullPageList.cardGap,
    FullPageList.languageSetCard,
    FullPageList.cardGap,
    FullPageList.userProtocolButton,
  ];

  static const Widget pageHeader = _PageHeader();
  static const Widget sectionGap = SizedBox(
    height: SettingPageStyles.sectionSpacing,
  );
  // static const Widget heroPanel = _HeroPanel();
  static const Widget firstCardGap = SizedBox(
    height: SettingPageStyles.cardSpacing,
  );
  static const Widget volumeSetCard = _VolumeSettingCard();
  static const Widget cardGap = SizedBox(height: SettingPageStyles.cardSpacing);
  static const Widget vibrationSetCard = _VibrationSettingCard();
  static const Widget autoSkipStorySetCard = _AutoSkipStorySettingCard();
  static const Widget languageSetCard = _LanguageSettingCard();
  static const Widget userProtocolButton = _UserProtocolButton();
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

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: SettingPageStyles.pageContentConstraints,
                  child: ListView(
                    padding: SettingPageStyles.pagePadding,
                    physics: const BouncingScrollPhysics(),
                    children: FullPageList.stttingList,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VolumeSettingCard extends StatelessWidget {
  const _VolumeSettingCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocalSettingService.settingsBox.listenable(),
      builder: (context, _, child) {
        final int volume = LocalSettingService.volume.current;

        return _SettingCard(
          icon: Icons.volume_up_rounded,
          title: SteeingPageStrings.volumeTitle,
          description: SteeingPageStrings.volumeDescription,
          status: _StatusChip(
            label: SteeingPageStrings.volumePercentage(volume),
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
                  label: SteeingPageStrings.volumePercentage(volume),
                  onChanged: (value) async {
                    await LocalSettingService.volume.update(value.round());
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
                        SteeingPageStrings.currentVolume(volume),
                        style: SettingPageStyles.toggleTitleStyle(volume > 0),
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
        );
      },
    );
  }
}

class _VibrationSettingCard extends StatelessWidget {
  const _VibrationSettingCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocalSettingService.settingsBox.listenable(),
      builder: (context, _, child) {
        final bool vibrationEnabled = LocalSettingService.vibration.isEnabled;

        return _SettingCard(
          icon: Icons.vibration_rounded,
          title: SteeingPageStrings.vibrationTitle,
          description: SteeingPageStrings.vibrationDescription,
          status: _StatusChip(
            label: SteeingPageStrings.vibrationStatus(vibrationEnabled),
            enabled: vibrationEnabled,
          ),
          child: AnimatedContainer(
            duration: SettingPageStyles.animationDuration,
            padding: SettingPageStyles.toggleShellPadding,
            decoration: SettingPageStyles.toggleShellDecoration(
              vibrationEnabled,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SteeingPageStrings.vibrationPanelTitle(
                          vibrationEnabled,
                        ),
                        style: SettingPageStyles.toggleTitleStyle(
                          vibrationEnabled,
                        ),
                      ),
                      const SizedBox(height: SettingPageStyles.gap2xs),
                      Text(
                        SteeingPageStrings.vibrationPanelMessage(
                          vibrationEnabled,
                        ),
                        style: SettingPageStyles.bodyTextStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SettingPageStyles.gapMd),
                Switch(
                  value: vibrationEnabled,
                  activeThumbColor: SettingPageStyles.switchActiveThumbColor,
                  activeTrackColor: SettingPageStyles.switchActiveTrackColor,
                  inactiveThumbColor:
                      SettingPageStyles.switchInactiveThumbColor,
                  inactiveTrackColor:
                      SettingPageStyles.switchInactiveTrackColor,
                  onChanged: (value) async {
                    await LocalSettingService.vibration.update(value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AutoSkipStorySettingCard extends StatelessWidget {
  const _AutoSkipStorySettingCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocalSettingService.settingsBox.listenable(),
      builder: (context, _, child) {
        final bool autoSkipStoryEnabled =
            LocalSettingService.autoSkipStory.isEnabled;

        return _SettingCard(
          icon: Icons.fast_forward_rounded,
          title: SteeingPageStrings.autoSkipStoryTitle,
          description: SteeingPageStrings.autoSkipStoryDescription,
          status: _StatusChip(
            label: SteeingPageStrings.autoSkipStoryStatus(autoSkipStoryEnabled),
            enabled: autoSkipStoryEnabled,
          ),
          child: AnimatedContainer(
            duration: SettingPageStyles.animationDuration,
            padding: SettingPageStyles.toggleShellPadding,
            decoration: SettingPageStyles.toggleShellDecoration(
              autoSkipStoryEnabled,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SteeingPageStrings.autoSkipStoryPanelTitle(
                          autoSkipStoryEnabled,
                        ),
                        style: SettingPageStyles.toggleTitleStyle(
                          autoSkipStoryEnabled,
                        ),
                      ),
                      const SizedBox(height: SettingPageStyles.gap2xs),
                      Text(
                        SteeingPageStrings.autoSkipStoryPanelMessage(
                          autoSkipStoryEnabled,
                        ),
                        style: SettingPageStyles.bodyTextStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SettingPageStyles.gapMd),
                Switch(
                  value: autoSkipStoryEnabled,
                  activeThumbColor: SettingPageStyles.switchActiveThumbColor,
                  activeTrackColor: SettingPageStyles.switchActiveTrackColor,
                  inactiveThumbColor:
                      SettingPageStyles.switchInactiveThumbColor,
                  inactiveTrackColor:
                      SettingPageStyles.switchInactiveTrackColor,
                  onChanged: (value) async {
                    await LocalSettingService.autoSkipStory.update(value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageSettingCard extends StatelessWidget {
  const _LanguageSettingCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocalSettingService.settingsBox.listenable(),
      builder: (context, _, child) {
        return _SettingCard(
          icon: Icons.language_rounded,
          title: SteeingPageStrings.languageTitle,
          description: SteeingPageStrings.languageDescription,
          status: _StatusChip(
            label: SteeingPageStrings.languageChineseLabel,
            enabled: true,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: LanguageSetting.chinese,
            decoration: InputDecoration(
              labelText: SteeingPageStrings.languageDropdownLabel,
              labelStyle: SettingPageStyles.bodyTextStyle,
              filled: true,
              fillColor: AppTheme.accentColor.withValues(alpha: 0.88),
              enabledBorder: OutlineInputBorder(
                borderRadius: SettingPageStyles.toggleShellBorderRadius,
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.24),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: SettingPageStyles.toggleShellBorderRadius,
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.2,
                ),
              ),
              contentPadding: SettingPageStyles.toggleShellPadding,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: SettingPageStyles.mutedIconColor,
            ),
            dropdownColor: AppTheme.cardColor,
            style: SettingPageStyles.toggleTitleStyle(true),
            items: const [
              DropdownMenuItem<String>(
                value: LanguageSetting.chinese,
                child: Text(SteeingPageStrings.languageChineseLabel),
              ),
            ],
            onChanged: null,
          ),
        );
      },
    );
  }
}

class _UserProtocolButton extends StatefulWidget {
  const _UserProtocolButton();

  @override
  State<_UserProtocolButton> createState() => _UserProtocolButtonState();
}

class _UserProtocolButtonState extends State<_UserProtocolButton> {
  static const Duration _pressAnimationDuration = Duration(milliseconds: 120);
  static const double _pressedScale = 0.96;

  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  Future<void> _handleTapUp() async {
    _setPressed(false);
    await Future<void>.delayed(_pressAnimationDuration);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const UserProtocolPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? _pressedScale : 1,
        duration: _pressAnimationDuration,
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                SettingPageStyles.switchActiveTrackColor,
                SettingPageStyles.switchInactiveTrackColor,
              ],
            ),
            borderRadius: SettingPageStyles.panelBorderRadius,
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: SettingPageStyles.settingIconSize,
                height: SettingPageStyles.settingIconSize,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: SettingPageStyles.settingIconBorderRadius,
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: SettingPageStyles.surfaceIconColor,
                  size: SettingPageStyles.settingIconGlyphSize,
                ),
              ),
              const SizedBox(width: SettingPageStyles.gapLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SteeingPageStrings.userProtocolTitle,
                      style: AppTheme.cardTitleStyle.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: SettingPageStyles.gap2xs),
                    Text(
                      SteeingPageStrings.userProtocolDescription,
                      style: AppTheme.detailBodyStyle.copyWith(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SettingPageStyles.gapMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.92),
                    size: 30,
                  ),
                  // const SizedBox(height: SettingPageStyles.gap2xs),
                  // Text(
                  //   SteeingPageStrings.userProtocolButtonHint,
                  //   style: AppTheme.cardTitleStyle.copyWith(
                  //     fontSize: 12,
                  //     color: Colors.white.withValues(alpha: 0.88),
                  //   ),
                  //   textAlign: TextAlign.end,
                  // ),
                ],
              ),
            ],
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
          //
          final bool isCompact =
              constraints.maxWidth <
              SettingPageStyles.settingCardCompactBreakpoint;
          //
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
          //
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
                    // status,
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
              child, //內容插槽
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
