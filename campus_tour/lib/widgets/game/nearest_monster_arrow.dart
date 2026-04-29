import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../controllers/monster_controller.dart';

class NearestMonsterArrow extends StatefulWidget {
  const NearestMonsterArrow({super.key});

  @override
  State<NearestMonsterArrow> createState() => _NearestMonsterArrowState();
}

class _NearestMonsterArrowState extends State<NearestMonsterArrow> {
  double _heading = 0; // 手機目前朝向（度，北=0）

  @override
  void initState() {
    super.initState();
    // 監聽羅盤
    FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null && mounted) {
        setState(() => _heading = event.heading!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<MonsterController>();
      final player = controller.playerPosition.value;
      final nearest = controller.nearestMonster.value;
      final distance = controller.nearestDistance.value;

      if (player == null || nearest == null) return const SizedBox.shrink();

      // 玩家 → 精靈的地理方位角
      final bearing = Geolocator.bearingBetween(
        player.latitude,
        player.longitude,
        nearest.location.latitude,
        nearest.location.longitude,
      );

      // 相對於手機螢幕的箭頭角度
      final angle = (bearing - _heading) * math.pi / 180.0;

      const double radius = 70;
      final dx = radius * math.sin(angle);
      final dy = -radius * math.cos(angle);

      return Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 精靈名稱 + 距離，固定在松鼠正上方
              Transform.translate(
                offset: const Offset(0, -110),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${nearest.name}  ${distance?.toStringAsFixed(0)} m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
  
              // 箭頭沿圓周移動
              Transform.translate(
                offset: Offset(dx, dy),
                child: _AnimatedArrow(angle: angle),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _AnimatedArrow extends StatefulWidget {
  final double angle;
  const _AnimatedArrow({required this.angle});

  @override
  State<_AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<_AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousAngle = 0;

  @override
  void initState() {
    super.initState();
    _previousAngle = widget.angle;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: widget.angle,
      end: widget.angle,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(_AnimatedArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.angle != widget.angle) {
      // 走短弧，避免跨 ±π 時繞遠路
      double delta = widget.angle - _previousAngle;
      if (delta > math.pi) delta -= 2 * math.pi;
      if (delta < -math.pi) delta += 2 * math.pi;

      final target = _previousAngle + delta;
      _animation = Tween<double>(
        begin: _previousAngle,
        end: target,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

      _previousAngle = target;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/arrow_global.png',
        width: 128,
        height: 128,
        fit: BoxFit.contain,
      ),
    );
  }
}