import 'dart:async';

import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/controllers/user_controller.dart';
import 'package:campus_tour/features/station_hardware/models/station_hardware_models.dart';
import 'package:campus_tour/services/mqtt_service.dart';
import 'package:campus_tour/services/station_event_history_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

enum StationHardwarePhase {
  idle,
  loadingHistory,
  ready,
  cooldown,
  publishing,
  waitingForHardware,
  confirmed,
  confirmationTimeout,
  error,
}

/// Provides page-ready state for the station hardware interaction flow.
class StationHardwareViewModel extends GetxController
    with WidgetsBindingObserver {
  static const Duration cooldownDuration = Duration(hours: 24);
  static const Duration confirmationTimeout = Duration(minutes: 2);

  final MqttService _mqttService = MqttService();
  final StationEventHistoryService _historyService =
      StationEventHistoryService();
  final MonsterController _monsterController = Get.find<MonsterController>();
  final UserController _userController = Get.find<UserController>();

  final Rx<StationHardwarePhase> _phase = StationHardwarePhase.idle.obs;
  final Rxn<DateTime> _lastTriggerTime = Rxn<DateTime>();
  final RxnString _errorMessage = RxnString();
  final RxInt _clockTick = 0.obs;

  StreamSubscription<HardwareDeviceData?>? _confirmationSubscription;
  Completer<HardwareDeviceData>? _confirmationCompleter;
  Timer? _confirmationTimer;
  Timer? _cooldownTimer;
  Timer? _statusTicker;
  DateTime? _confirmationDeadline;

  bool _historyAvailable = false;
  bool _disposed = false;

  StationHardwarePhase get phase => _phase.value;
  Stream<StationHardwarePhase> get phaseChanges => _phase.stream;
  DateTime? get lastTriggerTime => _lastTriggerTime.value;
  String? get errorMessage => _errorMessage.value;

  int get capturedCount => _monsterController.userMonsterCollection.length;
  int? get totalMonsterCount => _monsterController.totalMonsterCount.value;

  bool get hasCollectedAll {
    final total = totalMonsterCount;
    return total != null && total > 0 && capturedCount >= total;
  }

  bool get isBusy {
    final currentPhase = phase;
    return currentPhase == StationHardwarePhase.loadingHistory ||
        currentPhase == StationHardwarePhase.publishing ||
        currentPhase == StationHardwarePhase.waitingForHardware;
  }

  bool get canSend {
    final total = totalMonsterCount;
    return _historyAvailable &&
        !isBusy &&
        _userController.userModel.value != null &&
        total != null &&
        total > 0 &&
        _isCooldownComplete;
  }

  Duration get remainingCooldown {
    _clockTick.value;
    final triggerTime = lastTriggerTime;
    if (triggerTime == null) return Duration.zero;

    final remaining = triggerTime
        .add(cooldownDuration)
        .difference(DateTime.now().toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Duration get remainingConfirmation {
    _clockTick.value;
    final deadline = _confirmationDeadline;
    if (deadline == null) return Duration.zero;

    final remaining = deadline.difference(DateTime.now().toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get _isCooldownComplete {
    final triggerTime = lastTriggerTime;
    if (triggerTime == null) return true;

    final nextAvailableTime = triggerTime.add(cooldownDuration);
    return !DateTime.now().toUtc().isBefore(nextAvailableTime);
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _statusTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_disposed) _clockTick.value++;
    });
    unawaited(refreshLastTriggerTime());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isBusy) {
      unawaited(refreshLastTriggerTime());
    }
  }

  Future<void> refreshLastTriggerTime() async {
    if (_disposed || isBusy) return;

    _phase.value = StationHardwarePhase.loadingHistory;
    _errorMessage.value = null;
    _historyAvailable = false;

    try {
      final deviceData = await _historyService.getCurrentDeviceData();
      if (_disposed) return;

      _applyDeviceData(deviceData);
      _phase.value = _isCooldownComplete
          ? StationHardwarePhase.ready
          : StationHardwarePhase.cooldown;
    } on StateError {
      _setError('使用者尚未登入', historyUnavailable: true);
    } on FormatException {
      _setError('硬體最後啟動時間格式錯誤', historyUnavailable: true);
    } on FirebaseException {
      _setError('無法讀取硬體最後啟動時間', historyUnavailable: true);
    } catch (_) {
      _setError('讀取硬體資料時發生未知錯誤', historyUnavailable: true);
    }
  }

  Future<void> send({
    required StationId stationId,
    required StationHardwareInput input,
  }) async {
    if (_disposed || isBusy) return;

    _errorMessage.value = null;
    await refreshLastTriggerTime();

    if (_disposed || !_historyAvailable) return;

    if (!_isCooldownComplete) {
      _phase.value = StationHardwarePhase.cooldown;
      return;
    }

    final total = totalMonsterCount;
    if (total == null || total <= 0) {
      _setError('精靈總數尚未載入');
      return;
    }

    var userModel = _userController.userModel.value;
    if (userModel == null) {
      await _userController.fetchCurrentUser();
      if (_disposed) return;
      userModel = _userController.userModel.value;
    }

    if (userModel == null) {
      _setError('玩家資料尚未載入');
      return;
    }

    if (userModel.nickname.trim().isEmpty) {
      _setError('玩家名稱不可為空');
      return;
    }

    final beforeTriggerTime = lastTriggerTime;
    final event = _eventForCollectionState();
    final eventData = MqttEventData.fromInput(
      input: input,
      displayName: userModel.nickname,
    );

    try {
      _phase.value = StationHardwarePhase.publishing;

      await _mqttService.sendStationEvent(
        stationId: stationId,
        event: event,
        data: eventData,
      );
      if (_disposed) return;

      _confirmationDeadline = DateTime.now().toUtc().add(confirmationTimeout);
      _clockTick.value++;
      _phase.value = StationHardwarePhase.waitingForHardware;
      final confirmedDevice = await _waitForHardwareUpdate(beforeTriggerTime);
      if (_disposed) return;

      _applyDeviceData(confirmedDevice);
      _errorMessage.value = null;
      _phase.value = StationHardwarePhase.confirmed;
    } on TimeoutException {
      if (_disposed) return;

      _errorMessage.value = '兩分鐘內沒有收到硬體更新，可以重新發送';
      _phase.value = StationHardwarePhase.confirmationTimeout;
    } on MqttAuthenticationException {
      _setError('登入狀態已失效，請重新登入');
    } on MqttConnectionException {
      _setError('無法連線至 MQTT Broker');
    } on MqttPublishException {
      _setError('MQTT 訊息發送失敗');
    } on FirebaseException {
      _setError('監聽硬體狀態時發生錯誤', historyUnavailable: true);
    } on FormatException {
      _setError('硬體回報的時間格式錯誤', historyUnavailable: true);
    } on _StationHardwareViewModelClosedException {
      return;
    } on StateError {
      _setError('硬體狀態監聽已中止', historyUnavailable: true);
    } catch (_) {
      _setError('發送過程發生未知錯誤');
    } finally {
      _confirmationDeadline = null;
      if (!_disposed) _clockTick.value++;
    }
  }

  MqttEventType _eventForCollectionState() {
    final total = totalMonsterCount;
    if (total == null || total <= 0) {
      throw StateError('Monster total count is unavailable');
    }

    return capturedCount >= total
        ? MqttEventType.challengeClear
        : MqttEventType.storyUnlock;
  }

  void _applyDeviceData(HardwareDeviceData? deviceData) {
    _historyAvailable = true;
    _lastTriggerTime.value = deviceData?.lastTriggerTime;
    _scheduleCooldownTimer();
  }

  void _scheduleCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;

    _statusTicker?.cancel();
    _statusTicker = null;
    _confirmationDeadline = null;

    final remaining = remainingCooldown;
    if (remaining == Duration.zero) return;

    _cooldownTimer = Timer(remaining, () {
      if (_disposed) return;

      _lastTriggerTime.refresh();
      if (!isBusy && _historyAvailable) {
        _phase.value = StationHardwarePhase.ready;
      }
    });
  }

  Future<HardwareDeviceData> _waitForHardwareUpdate(
    DateTime? beforeTriggerTime,
  ) async {
    await _stopHardwareConfirmation();
    if (_disposed) {
      throw const _StationHardwareViewModelClosedException();
    }

    final completer = Completer<HardwareDeviceData>();
    _confirmationCompleter = completer;

    _confirmationSubscription = _historyService.watchCurrentDeviceData().listen(
      (deviceData) {
        final newTime = deviceData?.lastTriggerTime;
        if (deviceData == null || newTime == null) return;

        final hasChanged =
            beforeTriggerTime == null || newTime.isAfter(beforeTriggerTime);
        if (hasChanged && !completer.isCompleted) {
          completer.complete(deviceData);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(
            StateError('Hardware history stream closed before confirmation'),
          );
        }
      },
    );

    _confirmationTimer = Timer(confirmationTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(
            'Hardware did not update lastTriggerTime',
            confirmationTimeout,
          ),
        );
      }
    });

    try {
      return await completer.future;
    } finally {
      await _stopHardwareConfirmation(owner: completer);
    }
  }

  Future<void> _stopHardwareConfirmation({
    Completer<HardwareDeviceData>? owner,
  }) async {
    if (owner != null && !identical(_confirmationCompleter, owner)) return;

    _confirmationTimer?.cancel();
    _confirmationTimer = null;

    final subscription = _confirmationSubscription;
    _confirmationSubscription = null;
    _confirmationCompleter = null;

    await subscription?.cancel();
  }

  void _setError(String message, {bool historyUnavailable = false}) {
    if (_disposed) return;

    if (historyUnavailable) {
      _historyAvailable = false;
    }
    _errorMessage.value = message;
    _phase.value = StationHardwarePhase.error;
  }

  @override
  void onClose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);

    _cooldownTimer?.cancel();
    _cooldownTimer = null;

    final completer = _confirmationCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(const _StationHardwareViewModelClosedException());
    }
    unawaited(_stopHardwareConfirmation(owner: completer));

    _mqttService.disconnect();
    super.onClose();
  }
}

final class _StationHardwareViewModelClosedException implements Exception {
  const _StationHardwareViewModelClosedException();
}
