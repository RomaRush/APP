import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum HealthStatus { excellent, good, normal, bad }

class StatusCard extends StatelessWidget {
  final HealthStatus status;
  final String? customText;
  final Color? customColor;

  const StatusCard({
    super.key,
    this.status = HealthStatus.normal,
    this.customText,
    this.customColor,
  });

  String get _statusText {
    if (customText != null) return customText!;
    switch (status) {
      case HealthStatus.excellent: return 'Превосходно';
      case HealthStatus.good:      return 'Хорошо';
      case HealthStatus.normal:    return 'Нормально';
      case HealthStatus.bad:       return 'Нужен отдых';
    }
  }

  IconData get _icon {
    switch (status) {
      case HealthStatus.excellent: return Icons.sentiment_very_satisfied_rounded;
      case HealthStatus.good:      return Icons.sentiment_satisfied_rounded;
      case HealthStatus.normal:    return Icons.sentiment_neutral_rounded;
      case HealthStatus.bad:       return Icons.sentiment_dissatisfied_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = customColor ?? const Color(0xFFFF9500);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: cardColor.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Состояние',
                style: AppTheme.labelStyle.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusText,
                style: AppTheme.titleStyle.copyWith(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _icon,
                    color: Colors.white.withValues(alpha: 0.95),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
