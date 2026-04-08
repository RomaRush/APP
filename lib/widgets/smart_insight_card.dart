import 'package:flutter/material.dart';
import '../core/providers/smart_life_provider.dart';

class SmartInsightCard extends StatelessWidget {
  final SmartInsight insight;
  final VoidCallback? onDismiss;

  const SmartInsightCard({
    super.key,
    required this.insight,
    this.onDismiss,
  });

  Color _getColor() {
    switch (insight.type) {
      case InsightType.tip:
        return const Color(0xFF4CAF50); // Green
      case InsightType.warning:
        return const Color(0xFFFFC107); // Amber
      case InsightType.danger:
        return const Color(0xFFEF5350); // Red
    }
  }

  IconData _getIcon() {
    switch (insight.type) {
      case InsightType.tip:
        return Icons.lightbulb_outline;
      case InsightType.warning:
        return Icons.warning_amber_rounded;
      case InsightType.danger:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(), color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                if (insight.actionLabel != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: insight.onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        insight.actionLabel!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.5), size: 20),
            ),
        ],
      ),
    );
  }
}
