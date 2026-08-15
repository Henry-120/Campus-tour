import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/controllers/location_controller.dart';
import 'package:campus_tour/controllers/login_controller.dart';
import 'package:campus_tour/local_information/local_setting.dart';
import 'package:campus_tour/services/load_db_service.dart';
import 'package:campus_tour/services/firebase_auth_service.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:campus_tour/view/user_protocol.dart';
import 'package:campus_tour/view/start_page.dart';
import 'package:campus_tour/widgets/common/snackbar_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:campus_tour/services/audio_service.dart';

class SteeingPageStrings {
  // State
  static String get loadErrorTitle => 'view.lhf.setting.page.s001'.tr;
  static String get loadErrorMessage => 'view.lhf.setting.page.s002'.tr;
  static String get loadingTitle => 'view.lhf.setting.page.s003'.tr;
  static String get loadingMessage => 'view.lhf.setting.page.s004'.tr;

  // Header
  static String get backTooltip => 'view.camera.view.s010'.tr;
  static String get pageTitle => 'view.lhf.setting.page.s006'.tr;
  static const pageSubtitle = '';

  // Hero
  static String get heroTitle => 'view.lhf.setting.page.s007'.tr;
  static String get heroDescription => 'view.lhf.setting.page.s008'.tr;
  static String get heroLocalStorageBadge => 'view.lhf.setting.page.s009'.tr;
  static String get heroInstantApplyBadge => 'view.lhf.setting.page.s010'.tr;

  // Volume
  static String get volumeTitle => 'view.lhf.setting.page.s011'.tr;
  static String get volumeDescription => 'view.lhf.setting.page.s012'.tr;
  static String get volumeMuteLabel => 'view.lhf.setting.page.s013'.tr;
  static String get volumeMaxLabel => 'view.lhf.setting.page.s014'.tr;

  // Vibration
  static String get vibrationTitle => 'view.lhf.setting.page.s015'.tr;
  static String get vibrationDescription => 'view.lhf.setting.page.s016'.tr;
  static String get vibrationEnabledStatus => 'view.lhf.setting.page.s017'.tr;
  static String get vibrationDisabledStatus => 'view.lhf.setting.page.s018'.tr;
  static String get vibrationEnabledTitle => 'view.lhf.setting.page.s019'.tr;
  static String get vibrationDisabledTitle => 'view.lhf.setting.page.s020'.tr;
  static String get vibrationEnabledMessage => 'view.lhf.setting.page.s021'.tr;
  static String get vibrationDisabledMessage => 'view.lhf.setting.page.s022'.tr;

  // Auto skip story
  static String get autoSkipStoryTitle => 'view.lhf.setting.page.s023'.tr;
  static String get autoSkipStoryDescription => 'view.lhf.setting.page.s024'.tr;
  static String get autoSkipStoryEnabledStatus =>
      'view.lhf.setting.page.s017'.tr;
  static String get autoSkipStoryDisabledStatus =>
      'view.lhf.setting.page.s018'.tr;
  static String get autoSkipStoryEnabledTitle =>
      'view.lhf.setting.page.s027'.tr;
  static String get autoSkipStoryDisabledTitle =>
      'view.lhf.setting.page.s028'.tr;
  static String get autoSkipStoryEnabledMessage =>
      'view.lhf.setting.page.s029'.tr;
  static String get autoSkipStoryDisabledMessage =>
      'view.lhf.setting.page.s030'.tr;

