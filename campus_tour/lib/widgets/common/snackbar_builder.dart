import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';

enum AppToastType { success, warning, error, info }

class SnackBarBuilder {
  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        final scale = (size.width / 411.0).clamp(0.82, 1.08).toDouble();
        final colors = _ToastColors.fromType(type);

        return Positioned(
          top: size.height * 0.22,
          left: 22 * scale,
          right: 22 * scale,
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.88 + value * 0.12,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * -14 * scale),
                      child: child,
                    ),
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 360 * scale),
                  margin: EdgeInsets.symmetric(horizontal: 8 * scale),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 13 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.92),
                      width: 1.2 * scale,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 20 * scale,
                        offset: Offset(0, 10 * scale),
                      ),
                      BoxShadow(
                        color: colors.glow,
                        blurRadius: 12 * scale,
                        spreadRadius: 0.5 * scale,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34 * scale,
                        height: 34 * scale,
                        decoration: BoxDecoration(
                          color: colors.iconColor.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          colors.icon,
                          color: Colors.white.withValues(alpha: 0.95),
                          size: 20 * scale,
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Text(
                          message,
                          textAlign: TextAlign.left,
                          style: AppTheme.titleStyle.copyWith(
                            color: const Color(0xDD1F1F1F),
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    Future.delayed(duration, entry.remove);
  }

  static SnackBar showOut(String mes) {
    return SnackBar(
      content: Text(mes),
      duration: Duration(seconds: 2), // 設定停留時間，預設通常是 4 秒
      behavior: SnackBarBehavior.floating, // 讓它「浮起來」，看起來更現代
    );
  }
}

class _ToastColors {
  const _ToastColors({
    required this.glow,
    required this.iconColor,
    required this.icon,
  });

  final Color glow;
  final Color iconColor;
  final IconData icon;

  factory _ToastColors.fromType(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return const _ToastColors(
          glow: Color(0x3325D366),
          iconColor: Color(0xFF3AAF4A),
          icon: Icons.check_rounded,
        );
      case AppToastType.warning:
        return const _ToastColors(
          glow: Color(0x33FFD36A),
          iconColor: Color(0xFFE08B20),
          icon: Icons.priority_high_rounded,
        );
      case AppToastType.error:
        return const _ToastColors(
          glow: Color(0x33E57373),
          iconColor: Color(0xFFE05252),
          icon: Icons.close_rounded,
        );
      case AppToastType.info:
        return const _ToastColors(
          glow: Color(0x336AA8FF),
          iconColor: Color(0xFF4D7EDB),
          icon: Icons.auto_awesome_rounded,
        );
    }
  }
}
