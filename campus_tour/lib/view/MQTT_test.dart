// ignore_for_file: file_names

import 'package:campus_tour/config/esp32_scheme.dart';
import 'package:campus_tour/features/station_hardware/models/station_hardware_models.dart';

import 'package:campus_tour/services/mqtt_service.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MqttTestPage extends StatefulWidget {
  const MqttTestPage({super.key});

  @override
  State<MqttTestPage> createState() => _MqttTestPageState();
}

class _MqttTestPageState extends State<MqttTestPage> {
  static const Map<MqttEventType, String> _eventLabels = {
    MqttEventType.scanSuccess: '掃描成功 (scan_success)',
    MqttEventType.arrival: '抵達站點 (arrival)',
    MqttEventType.storyUnlocked: '解鎖故事 (story_unlock)',
    MqttEventType.challengeComplete: '完成挑戰 (challenge_clear)',
  };

  // 在頁面重開時沿用同一條測試連線，避免建立多個 MQTT client。
  static final MqttService _mqttService = MqttService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _stationIdController = TextEditingController(
    text: StationId.sakura.wireName,
  );
  final List<String> _logs = [];

  MqttEventType _selectedEvent = _eventLabels.keys.first;

  String _statusMessage = '尚未開始測試';
  _MqttTestPhase _phase = _MqttTestPhase.idle;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    if (_mqttService.isConnected) {
      _phase = _MqttTestPhase.connected;
      _statusMessage = '目前已有可用的 MQTT 連線';
    }
  }

  @override
  void dispose() {
    _stationIdController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    final now = DateTime.now();
    final timestamp = [
      now.hour,
      now.minute,
      now.second,
    ].map((part) => part.toString().padLeft(2, '0')).join(':');

    _logs.insert(0, '[$timestamp] $message');
    if (_logs.length > 50) _logs.removeLast();
  }

  Future<void> _testConnection() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _phase = _MqttTestPhase.connecting;
      _statusMessage = '正在連線至 MQTT Broker…';
      _addLog('開始連線 ${Esp32MqttInfo.brokerAddress}:${Esp32MqttInfo.port}');
    });

    final connected = await _mqttService.connect();
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      _phase = connected ? _MqttTestPhase.connected : _MqttTestPhase.error;
      _statusMessage = connected ? 'MQTT Broker 連線成功' : 'MQTT Broker 連線失敗';
      _addLog(connected ? '連線測試成功' : '連線測試失敗，請確認網路與 Broker 設定');
    });
  }

  Future<void> _publishTestEvent() async {
    if (_isBusy || !(_formKey.currentState?.validate() ?? false)) return;
    const stationId = StationId.sakura;
    final topic = 'campustour/${stationId.wireName}/checkin';

    setState(() {
      _isBusy = true;
      _phase = _MqttTestPhase.publishing;
      _statusMessage = '正在送出測試事件…';
      _addLog('準備發佈 ${_selectedEvent.wireName} → $topic');
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const MqttAuthenticationException();
      }

      await _mqttService.sendStationEvent(
        stationId: stationId,
        event: _selectedEvent,
        data: MqttEventData(displayName: _displayNameFor(user)),
      );
      if (!mounted) return;

      setState(() {
        _phase = _MqttTestPhase.success;
        _statusMessage = '測試事件已送出';
        _addLog('發佈成功（QoS 1）→ $topic');
      });
    } catch (error) {
      if (!mounted) return;

      final reason = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        _phase = _MqttTestPhase.error;
        _statusMessage = '測試事件送出失敗';
        _addLog('發佈失敗：$reason');
      });
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _clearLogs() {
    setState(_logs.clear);
  }

  String _displayNameFor(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email;

    return user.uid;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT 功能測試'),
        backgroundColor: AppTheme.cardColor,
        foregroundColor: AppTheme.textColor,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: SettingPageStyles.pageBackgroundDecoration,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: SettingPageStyles.pageContentConstraints,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ConnectionStatusCard(
                      phase: _phase,
                      message: _statusMessage,
                      isConnected: _mqttService.isConnected,
                      userLabel: user == null
                          ? '尚未登入（事件發佈需要 Firebase 登入）'
                          : '已登入：${user.uid}',
                    ),
                    const SizedBox(height: SettingPageStyles.cardSpacing),
                    _buildPublishCard(user != null),
                    const SizedBox(height: SettingPageStyles.cardSpacing),
                    _buildLogCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPublishCard(bool isAuthenticated) {
    return Container(
      padding: SettingPageStyles.cardPadding,
      decoration: SettingPageStyles.settingCardDecoration,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('事件發佈測試', style: SettingPageStyles.cardTitleStyle),
            const SizedBox(height: SettingPageStyles.gap2xs),
            Text(
              '測試訊息會附帶目前使用者的 Firebase ID Token、顯示名稱，並以 QoS 1 發佈。',

              style: SettingPageStyles.bodyTextStyle,
            ),
            const SizedBox(height: SettingPageStyles.gapXl),
            TextFormField(
              controller: _stationIdController,
              enabled: !_isBusy,
              readOnly: true,
              decoration: _inputDecoration(
                label: 'Station ID',
                hint: '目前固定站點',
                icon: Icons.location_on_outlined,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: SettingPageStyles.gapLg),
            DropdownButtonFormField<MqttEventType>(
              initialValue: _selectedEvent,
              decoration: _inputDecoration(
                label: 'Event',
                icon: Icons.bolt_rounded,
              ),
              items: _eventLabels.entries
                  .map(
                    (entry) => DropdownMenuItem<MqttEventType>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: _isBusy
                  ? null
                  : (event) {
                      if (event != null) {
                        setState(() => _selectedEvent = event);
                      }
                    },
            ),
            const SizedBox(height: SettingPageStyles.gap2xl),
            Wrap(
              spacing: SettingPageStyles.gapMd,
              runSpacing: SettingPageStyles.gapMd,
              children: [
                OutlinedButton.icon(
                  onPressed: _isBusy ? null : _testConnection,
                  icon: const Icon(Icons.cable_rounded),
                  label: const Text('測試連線'),
                ),
                FilledButton.icon(
                  onPressed: _isBusy || !isAuthenticated
                      ? null
                      : _publishTestEvent,
                  icon: _phase == _MqttTestPhase.publishing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: const Text('送出測試事件'),
                ),
              ],
            ),
            if (!isAuthenticated) ...[
              const SizedBox(height: SettingPageStyles.gapMd),
              Text(
                '請先登入帳號，再測試事件發佈。連線測試仍可使用。',
                style: SettingPageStyles.bodyTextStyle.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard() {
    return Container(
      padding: SettingPageStyles.cardPadding,
      decoration: SettingPageStyles.settingCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('測試紀錄', style: SettingPageStyles.cardTitleStyle),
              ),
              IconButton(
                onPressed: _logs.isEmpty ? null : _clearLogs,
                tooltip: '清除紀錄',
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ],
          ),
          const SizedBox(height: SettingPageStyles.gapSm),
          Container(
            constraints: const BoxConstraints(minHeight: 130, maxHeight: 260),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2E211D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _logs.isEmpty ? '尚無測試紀錄' : _logs.join('\n'),
                style: const TextStyle(
                  color: Color(0xFFFFEDE2),
                  fontFamily: 'monospace',

                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    final border = OutlineInputBorder(
      borderRadius: SettingPageStyles.toggleShellBorderRadius,
      borderSide: BorderSide(
        color: AppTheme.primaryColor.withValues(alpha: 0.35),
      ),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: AppTheme.accentColor.withValues(alpha: 0.72),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.8),
      ),
    );
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  const _ConnectionStatusCard({
    required this.phase,
    required this.message,
    required this.isConnected,
    required this.userLabel,
  });

  final _MqttTestPhase phase;
  final String message;
  final bool isConnected;
  final String userLabel;

  Color get _statusColor => switch (phase) {
    _MqttTestPhase.idle => AppTheme.linkColor,
    _MqttTestPhase.connecting ||
    _MqttTestPhase.publishing => const Color(0xFFE69A35),
    _MqttTestPhase.connected ||
    _MqttTestPhase.success => const Color(0xFF3D8B62),
    _MqttTestPhase.error => AppTheme.errorColor,
  };

  IconData get _statusIcon => switch (phase) {
    _MqttTestPhase.idle => Icons.sensors_rounded,
    _MqttTestPhase.connecting ||
    _MqttTestPhase.publishing => Icons.sync_rounded,
    _MqttTestPhase.connected ||
    _MqttTestPhase.success => Icons.check_circle_rounded,
    _MqttTestPhase.error => Icons.error_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SettingPageStyles.cardPadding,
      decoration: SettingPageStyles.heroCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SettingPageStyles.settingIconSize,
                height: SettingPageStyles.settingIconSize,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.14),
                  borderRadius: SettingPageStyles.settingIconBorderRadius,
                ),
                child: Icon(_statusIcon, color: _statusColor, size: 30),
              ),
              const SizedBox(width: SettingPageStyles.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('連線狀態', style: SettingPageStyles.cardTitleStyle),
                    const SizedBox(height: SettingPageStyles.gap2xs),
                    Text(
                      message,
                      style: SettingPageStyles.bodyTextStyle.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(isConnected: isConnected),
            ],
          ),
          const SizedBox(height: SettingPageStyles.gapXl),
          _InfoRow(
            icon: Icons.dns_outlined,
            label: '${Esp32MqttInfo.brokerAddress}:${Esp32MqttInfo.port}',
          ),
          const SizedBox(height: SettingPageStyles.gapSm),
          const _InfoRow(icon: Icons.lock_outline_rounded, label: 'TLS 加密連線'),
          const SizedBox(height: SettingPageStyles.gapSm),
          _InfoRow(icon: Icons.account_circle_outlined, label: userLabel),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? const Color(0xFF3D8B62) : AppTheme.linkColor;

    return Container(
      padding: SettingPageStyles.statusChipPadding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SettingPageStyles.pillRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isConnected ? '已連線' : '未連線',
        style: SettingPageStyles.badgeTextStyle.copyWith(color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppTheme.linkColor),
        const SizedBox(width: SettingPageStyles.gapSm),
        Expanded(
          child: Text(
            label,
            style: SettingPageStyles.bodyTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

enum _MqttTestPhase { idle, connecting, connected, publishing, success, error }