  // Debug
  static String get debugCaptureAllTitle => 'view.lhf.setting.page.s031'.tr;
  static String get debugCaptureAllDescription =>
      'view.lhf.setting.page.s032'.tr;
  static const debugCaptureAllStatus = 'Debug';
  static String get debugCaptureAllButton => 'view.lhf.setting.page.s033'.tr;
  static String get debugDeleteAllButton => 'view.lhf.setting.page.s034'.tr;
  static String get debugCaptureAllNoUser => 'view.lhf.setting.page.s035'.tr;
  static String get debugCaptureAllRunning => 'view.lhf.setting.page.s036'.tr;
  static String get debugDeleteAllRunning => 'view.lhf.setting.page.s037'.tr;
  static String get debugCaptureAllFailed => 'view.lhf.setting.page.s038'.tr;
  static String get debugDeleteAllFailed => 'view.lhf.setting.page.s039'.tr;
  static String get debugImportDbButton => 'view.lhf.setting.page.s054'.tr;
  static String get debugImportDbRunning => 'view.lhf.setting.page.s055'.tr;
  static String get debugImportDbDone => 'view.lhf.setting.page.s056'.tr;
  static String get debugImportDbFailed => 'view.lhf.setting.page.s057'.tr;

  // Location offset test
  static String get locationTestTitle => 'view.lhf.setting.page.s058'.tr;
  static String get locationTestDescription =>
      'view.lhf.setting.page.s059'.trParams({
        'latitude': '${LocationTestConfig.anchorLatitude}',
        'longitude': '${LocationTestConfig.anchorLongitude}',
      });
  static String get locationTestEnabledStatus =>
      'view.lhf.setting.page.s060'.tr;
  static String get locationTestDisabledStatus =>
      'view.lhf.setting.page.s061'.tr;
  static String get locationTestStartButton => 'view.lhf.setting.page.s062'.tr;
  static String get locationTestStopButton => 'view.lhf.setting.page.s063'.tr;
  static String get locationTestStarting => 'view.lhf.setting.page.s064'.tr;
  static String get locationTestStarted => 'view.lhf.setting.page.s065'.tr;
  static String get locationTestStopped => 'view.lhf.setting.page.s066'.tr;
  static String get locationTestFailed => 'view.lhf.setting.page.s067'.tr;

  // Account security
  static String get accountPasswordLinked => 'view.lhf.setting.page.s068'.tr;
  static String get accountNotSignedIn => 'view.lhf.setting.page.s069'.tr;
  static String get accountEmailVerified => 'view.lhf.setting.page.s070'.tr;
  static String get accountPasswordLinkedVerificationSent =>
      'view.lhf.setting.page.s071'.tr;
  static String get accountVerificationResent =>
      'view.lhf.setting.page.s072'.tr;
  static String accountVerificationSendFailed(String error) =>
      'view.lhf.setting.page.s073'.trParams({'error': error});
  static String get accountSecurityTitle => 'view.lhf.setting.page.s074'.tr;
  static String accountEmail(String email) =>
      'view.lhf.setting.page.s075'.trParams({'email': email});
  static String get accountVerificationPending =>
      'view.lhf.setting.page.s076'.tr;
  static String get accountPasswordSet => 'view.lhf.setting.page.s077'.tr;
  static String get accountPasswordNotSet => 'view.lhf.setting.page.s078'.tr;
  static String get accountVerificationRequiredDescription =>
      'view.lhf.setting.page.s079'.tr;
  static String get accountResendVerification =>
      'view.lhf.setting.page.s080'.tr;
  static String get accountGoogleAndEmailAvailable =>
      'view.lhf.setting.page.s081'.tr;
  static String get accountEmailAvailable => 'view.lhf.setting.page.s082'.tr;
  static String get accountSetEmailPassword => 'view.lhf.setting.page.s083'.tr;
  static String get accountThisEmail => 'view.lhf.setting.page.s084'.tr;
  static String accountPasswordDialogDescription(String email) =>
      'view.lhf.setting.page.s085'.trParams({'email': email});
  static String get accountNewPassword => 'view.lhf.setting.page.s086'.tr;
  static String get accountPasswordHelper => 'view.lhf.setting.page.s087'.tr;
  static String get accountEnterNewPassword => 'view.lhf.setting.page.s088'.tr;
  static String get accountPasswordTooShort => 'view.lhf.setting.page.s089'.tr;
  static String get accountConfirmNewPassword =>
      'view.lhf.setting.page.s090'.tr;
  static String get accountEnterPasswordAgain =>
      'view.lhf.setting.page.s091'.tr;
  static String get accountPasswordsDoNotMatch =>
      'view.lhf.setting.page.s092'.tr;
  static String get accountCancel => 'view.lhf.setting.page.s093'.tr;
  static String get accountConfirmSet => 'view.lhf.setting.page.s094'.tr;

