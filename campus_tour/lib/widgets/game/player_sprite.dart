import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';

enum PlayerDirection {
  up,    // 手機朝北：角色背面 / 往上走
  down,  // 手機朝南：角色正面 / 往下走
  left,  // 手機朝西
  right, // 手機朝東
}

class PlayerSprite extends StatefulWidget {
  /// 顯示大小（螢幕上的像素，可自行調整）
  final double size;
  final bool isMoving;

  /// 輪盤方向，例如 Offset(dx, dy)
  /// dx > 0 = 右
  /// dx < 0 = 左
  /// dy < 0 = 上 / 向後
  /// dy > 0 = 下 / 正面
 
  const PlayerSprite({
    super.key,
    this.size = 80,
    this.isMoving = true,
  });
 
  @override
  State<PlayerSprite> createState() => _PlayerSpriteState();
}

class _PlayerSpriteState extends State<PlayerSprite> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  StreamSubscription<CompassEvent>? _compassSub;

  // Sprite sheet 參數
  static const int _totalFrames = 4;       // 第一列共 4 幀
  static const double _frameWidth = 270;   // 每幀寬度（px）
  static const double _frameHeight = 270;  // 每幀高度（px）

  PlayerDirection _direction = PlayerDirection.down;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // 每幀停留約 150ms，4 幀一循環 = 600ms
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isMoving) {
      _controller.repeat();
    }

    _SpriteImageCache.instance.load().then((_) {
      if (mounted) setState(() {});
    });

    _compassSub = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null || !mounted) return;

      setState(() {
        _direction = _directionFromHeading(heading);
      });
    });
  }

  PlayerDirection _directionFromHeading(double heading) {
    final h = (heading + 360) % 360;

    if (h >= 315 || h < 45) {
      return PlayerDirection.up; // 北
    } else if (h >= 45 && h < 135) {
      return PlayerDirection.right; // 東
    } else if (h >= 135 && h < 225) {
      return PlayerDirection.down; // 南
    } else {
      return PlayerDirection.left; // 西
    }
  }

  int _rowIndexFromDirection(PlayerDirection direction) {
    switch (direction) {
      case PlayerDirection.up:
        return 0; // 第一列：向後 / 上
      case PlayerDirection.down:
        return 1; // 第二列：向下 / 正面
      case PlayerDirection.left:
        return 2; // 第三列：向左
      case PlayerDirection.right:
        return 3; // 第四列：向右
    }
  }

  Offset _cropOffsetForDirection(PlayerDirection direction) {
    switch (direction) {
      case PlayerDirection.up:
        return const Offset(85, 30); // 第一列：向上
      case PlayerDirection.down:
        return const Offset(85, 70); // 第二列：向後
      case PlayerDirection.left:
        return const Offset(100, 70); // 第三列：向左
      case PlayerDirection.right:
        return const Offset(90, 120); // 第四列：向右
    }
  }

  @override
  void didUpdateWidget(covariant PlayerSprite oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isMoving && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isMoving && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rowIndex = _rowIndexFromDirection(_direction);
    final cropOffset = _cropOffsetForDirection(_direction);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // 根據動畫進度算出目前是第幾幀（0~3）
        final frameIndex = widget.isMoving
            ? math.min(
                (_controller.value * _totalFrames).floor(),
                _totalFrames - 1,
              )
            : 0;
 
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SpritePainter(
            frameIndex: frameIndex,
            rowIndex: rowIndex,
            frameWidth: _frameWidth,
            frameHeight: _frameHeight,
            offsetX: cropOffset.dx,
            offsetY: cropOffset.dy,
          ),
        );
      },
    );
  }
}

class _SpritePainter extends CustomPainter {
  final int frameIndex;
  final int rowIndex;
  final double frameWidth;
  final double frameHeight;
  final double offsetX;
  final double offsetY;

  _SpritePainter({
    required this.frameIndex,
    required this.rowIndex,
    required this.frameWidth,
    required this.frameHeight,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // src：從 sprite sheet 裁出的區域
    final src = Rect.fromLTWH(
      frameIndex * frameWidth + offsetX, // X：第幾幀
      rowIndex * frameHeight + offsetY,               // Y：第幾列
      frameWidth,
      frameHeight,
    );
 
    // dst：畫到螢幕上的區域（填滿 CustomPaint 的 size）
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
 
    // 這裡用 drawImageRect，image 透過 _SpriteImage 單例提供
    final image = _SpriteImageCache.instance.image;
    if (image != null) {
      canvas.drawImageRect(image, src, dst, Paint());
    }
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) {
    return oldDelegate.frameIndex != frameIndex ||
        oldDelegate.rowIndex != rowIndex;
  }
}

/// 全域圖片快取，確保 sprite sheet 只載入一次
class _SpriteImageCache {
  _SpriteImageCache._();
  static final _SpriteImageCache instance = _SpriteImageCache._();
 
  ui.Image? image;
  bool _loading = false;
 
  Future<void> load() async {
    if (image != null || _loading) return;
    _loading = true;
    final data = await rootBundle.load('assets/images/squirrel_walking.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    image = frame.image;
  }
}