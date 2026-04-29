import 'package:flutter/material.dart';

import '../constants/asset_paths.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: SizedBox(
        height: 76,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              left: 24,
              right: 24,
              child: Image.asset(
                AssetPaths.wood,
                height: 56,
                fit: BoxFit.fill,
              ),
            ),

            Positioned(
              left: 66,
              bottom: 18,
              child: GestureDetector(
                onTap: onPrevious,
                child: Opacity(
                  opacity: onPrevious == null ? 0.4 : 1.0,
                  child: Image.asset(
                    AssetPaths.leftArrow,
                    width: 54,
                    height: 54,
                  ),
                ),
              ),
            ),

            Positioned(
              right: 66,
              bottom: 18,
              child: GestureDetector(
                onTap: onNext,
                child: Opacity(
                  opacity: onNext == null ? 0.4 : 1.0,
                  child: Image.asset(
                    AssetPaths.rightArrow,
                    width: 54,
                    height: 54,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 24,
              child: SizedBox(
                width: 170,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        AssetPaths.paper,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Text(
                      "第 $currentPage / $totalPages 頁",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4A2F25),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}