  static String accountAuthError(Object error) {
    if (error is! FirebaseAuthException) {
      return 'view.lhf.setting.page.s095'.tr;
    }

    return switch (error.code) {
      'invalid-email' => 'view.lhf.setting.page.s096'.tr,
      'missing-password' => 'view.lhf.setting.page.s097'.tr,
      'weak-password' => 'view.lhf.setting.page.s098'.tr,
      'user-not-found' => 'view.lhf.setting.page.s099'.tr,
      'provider-already-linked' => 'view.lhf.setting.page.s100'.tr,
      'credential-already-in-use' => 'view.lhf.setting.page.s101'.tr,
      'requires-recent-login' => 'view.lhf.setting.page.s102'.tr,
      'too-many-requests' => 'view.lhf.setting.page.s103'.tr,
      'network-request-failed' => 'view.lhf.setting.page.s104'.tr,
      'operation-not-allowed' => 'view.lhf.setting.page.s105'.tr,
      'google-sign-in-cancelled' => 'view.lhf.setting.page.s106'.tr,
      'google-account-mismatch' => 'view.lhf.setting.page.s107'.tr,
      _ => 'view.lhf.setting.page.s108'.tr,
    };
  }

  static String debugCaptureAllDone(int count) {
    return count == 0 ? 'view.lhf.setting.page.s040'.tr : '已新增 $count 隻精靈到圖鑑';
  }

  static String debugDeleteAllDone(int count) {
    return count == 0 ? 'view.lhf.setting.page.s042'.tr : '已從圖鑑刪除 $count 隻精靈';
  }

  // Language
  static String get languageTitle => 'view.lhf.setting.page.s044'.tr;
  static String get languageDescription => 'view.lhf.setting.page.s045'.tr;
  static String get languageChineseLabel => 'view.lhf.setting.page.s046'.tr;
  static const languageEnglishLabel = 'English';
  static const languageJapaneseLabel = '日本語';
  static String get languageDropdownLabel => 'view.lhf.setting.page.s047'.tr;

  // Protocol
  static String get userProtocolTitle => 'view.lhf.setting.page.s048'.tr;
  static String get userProtocolDescription => 'view.lhf.setting.page.s049'.tr;
  static String get userProtocolButtonHint => 'view.lhf.setting.page.s050'.tr;

  // Account deletion
  static String get deleteAccountTitle => 'view.lhf.setting.page.s109'.tr;
  static String get deleteAccountDescription => 'view.lhf.setting.page.s110'.tr;
  static String get deleteAccountButton => 'view.lhf.setting.page.s111'.tr;
  static String get deleteAccountConfirmTitle =>
      'view.lhf.setting.page.s112'.tr;
  static String get deleteAccountConfirmMessage =>
      'view.lhf.setting.page.s113'.tr;
  static String get deleteAccountPassword => 'view.lhf.setting.page.s114'.tr;
  static String get deleteAccountCancel => 'view.lhf.setting.page.s115'.tr;
  static String get deleteAccountConfirm => 'view.lhf.setting.page.s116'.tr;
  static String get deleteAccountFailed => 'view.lhf.setting.page.s117'.tr;
  static String get deleteAccountWrongPassword =>
      'view.lhf.setting.page.s118'.tr;

  static String volumePercentage(int volume) => '$volume%';

  static String currentVolume(int volume) => 'view.lhf.setting.page.s051'
      .trParams({'volume': volumePercentage(volume)});

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
    return switch (language) {
      LanguageSetting.english => languageEnglishLabel,
      LanguageSetting.japanese => languageJapaneseLabel,
      _ => languageChineseLabel,
    };
  }
}

