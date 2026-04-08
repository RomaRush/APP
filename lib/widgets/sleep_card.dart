import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SleepCard extends StatelessWidget {
  final List<double> weeklyData;
  final double todayHours;

  const SleepCard({
    super.key,
    this.weeklyData = const [0, 0, 0, 0, 0, 0, 0],
    this.todayHours = 0,
  });

  Color _getSleepQualityColor(double hours) {
    if (hours >= 7) return Colors.greenAccent;
    if (hours >= 5) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getSleepQualityText(double hours) {
    if (hours >= 8) return 'Отлично';
    if (hours >= 7) return 'Хорошо';
    if (hours >= 5) return 'Мало';
    return 'Критично';
  }

  @override
  Widget build(BuildContext context) {
    final qualityColor = _getSleepQualityColor(todayHours);
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B8EFF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.bedtime_rounded,
                          color: const Color(0xFF6B8EFF),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Сон',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: qualityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getSleepQualityText(todayHours),
                      style: TextStyle(
                        color: qualityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              
              // Main content
              Row(
                children: [
                  // Bar chart with day labels
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: weeklyData.asMap().entries.map((entry) {
                              final barHeight = entry.value > 0 
                                  ? (entry.value / 12) * 40 + 10 
                                  : 6.0;
                              final isToday = entry.key == weeklyData.length - 1;
                              final barColor = isToday 
                                  ? _getSleepQualityColor(entry.value)
                                  : const Color(0xFF5B7FFF).withValues(alpha: 0.4);
                              
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300 + entry.key * 50),
                                    width: 10,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: isToday ? [
                                        BoxShadow(
                                          color: barColor.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ] : null,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Day labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: days.asMap().entries.map((entry) {
                            final isToday = entry.key == days.length - 1;
                            return Text(
                              entry.value,
                              style: TextStyle(
                                color: isToday 
                                  ? Colors.white70 
                                  : Colors.white30,
                                fontSize: 9,
                                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Hours display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              todayHours.toStringAsFixed(1),
                              style: AppTheme.headlineStyle.copyWith(
                                fontSize: 28,
                                color: AppTheme.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 2),
                              child: Text(
                                'ч',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'сегодня',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
