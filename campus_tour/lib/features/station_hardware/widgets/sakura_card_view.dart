import 'dart:async';
import 'dart:math' as math;

import 'package:campus_tour/features/station_hardware/constants/sakura_assets.dart';
import 'package:campus_tour/features/station_hardware/constants/sakura_card_layout.dart';
import 'package:campus_tour/features/station_hardware/models/station_hardware_models.dart';
import 'package:campus_tour/features/station_hardware/pages/sakura_monster_picker_page.dart';
import 'package:campus_tour/features/station_hardware/view_models/sakura_card_draft_view_model.dart';
import 'package:campus_tour/features/station_hardware/view_models/station_hardware_view_model.dart';
import 'package:campus_tour/features/station_hardware/widgets/sakura_handwriting_pad.dart';
import 'package:campus_tour/features/station_hardware/widgets/sakura_page_controls.dart';
import 'package:campus_tour/models/user_monster_model.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SakuraCardView extends StatefulWidget {
  const SakuraCardView({
    super.key,
    required this.hardwareViewModel,
    required this.draftViewModel,
    required this.onPreviousPage,
    required this.onDrawingInteractionChanged,
  });

  final StationHardwareViewModel hardwareViewModel;
  final SakuraCardDraftViewModel draftViewModel;
  final VoidCallback onPreviousPage;
  final ValueChanged<bool> onDrawingInteractionChanged;

  @override
  State<SakuraCardView> createState() => _SakuraCardViewState();
}

