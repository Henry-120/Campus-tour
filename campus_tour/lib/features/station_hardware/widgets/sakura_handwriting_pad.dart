import 'dart:math' as math;

import 'package:campus_tour/features/station_hardware/constants/sakura_assets.dart';
import 'package:campus_tour/features/station_hardware/constants/sakura_card_layout.dart';
import 'package:campus_tour/features/station_hardware/models/sakura_card_draft.dart';
import 'package:campus_tour/features/station_hardware/view_models/sakura_card_draft_view_model.dart';
import 'package:campus_tour/models/user_monster_model.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/utils/monster_image_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SakuraHandwritingCard extends StatelessWidget {
  const SakuraHandwritingCard({
    super.key,
    required this.draft,
    required this.isCollectionComplete,
    required this.isLocked,
    required this.onSelectMonster,
  });

  final SakuraCardDraftViewModel draft;
  final bool isCollectionComplete;
  final bool isLocked;
  final VoidCallback onSelectMonster;

  @override
  Widget build(BuildContext context) {
    final layout = isCollectionComplete
        ? SakuraCardLayout.completed
        : SakuraCardLayout.normal;
    final asset = isCollectionComplete
        ? SakuraAssets.cardFull
        : SakuraAssets.card;

    return AspectRatio(
      aspectRatio: layout.aspectRatio,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill)),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                final writingRect = layout.writingRectFor(cardSize);
                final monsterRect = layout.monsterRectFor(cardSize);
                final toolExtent = math.min(
                  40.0,
                  math.max(34.0, writingRect.height * 0.25),
                );
                const toolGap = 2.0;
                final toolbarWidth = toolExtent * 3 + toolGap * 2;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fromRect(
                      rect: writingRect,
                      child: _WritingSurface(draft: draft, isLocked: isLocked),
                    ),
                    Positioned(
                      left: writingRect.right - toolbarWidth - 4,
                      top: writingRect.top - toolExtent * 0.48,
                      child: AnimatedBuilder(
                        animation: draft,
                        builder: (context, _) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _DrawingToolButton(
                                extent: toolExtent,
                                icon: Icons.undo_rounded,
                                tooltip:
                                    'features.station.hardware.sakura.page.s016'
                                        .tr,
                                onPressed: !isLocked && draft.canUndo
                                    ? draft.undo
                                    : null,
                              ),
                              const SizedBox(width: toolGap),
                              _DrawingToolButton(
                                extent: toolExtent,
                                icon: Icons.redo_rounded,
                                tooltip:
                                    'features.station.hardware.sakura.page.s017'
                                        .tr,
                                onPressed: !isLocked && draft.canRedo
                                    ? draft.redo
                                    : null,
                              ),
                              const SizedBox(width: toolGap),
                              _DrawingToolButton(
                                extent: toolExtent,
                                icon: Icons.delete_sweep_rounded,
                                tooltip:
                                    'features.station.hardware.sakura.page.s018'
                                        .tr,
                                onPressed: !isLocked && draft.canClear
                                    ? draft.clearDrawing
                                    : null,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Positioned.fromRect(
                      rect: monsterRect,
                      child: AnimatedBuilder(
                        animation: draft,
                        builder: (context, _) {
                          return _MonsterSelectionTarget(
                            monster: draft.selectedMonster,
                            enabled: !isLocked,
                            onTap: onSelectMonster,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WritingSurface extends StatefulWidget {
  const _WritingSurface({required this.draft, required this.isLocked});

  final SakuraCardDraftViewModel draft;
  final bool isLocked;

  @override
  State<_WritingSurface> createState() => _WritingSurfaceState();
}

class _WritingSurfaceState extends State<_WritingSurface> {
  static const double _minimumPointDistance = 2.5;
  Offset? _lastAcceptedLocalPoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return ClipRect(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  key: const ValueKey('sakura-handwriting-surface'),
                  behavior: HitTestBehavior.opaque,
                  onPanStart: widget.isLocked
                      ? null
                      : (details) => _startStroke(details.localPosition, size),
                  onPanUpdate: widget.isLocked
                      ? null
                      : (details) => _updateStroke(details.localPosition, size),
                  onPanEnd: widget.isLocked ? null : (_) => _finishStroke(),
                  onPanCancel: widget.isLocked ? null : _cancelStroke,
                  child: AnimatedBuilder(
                    animation: widget.draft,
                    builder: (context, _) {
                      return RepaintBoundary(
                        child: CustomPaint(
                          painter: _SakuraStrokePainter(
                            strokes: widget.draft.strokes,
                            activePoints: widget.draft.activePoints,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: widget.draft,
                    builder: (context, _) {
                      return AnimatedOpacity(
                        key: const ValueKey('sakura-writing-prompts'),
                        opacity: widget.draft.hasHandwriting ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: const _WritingPrompts(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startStroke(Offset localPoint, Size size) {
    _lastAcceptedLocalPoint = localPoint;
    widget.draft.beginStroke(_normalize(localPoint, size));
  }

  void _updateStroke(Offset localPoint, Size size) {
    final previous = _lastAcceptedLocalPoint;
    if (previous != null &&
        (localPoint - previous).distance < _minimumPointDistance) {
      return;
    }

    if (widget.draft.appendPoint(_normalize(localPoint, size))) {
      _lastAcceptedLocalPoint = localPoint;
    }
  }

  void _finishStroke() {
    _lastAcceptedLocalPoint = null;
    widget.draft.endStroke();
  }

  void _cancelStroke() {
    _lastAcceptedLocalPoint = null;
    widget.draft.cancelStroke();
  }

  Offset _normalize(Offset point, Size size) {
    return Offset(point.dx / size.width, point.dy / size.height);
  }
}

class _WritingPrompts extends StatelessWidget {
  const _WritingPrompts();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7).withValues(alpha: 0.62),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _PromptRow(
              labelKey: 'features.station.hardware.sakura.page.s008',
              descriptionKey: 'features.station.hardware.sakura.page.s009',
            ),
            SizedBox(height: 4),
            _PromptRow(
              labelKey: 'features.station.hardware.sakura.page.s010',
              descriptionKey: 'features.station.hardware.sakura.page.s011',
            ),
            SizedBox(height: 4),
            _PromptRow(
              labelKey: 'features.station.hardware.sakura.page.s012',
              descriptionKey: 'features.station.hardware.sakura.page.s013',
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptRow extends StatelessWidget {
  const _PromptRow({required this.labelKey, required this.descriptionKey});

  final String labelKey;
  final String descriptionKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          SakuraAssets.smallSakura,
          width: 13,
          height: 13,
          cacheWidth: 52,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 30,
          child: Text(
            labelKey.tr,
            style: AppTheme.cardTitleStyle.copyWith(
              fontSize: 10,
              height: 1.1,
              color: const Color(0xFF75483F),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            descriptionKey.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.cardTitleStyle.copyWith(
              fontSize: 9,
              height: 1.15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8B6259),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonsterSelectionTarget extends StatelessWidget {
  const _MonsterSelectionTarget({
    required this.monster,
    required this.enabled,
    required this.onTap,
  });

  final UserMonsterModel? monster;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedMonster = monster;

    return Semantics(
      key: const ValueKey('sakura-monster-selection-target'),
      button: true,
      label: selectedMonster == null
          ? 'features.station.hardware.sakura.page.s014'.tr
          : 'features.station.hardware.sakura.page.s015'.tr,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F2).withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD6978B).withValues(alpha: 0.68),
              ),
            ),
            child: selectedMonster == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        'features.station.hardware.sakura.page.s014'.tr,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: AppTheme.cardTitleStyle.copyWith(
                          fontSize: 9,
                          height: 1.15,
                          color: const Color(0xFF85594F),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            MonsterImagePath.staticImage(
                              selectedMonster.imageURL,
                            ),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.broken_image_outlined,
                              size: 20,
                              color: Color(0xFF9A6E63),
                            ),
                          ),
                        ),
                        Text(
                          selectedMonster.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.cardTitleStyle.copyWith(
                            fontSize: 8,
                            height: 1,
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

class _DrawingToolButton extends StatelessWidget {
  const _DrawingToolButton({
    required this.extent,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final double extent;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: extent,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFFFF8F2).withValues(alpha: 0.94),
          disabledBackgroundColor: const Color(
            0xFFFFF8F2,
          ).withValues(alpha: 0.62),
          side: BorderSide(
            color: const Color(0xFFD6978B).withValues(alpha: 0.70),
          ),
        ),
        icon: Icon(icon, size: extent * 0.48),
        color: const Color(0xFF7E5148),
        disabledColor: const Color(0xFFB99D96),
      ),
    );
  }
}

class _SakuraStrokePainter extends CustomPainter {
  const _SakuraStrokePainter({
    required this.strokes,
    required this.activePoints,
  });

  final List<SakuraStroke> strokes;
  final List<Offset> activePoints;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6F4A43)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.7, size.shortestSide * 0.014)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      _drawStroke(canvas, size, stroke.points, paint);
    }
    _drawStroke(canvas, size, activePoints, paint);
  }

  void _drawStroke(
    Canvas canvas,
    Size size,
    List<Offset> normalizedPoints,
    Paint paint,
  ) {
    if (normalizedPoints.isEmpty) return;

    Offset scale(Offset point) =>
        Offset(point.dx * size.width, point.dy * size.height);

    if (normalizedPoints.length == 1) {
      final point = scale(normalizedPoints.first);
      canvas.drawCircle(point, paint.strokeWidth / 2, paint);
      return;
    }

    final path = Path()
      ..moveTo(
        normalizedPoints.first.dx * size.width,
        normalizedPoints.first.dy * size.height,
      );
    for (final point in normalizedPoints.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SakuraStrokePainter oldDelegate) => true;
}
