import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerSprite extends StatefulWidget {
  /// 顯示大小（螢幕上的像素，可自行調整）
  final double size;
 
  const PlayerSprite({
    super.key,
    this.size = 80,
  });
 
  @override
  State<PlayerSprite> createState() => _PlayerSpriteState();
}

class _PlayerSpriteState extends State<PlayerSprite> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Sprite sheet 參數
  static const int _totalFrames = 4;       // 第一列共 4 幀
  static const double _frameWidth = 270;   // 每幀寬度（px）
  static const double _frameHeight = 270;  // 每幀高度（px）
  static const double _rowOffset = 0;      // 第一列，Y 偏移為 0

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // 每幀停留約 150ms，4 幀一循環 = 600ms
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _SpriteImageCache.instance.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // 根據動畫進度算出目前是第幾幀（0~3）
        final frameIndex = (_controller.value * _totalFrames).floor();
 
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SpritePainter(
            frameIndex: frameIndex,
            frameWidth: _frameWidth,
            frameHeight: _frameHeight,
            rowOffset: _rowOffset,
            offsetX: 85,
            offsetY: 30,
          ),
        );
      },
    );
  }
}

class _SpritePainter extends CustomPainter {
  final int frameIndex;
  final double frameWidth;
  final double frameHeight;
  final double rowOffset;
  final double offsetX;
  final double offsetY;

  _SpritePainter({
    required this.frameIndex,
    required this.frameWidth,
    required this.frameHeight,
    required this.rowOffset,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // src：從 sprite sheet 裁出的區域
    final src = Rect.fromLTWH(
      frameIndex * frameWidth + offsetX, // X：第幾幀
      rowOffset + offsetY,               // Y：第幾列
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
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      oldDelegate.frameIndex != frameIndex;
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