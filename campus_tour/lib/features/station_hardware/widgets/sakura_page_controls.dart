import 'package:campus_tour/features/station_hardware/constants/sakura_assets.dart';
import 'package:flutter/material.dart';

class SakuraPageIndicator extends StatelessWidget {
  const SakuraPageIndicator({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    Widget dot(bool active) {
      if (active) {
        return Image.asset(
          SakuraAssets.smallSakura,
          width: 21,
          height: 21,
          cacheWidth: 84,
        );
      }
      return Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFC98C82),
        ),
      );
    }

    return Semantics(
      label: '${currentPage + 1} / 2',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot(currentPage == 0),
          const SizedBox(width: 9),
          dot(currentPage == 1),
        ],
      ),
    );
  }
}

class SakuraPageArrow extends StatelessWidget {
  const SakuraPageArrow({
    super.key,
    required this.direction,
    required this.onTap,
  });

  final AxisDirection direction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = direction == AxisDirection.left
        ? Icons.arrow_back_ios_new_rounded
        : Icons.arrow_forward_ios_rounded;

    return Semantics(
      button: true,
      child: Material(
        color: const Color(0xFFFFFAF5).withValues(alpha: 0.80),
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(icon, size: 21, color: const Color(0xFF8D5A50)),
          ),
        ),
      ),
    );
  }
}
