import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainMapStatusOverlay extends StatelessWidget {
  const MainMapStatusOverlay({
    super.key,
    required this.hasLocation,
    required this.isPlayerInsideCampusBounds,
    this.locationUnavailableMessage,
  });

  final bool hasLocation;
  final bool isPlayerInsideCampusBounds;
  final String? locationUnavailableMessage;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            if (!hasLocation)
              Positioned(
                right: 16,
                top: 136,
                child: SafeArea(child: _buildLocationUnavailableNotice()),
              ),
            if (hasLocation && !isPlayerInsideCampusBounds)
              const Align(
                alignment: Alignment(0, -0.4),
                child: _OutOfCampusNotice(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationUnavailableNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        locationUnavailableMessage ?? 'widgets.game.game.map.s012'.tr,
        style: AppTheme.titleStyle.copyWith(
          color: Colors.black87,
          fontSize: 14,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _OutOfCampusNotice extends StatelessWidget {
  const _OutOfCampusNotice();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.85),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          'widgets.game.game.map.s017'.tr,
          textAlign: TextAlign.center,
          style: AppTheme.titleStyle.copyWith(
            color: AppTheme.gameTextColor,
            fontSize: 22,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
