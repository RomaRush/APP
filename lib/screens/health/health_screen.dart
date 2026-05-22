import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/minimal_card.dart';
import 'mental_health_screen.dart';
import 'breathing_screen.dart';
import '../../core/providers/nutrition_provider.dart';
import 'package:intl/intl.dart';
import '../home/article_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

void _showBlockInfo(BuildContext context, String title, String text) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF13131F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.accentBlue),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTheme.titleStyle)),
        ],
      ),
      content: Text(text, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Понятно', style: AppTheme.titleStyle.copyWith(color: AppTheme.accentBlue)),
        ),
      ],
    ),
  );
}

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().fetchHealthData();
    });
  }

  void _measureMentalHealth(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MentalHealthScreen()),
    );
    if (result != null && result is Map) {
      if (context.mounted) {
        context.read<HealthProvider>().updateMentalHealth(result['status'], result['color']);
        context.read<UserProvider>().completeDailyTask('mood');
      }
    }
  }

  void _showSleepEditor(BuildContext context) {
    TimeOfDay startTime = const TimeOfDay(hour: 23, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 7, minute: 0);
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        DateTime tempStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute);
        DateTime tempEnd = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute);
        if (tempEnd.isBefore(tempStart)) tempEnd = tempEnd.add(const Duration(days: 1));

        return StatefulBuilder(
          builder: (context, setStateSheet) => Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: const BoxDecoration(
              color: Color(0xFF13131F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(color: AppTheme.white12, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Text('Запись сна', style: AppTheme.titleStyle.copyWith(fontSize: 20)),
                const SizedBox(height: 24),
                
                // Date
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setStateSheet(() => selectedDate = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white05,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppTheme.accentIndigo, size: 20),
                        const SizedBox(width: 12),
                        Text('Дата', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
                        const Spacer(),
                        Text(DateFormat('dd.MM.yyyy').format(selectedDate), style: AppTheme.bodyStyle.copyWith(color: AppTheme.white54)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Time Selection (Apple Style)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ОТБОЙ', style: AppTheme.labelStyle.copyWith(fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: CupertinoTheme(
                              data: const CupertinoThemeData(
                                brightness: Brightness.dark,
                                textTheme: CupertinoTextThemeData(
                                  dateTimePickerTextStyle: TextStyle(color: AppTheme.white, fontSize: 18),
                                ),
                              ),
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                use24hFormat: true,
                                initialDateTime: tempStart,
                                onDateTimeChanged: (d) {
                                  setStateSheet(() => tempStart = d);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 80, color: AppTheme.white05),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ПОДЪЕМ', style: AppTheme.labelStyle.copyWith(fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: CupertinoTheme(
                              data: const CupertinoThemeData(
                                brightness: Brightness.dark,
                                textTheme: CupertinoTextThemeData(
                                  dateTimePickerTextStyle: TextStyle(color: AppTheme.white, fontSize: 18),
                                ),
                              ),
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                use24hFormat: true,
                                initialDateTime: tempEnd,
                                onDateTimeChanged: (d) {
                                  setStateSheet(() => tempEnd = d);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentIndigo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      context.read<HealthProvider>().setSleepTimes(tempStart, tempEnd, date: selectedDate);
                      context.read<UserProvider>().completeDailyTask('note');
                      Navigator.pop(ctx);
                    },
                    child: Text('Сохранить', style: AppTheme.buttonTextStyleWhite),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openArticle(BuildContext context, String title, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(
          title: title,
          headerImage: imagePath,
          blocks: const [], // Content would be populated as before
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Wallpaper
          Positioned.fill(
            child: Consumer<UserProvider>(
              builder: (context, user, _) {
                return Image.asset(
                  user.wallpaperPath,
                  fit: BoxFit.cover,
                );
              }
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.1),
                    AppTheme.primaryDark,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Consumer<HealthProvider>(
              builder: (context, health, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text('Здоровье', style: AppTheme.headlineStyle)
                          .animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 32),
                      
                      // Steps & Calories Row
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Шаги',
                              value: health.isAuthorized ? '${health.steps}' : 'Подкл.',
                              icon: Icons.directions_walk_rounded,
                              color: AppTheme.accentGold,
                              goal: 10000,
                              current: health.steps.toDouble(),
                              infoTitle: 'Почему важны шаги?',
                              infoText: 'Ежедневная ходьба улучшает кровообращение, поддерживает тонус мышц и укрепляет сердечно-сосудистую систему. Помогает сжигать калории и повышает настроение.',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Ккал',
                              value: health.isAuthorized ? '${health.calories.toInt()}' : '-',
                              icon: Icons.local_fire_department_rounded,
                              color: AppTheme.errorRed,
                              goal: 2500,
                              current: health.calories,
                              infoTitle: 'Зачем считать калории?',
                              infoText: 'Поддержание баланса калорий помогает контролировать вес. Понимание того, сколько энергии вы тратите, позволяет более осознанно подходить к питанию и тренировкам.',
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 20),
                      
                      MinimalCard(
                        padding: EdgeInsets.zero,
                        onTap: () => _showSleepEditor(context),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  CardIconPill(icon: Icons.bedtime_rounded, color: AppTheme.accentIndigo),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Сон', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${health.sleepHours.toStringAsFixed(1)} ч сегодня',
                                        style: AppTheme.captionStyle,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.info_outline_rounded, color: AppTheme.white38, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _showBlockInfo(
                                      context,
                                      'Влияние сна',
                                      'Здоровый сон восстанавливает нервную систему, улучшает память, повышает иммунитет и дает энергию на весь день. Старайтесь спать от 7 до 9 часов для максимальной продуктивности.'
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentIndigo, size: 24),
                                ],
                              ),
                            ),
                            if (health.sleepHistory.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: _SleepGraph(history: health.sleepHistory),
                              ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 20),
                      const WaterTracker()
                          .animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 20),

                      // ── Heart Rate Card (Removed per user request) ──
                      
                      const SizedBox(height: 20),
                      
                      // Mental Health Card
                      MinimalCard(
                        color: health.mentalColor.withValues(alpha: 0.08),
                        border: Border.all(color: health.mentalColor.withValues(alpha: 0.2)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.psychology_rounded, color: health.mentalColor, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Настроение', style: AppTheme.titleStyle.copyWith(fontSize: 15)),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _showBlockInfo(
                                        context,
                                        'Эмоциональное здоровье',
                                        'Отслеживание настроения помогает выявить паттерны ваших эмоций. Регулярная саморефлексия снижает уровень стресса, предотвращает выгорание и помогает сохранять позитивный настрой.'
                                      ),
                                      child: Icon(Icons.info_outline_rounded, color: health.mentalColor.withValues(alpha: 0.5), size: 18),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: health.mentalColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    health.mentalStatus.toUpperCase(),
                                    style: TextStyle(
                                      color: health.mentalColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              health.mentalStatus,
                              style: AppTheme.headlineStyle.copyWith(fontSize: 32),
                              textAlign: TextAlign.center,
                            ),
                            // Mood history strip (last 7)
                            if (health.recentMoodHistory.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: health.recentMoodHistory.map((m) {
                                  final color = m['color'] as Color;
                                  final status = m['status'] as String;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Tooltip(
                                      message: status,
                                      child: Container(
                                        width: 28, height: 28,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: color.withValues(alpha: 0.5)),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 12, height: 12,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => _measureMentalHealth(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.white.withValues(alpha: 0.1),
                                  foregroundColor: AppTheme.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('Как вы себя чувствуете?', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 20),
                      
                      // Vitamins Card (New feature)
                      _VitaminsCard()
                          .animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.1, end: 0),
                          
                      const SizedBox(height: 20),
                      
                      // Breathing Practice
                      MinimalCard(
                        padding: EdgeInsets.zero,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BreathingScreen())),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CardIconPill(icon: Icons.air_rounded, color: AppTheme.accentBlue),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Дыхание', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text('Практика 2 минуты', style: AppTheme.captionStyle),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.info_outline_rounded, color: AppTheme.white38, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _showBlockInfo(
                                    context,
                                    'Дыхательные практики',
                                    'Глубокое дыхание активирует парасимпатическую нервную систему, замедляя сердцебиение и снижая уровень кортизола (гормона стресса). Даже пара минут дыхания очищает разум и помогает сфокусироваться.'
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.play_arrow_rounded, color: AppTheme.white38),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 32),
                      Text('База знаний', style: AppTheme.titleStyle)
                          .animate().fadeIn(duration: 600.ms, delay: 700.ms),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        height: 200,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _TipCard(
                              title: 'Сахарные качели: как избежать усталости',
                              imagePath: 'assets/images/health_nutrition.png',
                              category: 'Питание',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleScreen(
                                    title: "Сахарные качели",
                                    headerImage: 'assets/images/health_nutrition.png',
                                    blocks: [
                                      ArticleBlock(
                                        type: ArticleContentType.text,
                                        content: "Вы когда-нибудь чувствовали резкую сонливость через час после обеда? Это и есть результат 'сахарных качелей'. Когда мы едим простые углеводы, уровень сахара в крови резко растет, поджелудочная выбрасывает инсулин, и сахар так же резко падает ниже нормы.",
                                      ),
                                      ArticleBlock(
                                        type: ArticleContentType.image,
                                        content: 'assets/images/health_nutrition.png',
                                      ),
                                      ArticleBlock(
                                        type: ArticleContentType.text,
                                        title: "Как этого избежать?",
                                        content: "1. Добавляйте клетчатку (овощи) в каждый прием пищи.\n2. Начинайте прием пищи с белков и жиров, а углеводы оставляйте на конец.\n3. Выбирайте сложные углеводы с низким гликемическим индексом.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _TipCard(
                              title: 'Кофе и аденозин: почему кофе не бодрит',
                              imagePath: 'assets/images/health_sleep.png',
                              category: 'Сон',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleScreen(
                                    title: "Кофе и сон",
                                    headerImage: 'assets/images/health_sleep.png',
                                    blocks: [
                                      ArticleBlock(
                                        type: ArticleContentType.text,
                                        content: "Кофеин на самом деле не дает вам энергию. Он лишь 'обманывает' ваш мозг. В течение дня в мозгу накапливается аденозин — молекула усталости. Кофеин блокирует рецепторы аденозина, поэтому вы не чувствуете, как устали.",
                                      ),
                                      ArticleBlock(
                                        type: ArticleContentType.recipeStep,
                                        title: "Почему наступает откат?",
                                        content: "Когда действие кофеина проходит, весь накопленный аденозин разом обрушивается на рецепторы. Это вызывает резкое чувство разбитости.",
                                      ),
                                      ArticleBlock(
                                        type: ArticleContentType.text,
                                        title: "Совет",
                                        content: "Попробуйте подождать 90 минут после пробуждения перед первой чашкой кофе. Это позволит аденозину естественным образом очиститься, и вы избежите дневного провала энергии.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
                      
                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



class _SleepGraph extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const _SleepGraph({required this.history});

  @override
  Widget build(BuildContext context) {
    // Generate dates for the current week (Monday to Sunday)
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    final weekDays = List.generate(7, (index) {
      return DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day).add(Duration(days: index));
    });

    final displayHistory = weekDays.map((date) {
      // Find entry for this date (ignoring time)
      final entry = history.firstWhere(
        (h) {
          final hDate = h['date'] as DateTime;
          return hDate.year == date.year && hDate.month == date.month && hDate.day == date.day;
        },
        orElse: () => {'date': date, 'hours': 0.0},
      );
      return entry;
    }).toList();

    final maxHours = displayHistory.fold<double>(8.0, (max, h) => (h['hours'] as double) > max ? h['hours'] as double : max);

    return Column(
      children: [
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: displayHistory.map((h) {
              final hours = h['hours'] as double;
              final heightFactor = hours / maxHours;
              final date = h['date'] as DateTime;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 60 * heightFactor,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.accentIndigo, AppTheme.accentIndigo.withValues(alpha: 0.5)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: (displayHistory.indexOf(h) * 50).ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('E', 'ru').format(date).substring(0, 1),
                        style: AppTheme.labelStyle.copyWith(
                          fontSize: 10, 
                          color: date.day == now.day && date.month == now.month ? AppTheme.accentIndigo : AppTheme.white38,
                          fontWeight: date.day == now.day && date.month == now.month ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double goal;
  final double current;
  final String infoTitle;
  final String infoText;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.goal,
    required this.current,
    required this.infoTitle,
    required this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    
    return MinimalCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: AppTheme.captionStyle.copyWith(color: AppTheme.white70)),
              const Spacer(),
              GestureDetector(
                onTap: () => _showBlockInfo(context, infoTitle, infoText),
                child: const Icon(Icons.info_outline_rounded, color: AppTheme.white38, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTheme.headlineStyle.copyWith(fontSize: 26, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          // Progress bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    height: 4,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class WaterTracker extends StatelessWidget {
  const WaterTracker({super.key});

  Color _getDrinkColor(DrinkType type) {
    switch (type) {
      case DrinkType.water: return AppTheme.accentBlue;
      case DrinkType.coffee: return const Color(0xFF8B4513); // Brown
      case DrinkType.tea: return const Color(0xFF2E8B57);    // Green
      case DrinkType.juice: return const Color(0xFFFFA500);  // Orange
      case DrinkType.soda: return const Color(0xFF800080);   // Purple
      case DrinkType.other: return AppTheme.accentIndigo;
      default: return AppTheme.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, nutrition, _) {
        final totalMl = nutrition.waterMl;
        final goalMl = nutrition.waterGoalMl;
        final progress = (totalMl / goalMl).clamp(0.0, 1.0);

        return MinimalCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CardIconPill(
                        icon: Icons.water_drop_rounded,
                        color: nutrition.todaysDrinks.isEmpty 
                            ? AppTheme.accentBlue 
                            : _getDrinkColor(nutrition.todaysDrinks.last.type)
                      ),
                      const SizedBox(width: 12),
                      Text('Водный баланс', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showBlockInfo(
                          context,
                          'Зачем пить воду?',
                          'Вода критически важна для всех процессов в организме: она доставляет питательные вещества, улучшает работу мозга, помогает контролировать вес и выводит токсины. Достаточная гидратация - ключ к высокому уровню энергии!'
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: AppTheme.white38, size: 18),
                      ),
                    ],
                  ),
                  // Drink list
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _DrinkChip(
                    icon: Icons.water_drop_rounded, 
                    color: AppTheme.accentBlue, 
                    label: "Вода (250мл)",
                    onTap: () {
                      nutrition.addDrink(DrinkType.water, 250);
                      context.read<UserProvider>().completeDailyTask('water');
                    }
                  ),
                  const SizedBox(width: 8),
                  _DrinkChip(
                    icon: Icons.remove_rounded, 
                    color: AppTheme.white38, 
                    label: "Удалить",
                    onTap: () => nutrition.removeLastDrink()
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Segmented Progress Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: AppTheme.white05,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          children: [
                            ...nutrition.todaysDrinks.map((drink) {
                              final factor = drink.amountMl / goalMl;
                              // Ensure we don't exceed the bar width
                              return Container(
                                width: constraints.maxWidth * factor,
                                color: _getDrinkColor(drink.type),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(progress * 100).toInt()}% от цели', style: AppTheme.captionStyle),
                          Text('$totalMl / $goalMl мл', style: AppTheme.captionStyle.copyWith(color: AppTheme.white70, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  );
                }
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrinkChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _DrinkChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.labelStyle.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Heart Rate Card ────────────────────────────────────────────────────────────

class _HeartRateCard extends StatefulWidget {
  const _HeartRateCard();

  @override
  State<_HeartRateCard> createState() => _HeartRateCardState();
}

class _HeartRateCardState extends State<_HeartRateCard> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addReading(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF13131F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: AppTheme.white12, borderRadius: BorderRadius.circular(2))),
              ),
              Text('Ввести пульс', style: AppTheme.titleStyle),
              const SizedBox(height: 8),
              Text('Измерьте пульс и введите значение', style: AppTheme.captionStyle),
              const SizedBox(height: 20),
              TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: AppTheme.headlineStyle.copyWith(fontSize: 42, letterSpacing: -1),
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '72',
                  hintStyle: AppTheme.headlineStyle.copyWith(fontSize: 42, color: AppTheme.white12, letterSpacing: -1),
                  suffixText: 'уд/мин',
                  suffixStyle: AppTheme.captionStyle,
                  filled: true,
                  fillColor: AppTheme.white08,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final bpm = int.tryParse(_ctrl.text);
                    if (bpm != null && bpm > 30 && bpm < 250) {
                      context.read<HealthProvider>().addHeartRate(bpm);
                      _ctrl.clear();
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (_, health, __) {
        final bpm = health.latestHeartRate;
        final zone = health.heartRateZone;
        final zoneColor = health.heartRateZoneColor;
        final history = health.heartRateHistory;

        return MinimalCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF5350).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Color(0xFFEF5350), size: 18),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Пульс', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                        if (bpm != null)
                          Text(zone, style: AppTheme.captionStyle.copyWith(color: zoneColor, fontSize: 11)),
                      ],
                    ),
                    const Spacer(),
                    if (bpm != null) ...[
                      Text('$bpm', style: AppTheme.headlineStyle.copyWith(
                        fontSize: 36, color: zoneColor, letterSpacing: -2)),
                      const SizedBox(width: 4),
                      Text('уд/мин', style: AppTheme.captionStyle.copyWith(fontSize: 10)),
                    ],
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _addReading(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded, color: Color(0xFFEF5350), size: 18),
                      ),
                    ),
                  ],
                ),
                if (bpm == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Нажмите + чтобы ввести пульс',
                      style: AppTheme.captionStyle.copyWith(color: AppTheme.white38),
                    ),
                  ),
                if (history.length >= 2) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: _HeartRateMiniChart(
                      entries: history.reversed.take(12).toList().reversed.toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeartRateMiniChart extends StatelessWidget {
  final List<HeartRateEntry> entries;
  const _HeartRateMiniChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _HeartRateLinePainter(entries: entries));
  }
}

class _HeartRateLinePainter extends CustomPainter {
  final List<HeartRateEntry> entries;
  _HeartRateLinePainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;
    final bpms = entries.map((e) => e.bpm.toDouble()).toList();
    final minV = bpms.reduce((a, b) => a < b ? a : b) - 5;
    final maxV = bpms.reduce((a, b) => a > b ? a : b) + 5;
    final range = maxV - minV;
    if (range == 0) return;

    final pts = <Offset>[];
    for (int i = 0; i < bpms.length; i++) {
      final x = i / (bpms.length - 1) * size.width;
      final y = size.height - (bpms[i] - minV) / range * size.height;
      pts.add(Offset(x, y));
    }

    final paint = Paint()
      ..color = const Color(0xFFEF5350)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.lineTo(pts.first.dx, size.height);
    fillPath.close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFEF5350).withValues(alpha: 0.25), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
    canvas.drawCircle(pts.last, 4,
      Paint()..color = const Color(0xFFEF5350)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_HeartRateLinePainter oldDelegate) => oldDelegate.entries != entries;
}

// ── Mood emoji helper ──────────────────────────────────────────────────────────

String _moodEmoji(String status) {
  final s = status.toLowerCase();
  if (s.contains('отлично') || s.contains('прекрасно')) return '😄';
  if (s.contains('хорошо') || s.contains('нормально')) return '🙂';
  if (s.contains('устал') || s.contains('нейтраль')) return '😐';
  if (s.contains('плохо') || s.contains('грустн')) return '😔';
  if (s.contains('ужасно') || s.contains('стресс')) return '😟';
  return '😶';
}

class _TipCard extends StatelessWidget {
  final String title;
  final String category;
  final String imagePath;
  final VoidCallback onTap;
  
  const _TipCard({
    required this.title,
    required this.category,
    required this.imagePath,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentIndigo.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTheme.titleStyle.copyWith(fontSize: 14, color: Colors.white, height: 1.3),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _VitaminsCard extends StatefulWidget {
  const _VitaminsCard();

  @override
  State<_VitaminsCard> createState() => _VitaminsCardState();
}

class _VitaminsCardState extends State<_VitaminsCard> {
  List<Map<String, dynamic>> _pills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPills();
  }

  Future<void> _loadPills() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString('user_vitamins');
    if (jsonStr != null) {
      final List<dynamic> decoded = json.decode(jsonStr);
      _pills = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _pills = [
        {'name': 'Витамин D3', 'time': 'Утро', 'taken': false},
        {'name': 'Омега-3', 'time': 'Обед', 'taken': false},
      ];
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _savePills() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_vitamins', json.encode(_pills));
  }

  void _addPillDialog() {
    final nameCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    TimeOfDay? reminderTime;
    bool enableReminder = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF13131F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Новый витамин', style: AppTheme.titleStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: AppTheme.bodyStyle,
                decoration: InputDecoration(
                  hintText: 'Название (Омега-3)', 
                  hintStyle: AppTheme.captionStyle,
                  filled: true,
                  fillColor: AppTheme.white05,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                style: AppTheme.bodyStyle,
                decoration: InputDecoration(
                  hintText: 'Период (Утро/Вечер)', 
                  hintStyle: AppTheme.captionStyle,
                  filled: true,
                  fillColor: AppTheme.white05,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: enableReminder,
                    activeColor: AppTheme.accentGold,
                    onChanged: (v) {
                      setDialogState(() => enableReminder = v);
                    },
                  ),
                  const SizedBox(width: 8),
                  Text('Напоминание', style: AppTheme.bodyStyle),
                ],
              ),
              if (enableReminder)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(reminderTime == null ? 'Выбрать время' : '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.access_time_rounded, color: AppTheme.accentGold),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t != null) {
                      setDialogState(() => reminderTime = t);
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Отмена', style: AppTheme.captionStyle),
            ),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    _pills.add({
                      'name': nameCtrl.text,
                      'time': timeCtrl.text.isEmpty ? 'По расписанию' : timeCtrl.text,
                      'reminder_hour': reminderTime?.hour,
                      'reminder_minute': reminderTime?.minute,
                      'taken': false,
                    });
                  });
                  _savePills();
                  if (enableReminder && reminderTime != null) {
                    final now = DateTime.now();
                    var scheduled = DateTime(now.year, now.month, now.day, reminderTime!.hour, reminderTime!.minute);
                    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
                    
                    NotificationService().scheduleDailyNotification(
                      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                      title: 'Время принимать витамины!',
                      body: nameCtrl.text,
                      scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
                    );
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text('Добавить', style: AppTheme.titleStyle.copyWith(color: AppTheme.accentGold)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTime(String time) {
    final t = time.toLowerCase();
    if (t.contains('утро')) return Icons.brightness_5_rounded;
    if (t.contains('вечер') || t.contains('ночь')) return Icons.nights_stay_rounded;
    if (t.contains('обед') || t.contains('день')) return Icons.wb_sunny_rounded;
    return Icons.medication_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox();

    return MinimalCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CardIconPill(icon: Icons.medication_rounded, color: AppTheme.accentGold),
                const SizedBox(width: 16),
                Text('Витамины', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showBlockInfo(
                    context,
                    'Прием витаминов',
                    'Регулярный прием витаминов помогает восполнять дефицит нутриентов, укрепляет иммунитет и улучшает общее самочувствие. Отмечайте прием, чтобы ничего не забыть!'
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppTheme.white38, size: 18),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _addPillDialog,
                  child: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentGold, size: 24),
                ),
              ],
            ),
          ),
          if (_pills.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Нет добавленных витаминов', style: AppTheme.captionStyle),
            ),
          ..._pills.asMap().entries.map((entry) {
            final idx = entry.key;
            final pill = entry.value;
            final isTaken = pill['taken'] as bool;
            
            return Dismissible(
              key: ValueKey('${pill['name']}_$idx'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: AppTheme.errorRed.withValues(alpha: 0.8),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
              ),
              onDismissed: (_) {
                setState(() {
                  _pills.removeAt(idx);
                });
                _savePills();
              },
              child: InkWell(
                onTap: () {
                  setState(() {
                    pill['taken'] = !isTaken;
                  });
                  _savePills();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.white05,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getIconForTime(pill['time'] as String), size: 18, color: AppTheme.white54),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pill['name'] as String,
                              style: AppTheme.bodyStyle.copyWith(
                                decoration: isTaken ? TextDecoration.lineThrough : null,
                                color: isTaken ? AppTheme.white38 : AppTheme.white,
                              ),
                            ),
                            Text(pill['time'] as String, style: AppTheme.captionStyle),
                          ],
                        ),
                      ),
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: isTaken ? AppTheme.accentGold : Colors.transparent,
                          border: Border.all(color: isTaken ? AppTheme.accentGold : AppTheme.white38, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: isTaken ? const Icon(Icons.check, size: 16, color: AppTheme.primaryDark) : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
