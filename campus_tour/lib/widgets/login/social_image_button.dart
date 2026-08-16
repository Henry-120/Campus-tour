import 'package:flutter/material.dart';

class SocialImageButton extends StatefulWidget {
  const SocialImageButton({
    super.key,
    required this.imagePath,
    required this.onTap,
    required this.semanticsLabel,
    this.size = 92,
    this.disabled = false,
  });

  final String imagePath;
  final VoidCallback onTap;
  final String semanticsLabel;
  final double size;
  final bool disabled;

  @override
  State<SocialImageButton> createState() => _SocialImageButtonState();
}

class _SocialImageButtonState extends State<SocialImageButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (widget.disabled) return;

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !widget.disabled,
      label: widget.semanticsLabel,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.disabled ? null : widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: widget.disabled ? 0.55 : 1.0,
            duration: const Duration(milliseconds: 130),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
