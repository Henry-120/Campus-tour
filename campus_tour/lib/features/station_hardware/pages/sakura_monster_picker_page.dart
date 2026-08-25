import 'dart:math' as math;

import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/features/station_hardware/constants/sakura_assets.dart';
import 'package:campus_tour/features/station_hardware/widgets/sakura_monster_choice_card.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SakuraMonsterPickerPage extends StatefulWidget {
  const SakuraMonsterPickerPage({super.key});

  @override
  State<SakuraMonsterPickerPage> createState() =>
      _SakuraMonsterPickerPageState();
}

class _SakuraMonsterPickerPageState extends State<SakuraMonsterPickerPage> {
  static const int _itemsPerPage = 9;

  final MonsterController _monsterController = Get.find<MonsterController>();
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFFFF6EF),
      appBar: AppBar(
        title: Text(
          'features.station.hardware.sakura.page.s019'.tr,
          style: AppTheme.titleStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5F4038),
            letterSpacing: 0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF5F4038),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              SakuraAssets.pickerBackground,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Obx(() {
              final monsters = _monsterController.userMonsterCollection.toList(
                growable: false,
              );
              if (monsters.isEmpty) {
                return Center(
                  child: Text(
                    'features.station.hardware.sakura.page.s020'.tr,
                    style: AppTheme.cardTitleStyle.copyWith(fontSize: 17),
                  ),
                );
              }

              final totalPages = (monsters.length / _itemsPerPage).ceil();
              final visiblePage = math.min(_currentPage, totalPages);
              final start = (visiblePage - 1) * _itemsPerPage;
              final end = math.min(start + _itemsPerPage, monsters.length);
              final pageItems = monsters.sublist(start, end);

              return Column(
                children: [
                  const SizedBox(height: 18),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: pageItems.length,
                      itemBuilder: (context, index) {
                        final monster = pageItems[index];
                        return SakuraMonsterChoiceCard(
                          monster: monster,
                          onTap: () => Navigator.of(context).pop(monster),
                        );
                      },
                    ),
                  ),
                  _PickerPageControls(
                    currentPage: visiblePage,
                    totalPages: totalPages,
                    onPrevious: visiblePage > 1
                        ? () => setState(() => _currentPage = visiblePage - 1)
                        : null,
                    onNext: visiblePage < totalPages
                        ? () => setState(() => _currentPage = visiblePage + 1)
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PickerPageControls extends StatelessWidget {
  const _PickerPageControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 8, 36, 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F2).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD9A399)),
              ),
              child: Text(
                'features.station.hardware.sakura.page.s021'.trParams({
                  'current': '$currentPage',
                  'total': '$totalPages',
                }),
                style: AppTheme.cardTitleStyle.copyWith(fontSize: 14),
              ),
            ),
            IconButton.filledTonal(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