class FullPageList {
  static List<Widget> get stttingList => [
    FullPageList.pageHeader,
    FullPageList.sectionGap,
    FullPageList.firstCardGap,
    FullPageList.volumeSetCard,
    FullPageList.cardGap,
    FullPageList.vibrationSetCard,
    FullPageList.cardGap,
    FullPageList.autoSkipStorySetCard,
    if (LocationTestConfig.showControls) FullPageList.cardGap,
    if (LocationTestConfig.showControls) FullPageList.locationOffsetTestCard,
    if (MonsterCollectionTestConfig.showControls) FullPageList.cardGap,
    if (MonsterCollectionTestConfig.showControls)
      FullPageList.debugCaptureAllCard,
    FullPageList.cardGap,
    FullPageList.languageSetCard,
    FullPageList.cardGap,
    FullPageList.accountSecurityCard,
    FullPageList.cardGap,
    FullPageList.userProtocolButton,
    FullPageList.cardGap,
    FullPageList.deleteAccountCard,
  ];

  static Widget get pageHeader => _PageHeader();
  static Widget get sectionGap =>
      SizedBox(height: SettingPageStyles.sectionSpacing);
  // static Widget get heroPanel => _HeroPanel();
  static Widget get firstCardGap =>
      SizedBox(height: SettingPageStyles.cardSpacing);
  static Widget get volumeSetCard => _VolumeSettingCard();
  static Widget get cardGap => SizedBox(height: SettingPageStyles.cardSpacing);
  static Widget get vibrationSetCard => _VibrationSettingCard();
  static Widget get autoSkipStorySetCard => _AutoSkipStorySettingCard();
  static Widget get locationOffsetTestCard => _LocationOffsetTestCard();
  static Widget get debugCaptureAllCard => _DebugCaptureAllMonstersCard();
  static Widget get languageSetCard => _LanguageSettingCard();
  static Widget get accountSecurityCard => _AccountSecurityCard();
  static Widget get userProtocolButton => _UserProtocolButton();
  static Widget get deleteAccountCard => _DeleteAccountCard();
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioService().playOverlayBgm(fileName: 'audio/M02_settings.m4a');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService().pauseAllBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioService().resumeAllBgm();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AudioService().stopOverlayBgm();
    super.dispose();
  }

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
                return _StatePanel(
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
                    physics: BouncingScrollPhysics(),
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
                      SizedBox(height: SettingPageStyles.gap2xs),
                      Text(
                        SteeingPageStrings.vibrationPanelMessage(
                          vibrationEnabled,
                        ),
                        style: SettingPageStyles.bodyTextStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: SettingPageStyles.gapMd),
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
                      SizedBox(height: SettingPageStyles.gap2xs),
                      Text(
                        SteeingPageStrings.autoSkipStoryPanelMessage(
                          autoSkipStoryEnabled,
                        ),
                        style: SettingPageStyles.bodyTextStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: SettingPageStyles.gapMd),
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

class _LocationOffsetTestCard extends StatefulWidget {
  const _LocationOffsetTestCard();

  @override
  State<_LocationOffsetTestCard> createState() =>
      _LocationOffsetTestCardState();
}

class _LocationOffsetTestCardState extends State<_LocationOffsetTestCard> {
  late final LocationController _locationController;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _locationController = Get.find<LocationController>();
  }

  Future<void> _startOffset() async {
    if (_isStarting) return;

    setState(() => _isStarting = true);
    SnackBarBuilder.show(
      context,
      SteeingPageStrings.locationTestStarting,
      type: AppToastType.info,
    );

    final started = await _locationController.enableTestOffset();
    if (!mounted) return;

    setState(() => _isStarting = false);
    SnackBarBuilder.show(
      context,
      started
          ? SteeingPageStrings.locationTestStarted
          : SteeingPageStrings.locationTestFailed,
      type: started ? AppToastType.success : AppToastType.error,
    );
  }

  void _stopOffset() {
    _locationController.disableTestOffset();
    SnackBarBuilder.show(
      context,
      SteeingPageStrings.locationTestStopped,
      type: AppToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final enabled = _locationController.isTestOffsetEnabled.value;

      return _SettingCard(
        icon: Icons.my_location_rounded,
        title: SteeingPageStrings.locationTestTitle,
        description: SteeingPageStrings.locationTestDescription,
        status: _StatusChip(
          label: enabled
              ? SteeingPageStrings.locationTestEnabledStatus
              : SteeingPageStrings.locationTestDisabledStatus,
          enabled: enabled,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: enabled
              ? OutlinedButton.icon(
                  onPressed: _stopOffset,
                  icon: const Icon(Icons.location_disabled_rounded),
                  label: Text(SteeingPageStrings.locationTestStopButton),
                )
              : FilledButton.icon(
                  onPressed: _isStarting ? null : _startOffset,
                  icon: _isStarting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_location_alt_rounded),
                  label: Text(SteeingPageStrings.locationTestStartButton),
                ),
        ),
      );
    });
  }
}

