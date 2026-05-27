import 'package:flutter/material.dart';

class ArJoystick extends StatefulWidget {
  final Function(double dx, double dy) onMove;
  final VoidCallback? onEnd;

  const ArJoystick({super.key, required this.onMove, this.onEnd});

  @override
  State<ArJoystick> createState() => _ArJoystickState();
}

class _ArJoystickState extends State<ArJoystick> {
  Offset _knobPosition = Offset.zero; // 記錄小圓點的位置

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // 計算偏移量並限制在 60 像素的圓圈內
                  _knobPosition = Offset(
                    (_knobPosition.dx + details.delta.dx).clamp(-40, 40),
                    (_knobPosition.dy + details.delta.dy).clamp(-40, 40),
                  );
                });

                // 回傳 -1.0 到 1.0 的值給父組件
                widget.onMove(_knobPosition.dx / 40, _knobPosition.dy / 40);
              },
              onPanEnd: (_) {
                setState(() {
                  _knobPosition = Offset.zero; // 放開時回到中心
                });
                if (widget.onEnd != null) widget.onEnd!();
              },
              child: Transform.translate(
                offset: _knobPosition,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
