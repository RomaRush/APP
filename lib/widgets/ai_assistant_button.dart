import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import 'ai_chat_sheet.dart';

class AiAssistantButton extends StatefulWidget {
  final VoidCallback? onTap;

  const AiAssistantButton({
    super.key,
    this.onTap,
  });

  @override
  State<AiAssistantButton> createState() => _AiAssistantButtonState();
}

class _AiAssistantButtonState extends State<AiAssistantButton> {
  bool _isPressed = false;

  void _openChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIChatSheet(),
    );
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _openChatSheet();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: 3,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.primaryDark,
              size: 32,
            ),
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.02, 1.02),
      duration: 2500.ms,
      curve: Curves.easeInOut,
    );
  }
}