class _LanguageSettingCard extends StatelessWidget {
  const _LanguageSettingCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocalSettingService.settingsBox.listenable(),
      builder: (context, _, child) {
        final currentLanguage = LocalSettingService.language.current;
        return _SettingCard(
          icon: Icons.language_rounded,
          title: SteeingPageStrings.languageTitle,
          description: SteeingPageStrings.languageDescription,
          status: _StatusChip(
            label: SteeingPageStrings.languageLabel(currentLanguage),
            enabled: true,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: currentLanguage,
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
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.2,
                ),
              ),
              contentPadding: SettingPageStyles.toggleShellPadding,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: SettingPageStyles.mutedIconColor,
            ),
            dropdownColor: AppTheme.cardColor,
            style: SettingPageStyles.toggleTitleStyle(true),
            items: [
              DropdownMenuItem<String>(
                value: LanguageSetting.chinese,
                child: Text(SteeingPageStrings.languageChineseLabel),
              ),
              DropdownMenuItem<String>(
                value: LanguageSetting.english,
                child: Text(SteeingPageStrings.languageEnglishLabel),
              ),
              DropdownMenuItem<String>(
                value: LanguageSetting.japanese,
                child: Text(SteeingPageStrings.languageJapaneseLabel),
              ),
            ],
            onChanged: (language) async {
              if (language == null || language == currentLanguage) {
                return;
              }

              await LocalSettingService.language.update(language);
              Get.updateLocale(Locale(language));
            },
          ),
        );
      },
    );
  }
}

class _DebugCaptureAllMonstersCard extends StatefulWidget {
  const _DebugCaptureAllMonstersCard();

  @override
  State<_DebugCaptureAllMonstersCard> createState() =>
      _DebugCaptureAllMonstersCardState();
}

