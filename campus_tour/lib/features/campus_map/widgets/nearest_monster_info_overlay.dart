import 'package:campus_tour/models/monster_model.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';

class NearestMonsterInfoOverlay extends StatelessWidget {
  const NearestMonsterInfoOverlay({
    super.key,
    required this.hasPlayerPosition,
    required this.nearestMonster,
    required this.distanceMeters,
    this.minimumVisibleDistance = 40,
  });

  final bool hasPlayerPosition;
  final MonsterModel? nearestMonster;
  final double? distanceMeters;
  final double minimumVisibleDistance;

  @override
  Widget build(BuildContext context) {
    final monster = nearestMonster;
    final distance = distanceMeters;
    if (!hasPlayerPosition ||
        monster == null ||
        distance == null ||
        !distance.isFinite ||
        distance < minimumVisibleDistance) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -110),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${monster.name}  ${distance.toStringAsFixed(0)} m',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.titleStyle.copyWith(
                  color: AppTheme.whiteTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
