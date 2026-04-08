import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppIsland extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onAddTap;
  final VoidCallback onStatsTap;

  const AppIsland({
    super.key,
    required this.onHomeTap,
    required this.onAddTap,
    required this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _IslandIcon(icon: Icons.grid_view_rounded, onTap: onHomeTap, isActive: true),
              const SizedBox(width: 24),
              _IslandIcon(icon: Icons.add_circle_rounded, onTap: onAddTap, isPrimary: true),
              const SizedBox(width: 24),
              _IslandIcon(icon: Icons.bar_chart_rounded, onTap: onStatsTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _IslandIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool isPrimary;

  const _IslandIcon({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: isPrimary ? BoxDecoration(
          color: AppTheme.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ) : null,
        child: Icon(
          icon,
          color: isPrimary ? AppTheme.black : (isActive ? AppTheme.white : AppTheme.darkGray),
          size: isPrimary ? 28 : 26,
        ),
      ),
    );
  }
}