class _DebugCaptureAllMonstersCardState
    extends State<_DebugCaptureAllMonstersCard> {
  bool _isCapturing = false;
  bool _isDeleting = false;
  bool _isImportingDb = false;

  bool get _isBusy => _isCapturing || _isDeleting || _isImportingDb;

  Future<void> _captureAllMonsters() async {
    if (_isBusy) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.debugCaptureAllNoUser,
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isCapturing = true);
    SnackBarBuilder.show(
      context,
      SteeingPageStrings.debugCaptureAllRunning,
      type: AppToastType.info,
    );

    try {
      final count = await Get.find<MonsterController>()
          .captureAllMonstersForTesting(user.uid);

      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.debugCaptureAllDone(count),
        type: AppToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('[SettingPage] 捕捉全部精靈失敗: $e');
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.debugCaptureAllFailed,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _deleteAllMonsters() async {
    if (_isBusy) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.debugCaptureAllNoUser,
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isDeleting = true);
    SnackBarBuilder.show(
      context,
      SteeingPageStrings.debugDeleteAllRunning,
      type: AppToastType.info,
    );

    try {
      final count = await Get.find<MonsterController>()
          .deleteAllUserMonstersForTesting(user.uid);

      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.debugDeleteAllDone(count),
        type: AppToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('[SettingPage] 刪除全部精靈失敗: $e');
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.debugDeleteAllFailed,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _importGameData() async {
    if (_isBusy) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.debugCaptureAllNoUser,
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isImportingDb = true);
    SnackBarBuilder.show(
      context,
      SteeingPageStrings.debugImportDbRunning,
      type: AppToastType.info,
    );

    try {
      final service = LoadDbService();
      await service.loadArchitecture();
      await service.loadQA();
      await service.loadMonsters();

      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.debugImportDbDone,
        type: AppToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('[SettingPage] 匯入遊戲資料失敗: $e');
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.debugImportDbFailed,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isImportingDb = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCard(
      icon: Icons.bug_report_rounded,
      title: SteeingPageStrings.debugCaptureAllTitle,
      description: SteeingPageStrings.debugCaptureAllDescription,
      status: const _StatusChip(
        label: SteeingPageStrings.debugCaptureAllStatus,
        enabled: true,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: SettingPageStyles.gapMd,
          runSpacing: SettingPageStyles.gapMd,
          children: [
            FilledButton.icon(
              onPressed: _isBusy ? null : _captureAllMonsters,
              icon: _isCapturing
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.catching_pokemon_rounded),
              label: Text(SteeingPageStrings.debugCaptureAllButton),
            ),
            OutlinedButton.icon(
              onPressed: _isBusy ? null : _deleteAllMonsters,
              icon: _isDeleting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.delete_sweep_rounded),
              label: Text(SteeingPageStrings.debugDeleteAllButton),
            ),
            if (kDebugMode)
              FilledButton.tonalIcon(
                onPressed: _isBusy ? null : _importGameData,
                icon: _isImportingDb
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.cloud_upload_rounded),
                label: Text(SteeingPageStrings.debugImportDbButton),
              ),
          ],
        ),
      ),
    );
  }
}

class _AccountSecurityCard extends StatefulWidget {
  const _AccountSecurityCard();

  @override
  State<_AccountSecurityCard> createState() => _AccountSecurityCardState();
}

class _AccountSecurityCardState extends State<_AccountSecurityCard> {
  final AuthService _authService = AuthService();
  bool _isSendingVerification = false;

  Future<void> _setEmailPassword() async {
    final linked = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SetEmailPasswordDialog(authService: _authService),
    );
    if (linked != true || !mounted) return;

