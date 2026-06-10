import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/widgets/constants/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MonsterCollectionBadge extends StatelessWidget {
  const MonsterCollectionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);
    final controller = Get.find<MonsterController>();

    return Obx(() {
      final caughtCount = controller.userMonsterCollection.length;
      final totalCount = controller.totalMonsterCount.value;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 6 * scale,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            255,
            243,
            221,
            199,
          ).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(8 * scale),
          border: Border.all(
            color: const Color(0xFF4A2F25).withValues(alpha: 0.22),
            width: 1 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.catching_pokemon_rounded,
              size: 18 * scale,
              color: AppTheme.primaryColor,
            ),
            SizedBox(width: 6 * scale),
            Text(
              totalCount == null
                  ? '精靈 $caughtCount / --'
                  : '精靈 $caughtCount / $totalCount',
              style: AppTheme.titleStyle.copyWith(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4A2F25),
                letterSpacing: 0,
                height: 1,
              ),
            ),
          ],
        ),
      );
    });
  }
}
