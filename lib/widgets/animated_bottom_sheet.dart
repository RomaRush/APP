import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';

class AnimatedBottomSheet extends StatelessWidget {
  final Widget child;
  final double height;

  const AnimatedBottomSheet({
    super.key,
    required this.child,
    this.height = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * height + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: AppTheme.bottomSheetRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 32, 
          right: 32, 
          top: 40, 
          bottom: bottomPadding + 20,
        ),
        child: child,
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    ).fadeIn(duration: 300.ms);
  }
}
