import 'dart:math' as math;

import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/features/station_hardware/constants/sakura_assets.dart';
import 'package:campus_tour/features/station_hardware/view_models/station_hardware_view_model.dart';
import 'package:campus_tour/features/station_hardware/widgets/sakura_page_controls.dart';
import 'package:campus_tour/models/user_monster_model.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/utils/monster_image_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SakuraCollectionView extends StatelessWidget {
  const SakuraCollectionView({
    super.key,
    required this.hardwareViewModel,
    required this.onNextPage,
  });

  final StationHardwareViewModel hardwareViewModel;
  final VoidCallback onNextPage;

  @override
  Widget build(BuildContext context) {
    final monsterController = Get.find<MonsterController>();

    return Obx(() {
      final captured = hardwareViewModel.capturedCount;
      final total = hardwareViewModel.totalMonsterCount;
      final isComplete = hardwareViewModel.hasCollectedAll;
      final representatives = _representatives(
        monsterController.userMonsterCollection,
      );

      return Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: Image.asset(
                isComplete
                    ? SakuraAssets.backgroundLeftFull
                    : SakuraAssets.backgroundLeft,
                key: ValueKey(isComplete),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      SakuraAssets.smallSakura,
                      width: 34,
                      height: 34,
                      cacheWidth: 136,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'features.station.hardware.sakura.page.s001'.tr,
                    textAlign: TextAlign.center,
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 29,
                      color: const Color(0xFF68463E),
                      letterSpacing: 1,
                    ),
                  ),
                  Image.asset(
                    SakuraAssets.lineLong,
                    width: 260,
                    height: 50,
                    fit: BoxFit.contain,
                    cacheWidth: 900,
                  ),
                  _CollectionCount(captured: captured, total: total),
                  Image.asset(
                    SakuraAssets.lineShort,
                    width: 215,
                    height: 40,
                    fit: BoxFit.contain,
                    cacheWidth: 760,
                  ),
                  Text(
                    'features.station.hardware.sakura.page.s002'.tr,
                    style: AppTheme.cardTitleStyle.copyWith(
                      fontSize: 17,
                      color: const Color(0xFF755149),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: representatives.isEmpty
                        ? Center(
                            child: Text(
                              'features.station.hardware.sakura.page.s007'.tr,
                              style: AppTheme.cardTitleStyle.copyWith(
                                fontSize: 15,
                                color: const Color(0xFF8B6B64),
                              ),
                            ),
                          )
                        : _RepresentativeFairies(monsters: representatives),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _progressMessage(
                      isComplete: isComplete,
                      captured: captured,
                      total: total,
                    ),
                    textAlign: TextAlign.center,
                    style: AppTheme.cardTitleStyle.copyWith(
                      fontSize: 17,
                      color: const Color(0xFF704940),
                    ),
                  ),
                  const Spacer(flex: 2),
                  const SakuraPageIndicator(currentPage: 0),
                ],
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: SakuraPageArrow(
                direction: AxisDirection.right,
                onTap: onNextPage,
              ),
            ),
          ),
        ],
      );
    });
  }

  List<UserMonsterModel> _representatives(Iterable<UserMonsterModel> monsters) {
    final sorted = monsters.toList()
      ..sort((a, b) => b.caughtAt.compareTo(a.caughtAt));
    return sorted.take(5).toList(growable: false);
  }

  String _progressMessage({
    required bool isComplete,
    required int captured,
    required int? total,
  }) {
    if (isComplete) {
      return 'features.station.hardware.sakura.page.s006'.tr;
    }
    if (total == null || total <= 0) return '';

    return 'features.station.hardware.sakura.page.s005'.trParams({
      'count': '${math.max(0, total - captured)}',
    });
  }
}

class _CollectionCount extends StatelessWidget {
  const _CollectionCount({required this.captured, required this.total});

  final int captured;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final totalText = total == null ? '--' : '$total';

    return Semantics(
      label: total == null
          ? 'features.station.hardware.sakura.page.s004'.trParams({
              'captured': '$captured',
            })
          : 'features.station.hardware.sakura.page.s003'.trParams({
              'captured': '$captured',
              'total': totalText,
            }),
      child: ExcludeSemantics(
        child: RichText(
          text: TextSpan(
            style: AppTheme.titleStyle.copyWith(
              color: const Color(0xFF714A42),
              letterSpacing: 0,
            ),
            children: [
              TextSpan(
                text: '$captured',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: ' / $totalText',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepresentativeFairies extends StatelessWidget {
  const _RepresentativeFairies({required this.monsters});

  final List<UserMonsterModel> monsters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const fairyWidth = 86.0;
        final step = monsters.length <= 1
            ? 0.0
            : (constraints.maxWidth - fairyWidth) / (monsters.length - 1);

        return Stack(
          alignment: Alignment.center,
          children: [
            for (var index = 0; index < monsters.length; index++)
              Positioned(
                left: monsters.length == 1
                    ? (constraints.maxWidth - fairyWidth) / 2
                    : index * step,
                top: index.isEven ? 4 : 15,
                width: fairyWidth,
                height: 104,
                child: Image.asset(
                  MonsterImagePath.staticImage(monsters[index].imageURL),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF9B6B5E),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