    await FirebaseAuth.instance.currentUser?.reload();
    if (!mounted) return;
    setState(() {});

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await _sendVerificationEmail(passwordJustLinked: true);
      return;
    }

    if (!mounted) return;
    SnackBarBuilder.show(
      context,
      SteeingPageStrings.accountPasswordLinked,
      type: AppToastType.success,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> _sendVerificationEmail({bool passwordJustLinked = false}) async {
    if (_isSendingVerification) return;

    setState(() => _isSendingVerification = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: SteeingPageStrings.accountNotSignedIn,
        );
      }

      if (user.emailVerified) {
        if (!mounted) return;
        setState(() {});
        SnackBarBuilder.show(
          context,
          SteeingPageStrings.accountEmailVerified,
          type: AppToastType.success,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      await _authService.sendEmailVerification();
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        passwordJustLinked
            ? SteeingPageStrings.accountPasswordLinkedVerificationSent
            : SteeingPageStrings.accountVerificationResent,
        type: AppToastType.success,
        duration: const Duration(seconds: 5),
      );
    } catch (error) {
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        passwordJustLinked
            ? SteeingPageStrings.accountVerificationSendFailed(
                SteeingPageStrings.accountAuthError(error),
              )
            : SteeingPageStrings.accountAuthError(error),
        type: AppToastType.error,
        duration: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingVerification = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final hasPassword = _authService.hasPasswordProvider(user);
    final hasGoogle =
        user?.providerData.any(
          (provider) => provider.providerId == GoogleAuthProvider.PROVIDER_ID,
        ) ??
        false;
    final needsEmailVerification =
        hasPassword && user != null && !user.emailVerified;

    return _SettingCard(
      icon: Icons.security_rounded,
      title: SteeingPageStrings.accountSecurityTitle,
      description: user?.email == null
          ? SteeingPageStrings.accountNotSignedIn
          : SteeingPageStrings.accountEmail(user!.email!),
      status: _StatusChip(
        label: needsEmailVerification
            ? SteeingPageStrings.accountVerificationPending
            : hasPassword
            ? SteeingPageStrings.accountPasswordSet
            : SteeingPageStrings.accountPasswordNotSet,
        enabled: hasPassword && !needsEmailVerification,
      ),
      child: needsEmailVerification
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.mark_email_unread_rounded,
                      color: Colors.orange,
                    ),
                    SizedBox(width: SettingPageStyles.gapSm),
                    Expanded(
                      child: Text(
                        SteeingPageStrings
                            .accountVerificationRequiredDescription,
                        style: SettingPageStyles.bodyTextStyle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SettingPageStyles.gapMd),
                OutlinedButton.icon(
                  onPressed: _isSendingVerification
                      ? null
                      : _sendVerificationEmail,
                  icon: _isSendingVerification
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.outgoing_mail),
                  label: Text(SteeingPageStrings.accountResendVerification),
                ),
              ],
            )
          : hasPassword
          ? Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green),
                SizedBox(width: SettingPageStyles.gapSm),
                Expanded(
                  child: Text(
                    hasGoogle
                        ? SteeingPageStrings.accountGoogleAndEmailAvailable
                        : SteeingPageStrings.accountEmailAvailable,
                    style: SettingPageStyles.bodyTextStyle,
                  ),
                ),
              ],
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: user == null ? null : _setEmailPassword,
                icon: const Icon(Icons.password_rounded),
                label: Text(SteeingPageStrings.accountSetEmailPassword),
              ),
            ),
    );
  }
}

class _SetEmailPasswordDialog extends StatefulWidget {
  const _SetEmailPasswordDialog({required this.authService});

  final AuthService authService;

  @override
  State<_SetEmailPasswordDialog> createState() =>
      _SetEmailPasswordDialogState();
}

