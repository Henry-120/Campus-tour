import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';
import '../constants/responsive.dart';
import '../constants/asset_paths.dart';
import 'monster_collection_badge.dart';

class PageSelector extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PageSelector({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 28 * scale),
      child: SizedBox(
        height: 108 * scale,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              left: 24 * scale,
              right: 24 * scale,
              child: Image.asset(
                AssetPaths.wood,
                height: 56 * scale,
                fit: BoxFit.fill,
              ),
            ),

            Positioned(
              left: 66 * scale,
              bottom: 18 * scale,
              child: GestureDetector(
                onTap: onPrevious,
                child: Opacity(
                  opacity: onPrevious == null ? 0.4 : 1.0,
                  child: Image.asset(
                    AssetPaths.leftArrow,
                    width: 54 * scale,
                    height: 54 * scale,
                  ),
                ),
              ),
            ),

            Positioned(
              right: 66 * scale,
              bottom: 18 * scale,
              child: GestureDetector(
                onTap: onNext,
                child: Opacity(
                  opacity: onNext == null ? 0.4 : 1.0,
                  child: Image.asset(
                    AssetPaths.rightArrow,
                    width: 54 * scale,
                    height: 54 * scale,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 24 * scale,
              child: SizedBox(
                width: 170 * scale,
                height: 48 * scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Image.asset(AssetPaths.paper, fit: BoxFit.fill),
                    ),
                    Text(
                      "第 $currentPage / $totalPages 頁",
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4A2F25),
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 78 * scale,
              child: const MonsterCollectionBadge(),
            ),
          ],
        ),
      ),
    );
  }
}
