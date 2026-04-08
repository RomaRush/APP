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
      case HealthStatus.excellent: return 'превосходно';
      case HealthStatus.good: return 'хорошо';
      case HealthStatus.normal: return 'нормально';
      case HealthStatus.bad: return 'плохо';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = customColor ?? const Color(0xFFFF9500);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ваше',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                ),
              ),
              Text(
                'состояние',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _statusText,
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.white.withValues(alpha: 0.95),
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
