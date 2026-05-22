import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/user_provider.dart';

class MentalHealthScreen extends StatefulWidget {
  const MentalHealthScreen({super.key});

  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen> {
  double _moodValue = 4.0; // 1 to 7

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Очень неприятно', 'status': 'Критично', 'color': Color(0xFF6B4D91)},
    {'label': 'Неприятно', 'status': 'Плохо', 'color': Color(0xFF5D7BD5)},
    {'label': 'Немного неприятно', 'status': 'Стресс', 'color': Color(0xFF76AEC1)},
    {'label': 'Нейтрально', 'status': 'Нормально', 'color': Color(0xFF90B59B)},
    {'label': 'Немного приятно', 'status': 'Хорошо', 'color': Color(0xFFD4C881)},
    {'label': 'Приятно', 'status': 'Очень хорошо', 'color': Color(0xFFD99A6C)},
    {'label': 'Очень приятно', 'status': 'Превосходно', 'color': Color(0xFFEBB25D)},
  ];

  Map<String, dynamic> get _currentMood => _moods[(_moodValue.round() - 1).clamp(0, 6)];

  void _submit() {
    if (mounted) {
      context.read<UserProvider>().completeDailyTask('mood');
    }
    Navigator.pop(context, {
      'status': _currentMood['status'],
      'color': _currentMood['color'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final mood = _currentMood;
    final color = mood['color'] as Color;

    return Scaffold(
      body: AnimatedContainer(
        duration: 600.ms,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.4),
              AppTheme.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Ваше самочувствие',
                      style: AppTheme.titleStyle.copyWith(fontSize: 17, color: Colors.white),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Spacer(),
              
              // Animated Mood Shape
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 100,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    // Abstract shape (represented by an animated icon/container)
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          _getMoodIcon(_moodValue.round()),
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ).animate(key: ValueKey(_moodValue.round()))
                     .scale(duration: 400.ms, curve: Curves.easeOutBack)
                     .fadeIn(),
                  ],
                ),
              ),
              
              const SizedBox(height: 60),
              
              Text(
                mood['label'],
                style: AppTheme.headlineStyle.copyWith(fontSize: 28, color: Colors.white),
              ).animate(key: ValueKey(_moodValue.round())).fadeIn().slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 8),
              Text(
                'в целом за день',
                style: AppTheme.captionStyle.copyWith(color: Colors.white70),
              ),
              
              const Spacer(),
              
              // Apple-style Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 12,
                        activeTrackColor: Colors.white24,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withValues(alpha: 0.1),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 14,
                          elevation: 4,
                        ),
                        trackShape: const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        value: _moodValue,
                        min: 1,
                        max: 7,
                        divisions: 6,
                        onChanged: (val) => setState(() => _moodValue = val),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Неприятно', style: AppTheme.captionStyle.copyWith(fontSize: 11, color: Colors.white54)),
                          Text('Приятно', style: AppTheme.captionStyle.copyWith(fontSize: 11, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Done Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text(
                      'Готово',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMoodIcon(int value) {
    if (value <= 2) return Icons.sentiment_very_dissatisfied_rounded;
    if (value <= 3) return Icons.sentiment_dissatisfied_rounded;
    if (value <= 4) return Icons.sentiment_neutral_rounded;
    if (value <= 5) return Icons.sentiment_satisfied_rounded;
    if (value <= 6) return Icons.sentiment_satisfied_alt_rounded;
    return Icons.sentiment_very_satisfied_rounded;
  }
}