class _SetEmailPasswordDialogState extends State<_SetEmailPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await widget.authService.linkEmailPassword(_passwordController.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = SteeingPageStrings.accountAuthError(error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(SteeingPageStrings.accountSetEmailPassword),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                SteeingPageStrings.accountPasswordDialogDescription(
                  FirebaseAuth.instance.currentUser?.email ??
                      SteeingPageStrings.accountThisEmail,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: SteeingPageStrings.accountNewPassword,
                  helperText: SteeingPageStrings.accountPasswordHelper,
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return SteeingPageStrings.accountEnterNewPassword;
                  }
                  if (value.length < 6) {
                    return SteeingPageStrings.accountPasswordTooShort;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmation,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: SteeingPageStrings.accountConfirmNewPassword,
                  prefixIcon: const Icon(Icons.verified_user_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscureConfirmation = !_obscureConfirmation,
                    ),
                    icon: Icon(
                      _obscureConfirmation
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return SteeingPageStrings.accountEnterPasswordAgain;
                  }
                  if (value != _passwordController.text) {
                    return SteeingPageStrings.accountPasswordsDoNotMatch;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _isLoading ? null : _submit(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(SteeingPageStrings.accountCancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(SteeingPageStrings.accountConfirmSet),
        ),
      ],
    );
  }
}

class _UserProtocolButton extends StatefulWidget {
  const _UserProtocolButton();

  @override
  State<_UserProtocolButton> createState() => _UserProtocolButtonState();
}

class _UserProtocolButtonState extends State<_UserProtocolButton> {
  static Duration get _pressAnimationDuration => Duration(milliseconds: 120);
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
            gradient: LinearGradient(
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
                child: Icon(
                  Icons.description_rounded,
                  color: SettingPageStyles.surfaceIconColor,
                  size: SettingPageStyles.settingIconGlyphSize,
                ),
              ),
              SizedBox(width: SettingPageStyles.gapLg),
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
                    SizedBox(height: SettingPageStyles.gap2xs),
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
              SizedBox(width: SettingPageStyles.gapMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.92),
                    size: 30,
                  ),
                  // SizedBox(height: SettingPageStyles.gap2xs),
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

class _DeleteAccountCard extends StatefulWidget {
  const _DeleteAccountCard();

  @override
  State<_DeleteAccountCard> createState() => _DeleteAccountCardState();
}

class _DeleteAccountCardState extends State<_DeleteAccountCard> {
  bool _isDeleting = false;

  bool get _usesPassword {
    final user = FirebaseAuth.instance.currentUser;
    final providers = user?.providerData.map((info) => info.providerId).toSet();
    if (providers == null ||
        providers.contains(AppleAuthProvider.PROVIDER_ID) ||
        providers.contains(GoogleAuthProvider.PROVIDER_ID)) {
      return false;
    }
    return providers.contains(EmailAuthProvider.PROVIDER_ID);
  }

  Future<void> _requestDeletion() async {
    if (_isDeleting) return;

    final passwordController = TextEditingController();
    final passwordRequired = _usesPassword;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(SteeingPageStrings.deleteAccountConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SteeingPageStrings.deleteAccountConfirmMessage),
            if (passwordRequired) ...[
              const SizedBox(height: 18),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: SteeingPageStrings.deleteAccountPassword,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(SteeingPageStrings.deleteAccountCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(SteeingPageStrings.deleteAccountConfirm),
          ),
        ],
      ),
    );

    final password = passwordController.text;
    passwordController.dispose();
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await LoginController().deleteAccount(
        password: passwordRequired ? password : null,
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StartPage()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final isPasswordError =
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-login-credentials';
      SnackBarBuilder.show(
        context,
        isPasswordError
            ? SteeingPageStrings.deleteAccountWrongPassword
            : SteeingPageStrings.deleteAccountFailed,
        type: AppToastType.error,
      );
    } catch (_) {
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        SteeingPageStrings.deleteAccountFailed,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCard(
      icon: Icons.delete_forever_rounded,
      title: SteeingPageStrings.deleteAccountTitle,
      description: SteeingPageStrings.deleteAccountDescription,
      status: const SizedBox.shrink(),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade800,
            side: BorderSide(color: Colors.red.shade300),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: _isDeleting ? null : _requestDeletion,
          icon: _isDeleting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_forever_rounded),
          label: Text(SteeingPageStrings.deleteAccountButton),
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
            icon: Icon(Icons.arrow_back_rounded),
            color: SettingPageStyles.mutedIconColor,
            tooltip: SteeingPageStrings.backTooltip,
          ),
        ),
        SizedBox(width: SettingPageStyles.gapMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SteeingPageStrings.pageTitle,
                style: SettingPageStyles.pageTitleStyle,
              ),
              SizedBox(height: SettingPageStyles.gap2xs),
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
                SizedBox(height: SettingPageStyles.gap2xs),
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
                        SizedBox(width: SettingPageStyles.gapMd),
                        titleBlock,
                      ],
                    ),
                    SizedBox(height: SettingPageStyles.gapMd),
                    // status,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBlock,
                    SizedBox(width: SettingPageStyles.gapLg),
                    titleBlock,
                    SizedBox(width: SettingPageStyles.gapLg),
                    status,
                  ],
                ),
              SizedBox(height: SettingPageStyles.gap2xl),
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

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
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
                SizedBox(height: SettingPageStyles.gapXl),
                Text(title, style: SettingPageStyles.heroTitleStyle),
                SizedBox(height: SettingPageStyles.gapXs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: SettingPageStyles.bodyTextStyle,
                ),
                if (showLoading) ...[
                  SizedBox(height: SettingPageStyles.gapXl),
                  CircularProgressIndicator(
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
