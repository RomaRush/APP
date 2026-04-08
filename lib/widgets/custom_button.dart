import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';

/// Outlined button with animation
class DayloOutlinedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const DayloOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 56,
  });

  @override
  State<DayloOutlinedButton> createState() => _DayloOutlinedButtonState();
}

class _DayloOutlinedButtonState extends State<DayloOutlinedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isPressed ? AppTheme.mediumGray : Colors.transparent,
            borderRadius: AppTheme.buttonRadius,
            border: Border.all(
              color: AppTheme.black,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: AppTheme.buttonTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Filled black button with animation
class DayloFilledButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const DayloFilledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 56,
  });

  @override
  State<DayloFilledButton> createState() => _DayloFilledButtonState();
}

class _DayloFilledButtonState extends State<DayloFilledButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isPressed ? AppTheme.darkGray : AppTheme.black,
            borderRadius: AppTheme.buttonRadius,
          ),
          child: Center(
            child: Text(
              widget.text,
              style: AppTheme.buttonTextStyleWhite,
            ),
          ),
        ),
      ),
    );
  }
}

/// Light outlined button for welcome screen
class DayloLightButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const DayloLightButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 56,
  });

  @override
  State<DayloLightButton> createState() => _DayloLightButtonState();
}

class _DayloLightButtonState extends State<DayloLightButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isPressed 
                ? AppTheme.lightGray.withValues(alpha: 0.9)
                : AppTheme.lightGray.withValues(alpha: 0.85),
            borderRadius: AppTheme.buttonRadius,
          ),
          child: Center(
            child: Text(
              widget.text,
              style: AppTheme.buttonTextStyle.copyWith(
                letterSpacing: 2,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }
}
