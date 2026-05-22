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
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF161618).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _IslandIcon(icon: Icons.grid_view_rounded, onTap: onHomeTap, isActive: true),
              const SizedBox(width: 16),
              _IslandIcon(icon: Icons.add_rounded, onTap: onAddTap, isPrimary: true),
              const SizedBox(width: 16),
              _IslandIcon(icon: Icons.analytics_rounded, onTap: onStatsTap),
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
        width: isPrimary ? 52 : 48,
        height: isPrimary ? 52 : 48,
        decoration: isPrimary ? BoxDecoration(
          color: AppTheme.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.25),
              blurRadius: 15,
            ),
          ],
        ) : null,
        child: Center(
          child: Icon(
            icon,
            color: isPrimary ? Colors.black : (isActive ? AppTheme.white : AppTheme.white38),
            size: isPrimary ? 28 : 24,
          ),
        ),
      ),
    );
  }
}
