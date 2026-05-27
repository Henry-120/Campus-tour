import 'package:flutter/material.dart';

import '../../styles/app_theme.dart';

class LoginTextField extends StatefulWidget {
  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPasswordField = false,
    this.validator,
    this.keyboardType,
    this.height = 50,
    this.fontSize = 16,
    this.hintFontSize = 14,
    this.iconSize = 22,
    this.radius = 12,
    this.verticalPadding = 0,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPasswordField;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final double height;
  final double fontSize;
  final double hintFontSize;
  final double iconSize;
  final double radius;
  final double verticalPadding;

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  late bool _obscureText;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPasswordField;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldGlow = _isFocused;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppTheme.loginPanelColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: shouldGlow
              ? AppTheme.loginGlowColor
              : AppTheme.loginPanelBorderColor,
          width: shouldGlow ? 2.5 : 2,
        ),
        boxShadow: shouldGlow
            ? [
                BoxShadow(
                  color: AppTheme.loginGlowColor.withValues(alpha: 0.7),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  offset: const Offset(0, 3),
                  blurRadius: 4,
                ),
              ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: _obscureText,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        style: AppTheme.loginInputStyle(widget.fontSize),
        strutStyle: StrutStyle(
          fontSize: widget.fontSize,
          height: 1.15,
          forceStrutHeight: true,
        ),
        cursorColor: AppTheme.loginGlowColor,
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.icon,
            size: widget.iconSize,
            color: shouldGlow
                ? AppTheme.loginGlowColor
                : AppTheme.loginIconColor,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: widget.height * 0.92,
            minHeight: widget.height,
          ),
          suffixIcon: widget.isPasswordField
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: AppTheme.loginIconColor,
                    size: widget.iconSize * 0.9,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          suffixIconConstraints: BoxConstraints(
            minWidth: widget.height * 0.92,
            minHeight: widget.height,
          ),
          hintText: widget.hintText,
          hintStyle: AppTheme.loginHintStyle(widget.hintFontSize),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: widget.verticalPadding,
          ),
          errorStyle: AppTheme.zeroErrorStyle,
        ),
      ),
    );
  }
}
