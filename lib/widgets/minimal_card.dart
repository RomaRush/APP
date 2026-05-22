import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Universal glass-morphism card used across the entire app.
/// Supports optional gradient border, glow, and fully custom sizing.
class MinimalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final double? blur;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? shadow;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const MinimalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.blur,
    this.borderRadius,
    this.border,
    this.shadow,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 24.0;
    final br = BorderRadius.circular(radius);

    Widget card = ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur ?? 16, sigmaY: blur ?? 16),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppTheme.cardPadding),
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? AppTheme.white08) : null,
            gradient: gradient,
            borderRadius: br,
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.09),
                  width: 0.8,
                ),
          ),
          child: child,
        ),
      ),
    );

    if (shadow != null || AppTheme.softShadow.isNotEmpty) {
      card = Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: br,
          boxShadow: shadow ?? AppTheme.softShadow,
        ),
        child: card,
      );
    } else if (margin != null) {
      card = Container(margin: margin, child: card);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}

/// Slim divider used inside MinimalCard sections
class CardDivider extends StatelessWidget {
  const CardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.6,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}

/// Icon container pill used for section headers
class CardIconPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const CardIconPill({
    super.key,
    required this.icon,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
