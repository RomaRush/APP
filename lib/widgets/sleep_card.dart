import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/minimal_card.dart';

class SleepCard extends StatelessWidget {
  final List<double> weeklyData;
  final double todayHours;

  const SleepCard({
    super.key,
    this.weeklyData = const [0, 0, 0, 0, 0, 0, 0],
    this.todayHours = 0,
  });

  Color _qualityColor(double h) {
    if (h >= 7) return AppTheme.accentGreen;
    if (h >= 5) return AppTheme.accentGold;
    return AppTheme.errorRed;
  }

  String _qualityLabel(double h) {
    if (h >= 8) return 'Отлично';
    if (h >= 7) return 'Хорошо';
    if (h >= 5) return 'Мало';
    return 'Критично';
  }

  @override
  Widget build(BuildContext context) {
    final color = _qualityColor(todayHours);
    final maxVal = weeklyData.reduce((a, b) => a > b ? a : b).clamp(1.0, 12.0);
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return MinimalCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentIndigo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.bedtime_rounded, color: AppTheme.accentIndigo, size: 16),
              ),
              const SizedBox(width: 10),
              Text('Сон', style: AppTheme.titleStyle.copyWith(fontSize: 15)),
              const Spacer(),
              // Quality badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _qualityLabel(todayHours),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart + stat
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bar chart
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weeklyData.asMap().entries.map((e) {
                      final isToday = e.key == weeklyData.length - 1;
                      final barH = ((e.value / maxVal) * 52).clamp(4.0, 52.0);
                      final barColor = isToday
                          ? color
                          : AppTheme.white.withValues(alpha: 0.1);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isToday)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(bottom: 3),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            width: isToday ? 10 : 8,
                            height: barH,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            days[e.key],
                            style: AppTheme.captionStyle.copyWith(
                              fontSize: 9,
                              color: isToday ? AppTheme.white70 : AppTheme.white38,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Today stat pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: todayHours.toStringAsFixed(1),
                            style: AppTheme.headlineStyle.copyWith(
                              fontSize: 26,
                              color: color,
                            ),
                          ),
                          TextSpan(
                            text: ' ч',
                            style: AppTheme.captionStyle.copyWith(color: color),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'сегодня',
                      style: AppTheme.captionStyle.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