class _SakuraCardViewState extends State<SakuraCardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _departureController;
  StreamSubscription<StationHardwarePhase>? _phaseSubscription;

  @override
  void initState() {
    super.initState();
    _departureController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
      reverseDuration: const Duration(milliseconds: 650),
    );
    _phaseSubscription = widget.hardwareViewModel.phaseChanges.listen(
      _handlePhase,
    );
  }

  @override
  void dispose() {
    unawaited(_phaseSubscription?.cancel());
    _departureController.dispose();
    super.dispose();
  }

  Future<void> _handlePhase(StationHardwarePhase phase) async {
    if (!mounted) return;

    if (phase == StationHardwarePhase.waitingForHardware) {
      await _departureController.forward();
      return;
    }

    if (phase == StationHardwarePhase.confirmed) {
      if (!_departureController.isCompleted) {
        await _departureController.forward();
      }
      if (mounted &&
          widget.hardwareViewModel.phase == StationHardwarePhase.confirmed) {
        widget.draftViewModel.clearDraft();
      }
      return;
    }

    if ((phase == StationHardwarePhase.confirmationTimeout ||
            phase == StationHardwarePhase.error) &&
        _departureController.value > 0) {
      await _departureController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final phase = widget.hardwareViewModel.phase;
      final isComplete = widget.hardwareViewModel.hasCollectedAll;
      final canSend = widget.hardwareViewModel.canSend;
      final lastTriggerTime = widget.hardwareViewModel.lastTriggerTime;
      final errorMessage = widget.hardwareViewModel.errorMessage;
      final cooldownDeadline = widget.hardwareViewModel.cooldownDeadline;
      final confirmationDeadline =
          widget.hardwareViewModel.confirmationDeadline;
      final isLocked =
          widget.hardwareViewModel.isBusy ||
          phase == StationHardwarePhase.confirmed;

      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(SakuraAssets.backgroundRight, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      SakuraAssets.smallSakura,
                      width: 32,
                      height: 32,
                      cacheWidth: 128,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final layout = isComplete
                            ? SakuraCardLayout.completed
                            : SakuraCardLayout.normal;
                        final width = math.min(
                          math.min(constraints.maxWidth, 400.0),
                          constraints.maxHeight * layout.aspectRatio,
                        );

                        return Center(
                          child: SizedBox(
                            width: width,
                            child: AnimatedBuilder(
                              animation: _departureController,
                              child: SakuraHandwritingCard(
                                draft: widget.draftViewModel,
                                isCollectionComplete: isComplete,
                                isLocked: isLocked,
                                onSelectMonster: _openMonsterPicker,
                                onDrawingInteractionChanged:
                                    widget.onDrawingInteractionChanged,
                              ),
                              builder: (context, card) => _DepartureAnimation(
                                progress: _departureController.value,
                                child: card!,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  SakuraHardwareStatusPanel(
                    phase: phase,
                    lastTriggerTime: lastTriggerTime,
                    errorMessage: errorMessage,
                    cooldownDeadline: cooldownDeadline,
                    confirmationDeadline: confirmationDeadline,
                  ),
                  const SizedBox(height: 5),
                  AnimatedBuilder(
                    animation: widget.draftViewModel,
                    builder: (context, _) {
                      final hasMonster =
                          widget.draftViewModel.selectedMonster != null;

                      return _SakuraSendButton(
                        label: _buttonLabel(phase),
                        visuallyEnabled: canSend && hasMonster,
                        interactive: canSend,
                        onTap: () => _send(hasMonster: hasMonster),
                      );
                    },
                  ),
                  const SizedBox(height: 7),
                  const SakuraPageIndicator(currentPage: 1),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: SakuraPageArrow(
                direction: AxisDirection.left,
                onTap: widget.onPreviousPage,
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _openMonsterPicker() async {
    if (widget.hardwareViewModel.isBusy) return;

    final monster = await Navigator.of(context).push<UserMonsterModel>(
      MaterialPageRoute(builder: (_) => const SakuraMonsterPickerPage()),
    );
    if (!mounted || monster == null) return;
    widget.draftViewModel.selectMonster(monster);
  }

  void _send({required bool hasMonster}) {
    FocusScope.of(context).unfocus();

    if (!hasMonster) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('features.station.hardware.sakura.page.s037'.tr),
        ),
      );
      return;
    }

    unawaited(
      widget.hardwareViewModel.send(
        stationId: StationId.sakura,
        input: StationHardwareInput(
          message: widget.draftViewModel.message.trim(),
        ),
      ),
    );
  }

  String _buttonLabel(StationHardwarePhase phase) {
    return switch (phase) {
      StationHardwarePhase.publishing =>
        'features.station.hardware.sakura.page.s033'.tr,
      StationHardwarePhase.waitingForHardware =>
        'features.station.hardware.sakura.page.s034'.tr,
      StationHardwarePhase.confirmationTimeout =>
        'features.station.hardware.sakura.page.s035'.tr,
      StationHardwarePhase.confirmed =>
        'features.station.hardware.sakura.page.s036'.tr,
      _ => 'features.station.hardware.sakura.page.s032'.tr,
    };
  }
}

class SakuraHardwareStatusPanel extends StatefulWidget {
  const SakuraHardwareStatusPanel({
    super.key,
    required this.phase,
    required this.lastTriggerTime,
    required this.errorMessage,
    required this.cooldownDeadline,
    required this.confirmationDeadline,
    this.now,
  });

  final StationHardwarePhase phase;
  final DateTime? lastTriggerTime;
  final String? errorMessage;
  final DateTime? cooldownDeadline;
  final DateTime? confirmationDeadline;

  /// Injectable clock used to keep countdown behavior deterministic in tests.
  final DateTime Function()? now;

  @override
  State<SakuraHardwareStatusPanel> createState() =>
      _SakuraHardwareStatusPanelState();
}

class _SakuraHardwareStatusPanelState extends State<SakuraHardwareStatusPanel> {
  static const Duration _cooldownResolution = Duration(minutes: 1);
  static const Duration _confirmationResolution = Duration(seconds: 1);

  Timer? _displayTimer;

  @override
  void initState() {
    super.initState();
    _scheduleNextRefresh();
  }

  @override
  void didUpdateWidget(covariant SakuraHardwareStatusPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase ||
        oldWidget.cooldownDeadline != widget.cooldownDeadline ||
        oldWidget.confirmationDeadline != widget.confirmationDeadline ||
        oldWidget.now != widget.now) {
      _scheduleNextRefresh();
    }
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    _displayTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDDAEA3).withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.lastTriggerTime == null
                ? 'features.station.hardware.sakura.page.s023'.tr
                : 'features.station.hardware.sakura.page.s022'.trParams({
                    'time': _formatDateTime(widget.lastTriggerTime!.toLocal()),
                  }),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.cardTitleStyle.copyWith(
              fontSize: 12,
              color: const Color(0xFF806057),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _statusText(),
            key: const ValueKey('sakura-hardware-status-text'),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.cardTitleStyle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6E443C),
            ),
          ),
        ],
      ),
    );
  }

  String _statusText() {
    return switch (widget.phase) {
      StationHardwarePhase.idle || StationHardwarePhase.loadingHistory =>
        'features.station.hardware.sakura.page.s024'.tr,
      StationHardwarePhase.ready =>
        'features.station.hardware.sakura.page.s025'.tr,
      StationHardwarePhase.cooldown =>
        'features.station.hardware.sakura.page.s026'.trParams({
          'duration': _formatCooldown(widget.cooldownDeadline),
        }),
      StationHardwarePhase.publishing =>
        'features.station.hardware.sakura.page.s027'.tr,
      StationHardwarePhase.waitingForHardware =>
        'features.station.hardware.sakura.page.s028'.trParams({
          'duration': _formatConfirmation(widget.confirmationDeadline),
        }),
      StationHardwarePhase.confirmed =>
        'features.station.hardware.sakura.page.s029'.tr,
      StationHardwarePhase.confirmationTimeout =>
        'features.station.hardware.sakura.page.s030'.tr,
      StationHardwarePhase.error =>
        widget.errorMessage ?? 'features.station.hardware.sakura.page.s031'.tr,
    };
  }

  void _scheduleNextRefresh() {
    _displayTimer?.cancel();
    _displayTimer = null;

    final deadline = _activeDeadline;
    final resolution = _activeResolution;
    if (deadline == null || resolution == null) return;

    final remaining = deadline.difference(_now);
    if (remaining <= Duration.zero) return;

    final unitMicroseconds = resolution.inMicroseconds;
    final remainder = remaining.inMicroseconds % unitMicroseconds;
    final delayMicroseconds = remainder == 0 ? unitMicroseconds : remainder;

    _displayTimer = Timer(Duration(microseconds: delayMicroseconds), () {
      if (!mounted) return;
      setState(() {});
      _scheduleNextRefresh();
    });
  }

  DateTime get _now => (widget.now ?? DateTime.now)().toUtc();

  DateTime? get _activeDeadline => switch (widget.phase) {
    StationHardwarePhase.cooldown => widget.cooldownDeadline,
    StationHardwarePhase.waitingForHardware => widget.confirmationDeadline,
    _ => null,
  };

  Duration? get _activeResolution => switch (widget.phase) {
    StationHardwarePhase.cooldown => _cooldownResolution,
    StationHardwarePhase.waitingForHardware => _confirmationResolution,
    _ => null,
  };

  String _formatDateTime(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${value.year}/${twoDigits(value.month)}/${twoDigits(value.day)} '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

  String _formatCooldown(DateTime? deadline) {
    final totalMinutes = _ceilingUnits(
      _remainingUntil(deadline),
      _cooldownResolution,
    );
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String _formatConfirmation(DateTime? deadline) {
    final totalSeconds = _ceilingUnits(
      _remainingUntil(deadline),
      _confirmationResolution,
    );
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Duration _remainingUntil(DateTime? deadline) {
    if (deadline == null) return Duration.zero;
    final remaining = deadline.difference(_now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int _ceilingUnits(Duration duration, Duration unit) {
    if (duration <= Duration.zero) return 0;
    return (duration.inMicroseconds + unit.inMicroseconds - 1) ~/
        unit.inMicroseconds;
  }
}

class _SakuraSendButton extends StatefulWidget {
  const _SakuraSendButton({
    required this.label,
    required this.visuallyEnabled,
    required this.interactive,
    required this.onTap,
  });

  final String label;
  final bool visuallyEnabled;
  final bool interactive;
  final VoidCallback onTap;

  @override
  State<_SakuraSendButton> createState() => _SakuraSendButtonState();
}

class _SakuraSendButtonState extends State<_SakuraSendButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.interactive,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.interactive ? widget.onTap : null,
        onTapDown: widget.interactive
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.interactive
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: widget.interactive
            ? () => setState(() => _isPressed = false)
            : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 110),
          child: AnimatedOpacity(
            opacity: widget.visuallyEnabled ? 1 : 0.58,
            duration: const Duration(milliseconds: 180),
            child: SizedBox(
              width: 292,
              height: 84,
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      SakuraAssets.sendButton,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      cacheWidth: 1168,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: AppTheme.titleStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: const Color(0xFF704036),
                            shadows: const [
                              Shadow(color: Colors.white70, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DepartureAnimation extends StatelessWidget {
  const _DepartureAnimation({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeInOutCubic.transform(progress);
    final cardProgress = (eased / 0.45).clamp(0.0, 1.0);
    final petalProgress = ((eased - 0.28) / 0.72).clamp(0.0, 1.0);
    final cardOpacity = (1 - cardProgress).clamp(0.0, 1.0);
    final petalOpacity = math
        .min((petalProgress * 4).clamp(0.0, 1.0), 1 - petalProgress * 0.85)
        .clamp(0.0, 1.0);
    final flightOffset = Offset(
      62 * math.sin(petalProgress * math.pi * 1.7) + 42 * petalProgress,
      -230 * petalProgress + 18 * math.sin(petalProgress * math.pi * 4),
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: cardOpacity,
          child: Transform.rotate(
            angle: -0.16 * cardProgress,
            child: Transform.scale(
              scale: 1 - cardProgress * 0.82,
              child: child,
            ),
          ),
        ),
        if (petalOpacity > 0)
          Transform.translate(
            offset: flightOffset,
            child: Transform.rotate(
              angle: petalProgress * math.pi * 3.6,
              child: Opacity(
                opacity: petalOpacity,
                child: Transform.scale(
                  scale: 1 - petalProgress * 0.28,
                  child: const CustomPaint(
                    size: Size(34, 50),
                    painter: _PetalPainter(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PetalPainter extends CustomPainter {
  const _PetalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.50, 0)
      ..cubicTo(
        size.width * 0.94,
        size.height * 0.18,
        size.width * 0.92,
        size.height * 0.72,
        size.width * 0.50,
        size.height,
      )
      ..cubicTo(
        size.width * 0.08,
        size.height * 0.72,
        size.width * 0.06,
        size.height * 0.18,
        size.width * 0.50,
        0,
      )
      ..close();

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFEEE9), Color(0xFFF3A8A9), Color(0xFFD97B82)],
      ).createShader(Offset.zero & size);
    final border = Paint()
      ..color = const Color(0xFFC96F76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawShadow(path, const Color(0x668D4B4F), 5, false);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _PetalPainter oldDelegate) => false;
}
