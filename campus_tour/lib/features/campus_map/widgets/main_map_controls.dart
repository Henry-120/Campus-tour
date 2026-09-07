import 'package:campus_tour/features/campus_map/controllers/main_map_image_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainMapControls extends StatelessWidget {
  const MainMapControls({
    super.key,
    required this.selectedMapKind,
    required this.onMapKindSelected,
    required this.onOpenDrawer,
    required this.onReturnToPlayer,
    required this.canReturnToPlayer,
  });

  final MainMapKind selectedMapKind;
  final ValueChanged<MainMapKind> onMapKindSelected;
  final VoidCallback onOpenDrawer;
  final VoidCallback onReturnToPlayer;
  final bool canReturnToPlayer;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 16,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MapKindButton(
              selectedMapKind: selectedMapKind,
              onSelected: onMapKindSelected,
            ),
            const SizedBox(height: 8),
            _ImageControlButton(
              assetPath: 'assets/images/component/side_bar.png',
              onTap: onOpenDrawer,
            ),
            if (canReturnToPlayer) ...[
              const SizedBox(height: 8),
              _ImageControlButton(
                assetPath: 'assets/images/component/position_return.png',
                onTap: onReturnToPlayer,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapKindButton extends StatelessWidget {
  const _MapKindButton({
    required this.selectedMapKind,
    required this.onSelected,
  });

  final MainMapKind selectedMapKind;
  final ValueChanged<MainMapKind> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MainMapKind>(
      tooltip: 'widgets.game.game.map.s013'.tr,
      initialValue: selectedMapKind,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final kind in MainMapKind.values)
          PopupMenuItem<MainMapKind>(
            value: kind,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  kind == selectedMapKind
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: Colors.black87,
                ),
                const SizedBox(width: 10),
                Text(_labelFor(kind)),
              ],
            ),
          ),
      ],
      child: Image.asset(
        'assets/images/component/layers.png',
        width: 52,
        height: 52,
        fit: BoxFit.contain,
      ),
    );
  }

  String _labelFor(MainMapKind kind) {
    return switch (kind) {
      MainMapKind.campus => 'widgets.game.game.map.s001'.tr,
      MainMapKind.forest => 'widgets.game.game.map.s002'.tr,
    };
  }
}

class _ImageControlButton extends StatelessWidget {
  const _ImageControlButton({required this.assetPath, required this.onTap});

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Image.asset(assetPath, width: 52, height: 52, fit: BoxFit.contain),
    );
  }
}
