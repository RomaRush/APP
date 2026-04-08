import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/health_provider.dart';
import 'mental_health_screen.dart';
import 'breathing_screen.dart';
import '../../core/providers/smart_life_provider.dart';
import 'widgets/water_tracker.dart';
import '../home/article_screen.dart';
import '../../widgets/note_editor_sheet.dart';
import 'package:fl_chart/fl_chart.dart';

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

  void _editNote(BuildContext context, String title, String currentNote, Function(String) onSave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteEditorSheet(
        title: title,
        initialContent: currentNote,
        onSave: onSave,
      ),
    );
  }

  void _measureMentalHealth(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MentalHealthScreen()),
    );
    if (result != null && result is Map) {
      if (context.mounted) {
        context.read<HealthProvider>().updateMentalHealth(result['status'], result['color']);
      }
    }
  }

  void _openArticle(BuildContext context, String title, String imagePath) {
    List<ArticleBlock> blocks = [];
    
    // Using simple lowerCase check for flexibility
    String lowerTitle = title.toLowerCase();
  
    if (lowerTitle.contains("питание")) {
      blocks = [
        ArticleBlock(
          type: ArticleContentType.text,
          content: "🍫 Почему вам хочется спать после обеда и причем тут «сахарные качели»?\n\nЗнакомое чувство: вы плотно пообедали, но вместо прилива сил вас накрывает «туман» в голове? Это глюкозный спад.",
        ),
        ArticleBlock(
          type: ArticleContentType.image, 
          // Sugar/Donuts vs Broccoli concept
          content: 'https://images.unsplash.com/photo-1502462041640-b05d92a83e68?q=80&w=800&auto=format&fit=crop', 
        ),
        ArticleBlock(
          type: ArticleContentType.recipeStep,
          title: "Глюкозная Ракета 🚀",
          content: "Когда мы едим быстрые углеводы на голодный желудок, уровень сахара взлетает. Поджелудочная выбрасывает инсулин, и сахар резко падает. Результат — голод и усталость.",
        ),
        ArticleBlock(
          type: ArticleContentType.image, 
          // Healthy salad/protein meal
          content: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop', 
        ),
        ArticleBlock(
          type: ArticleContentType.recipeStep,
          title: "Хакни систему: Очередность",
          content: "1. 🥗 Клетчатка (овощи).\n2. 🥩 Белки и жиры.\n3. 🍝 Углеводы.\n\nДесерт после стейка = ровная энергия.",
        ),
      ];
    } else if (lowerTitle.contains("сон")) {
      blocks = [
        ArticleBlock(
          type: ArticleContentType.text,
          content: "☕️ Первая чашка кофе: почему её нельзя пить сразу после пробуждения?\n\nКофе в первые 90 минут — это кредит энергии под огромные проценты.",
        ),
        ArticleBlock(
          type: ArticleContentType.image, 
          // Morning sunlight / water
          content: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=800&auto=format&fit=crop',
        ),
        ArticleBlock(
          type: ArticleContentType.recipeStep,
          title: "Кофеин и Аденозин",
          content: "Кофеин маскирует усталость, но не убирает её. Если выпить кофе сразу, вы собьете кортизол, и день будет разбит.",
        ),
        ArticleBlock(
          type: ArticleContentType.image, 
          // Coffee art/concept
          content: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=800&auto=format&fit=crop',
        ),
        ArticleBlock(
          type: ArticleContentType.recipeStep,
          title: "Стратегия 90 минут",
          content: "0–90 мин: Вода, свет, движение.\nПосле 90 мин: Кофе. Идеальный заряд бодрости.",
        ),
      ];
    } else {
      blocks = [
        ArticleBlock(
          type: ArticleContentType.text,
          content: "🦵 Отеки и усталость. Ваша лимфа просит о помощи.\n\nЛимфатическая система — это «канализация» организма. У неё нет насоса, она движется только когда вы двигаетесь.",
        ),
        ArticleBlock(
          type: ArticleContentType.image, 
          // Running / Legs motion
          content: 'https://images.unsplash.com/photo-1552674605-4695c316f6b4?q=80&w=800&auto=format&fit=crop',
        ),
        ArticleBlock(
          type: ArticleContentType.text,
          content: "Сидячий образ жизни превращает лимфу в болото. Отсюда отеки и целлюлит.",
        ),
        ArticleBlock(
          type: ArticleContentType.image, 
          // Water / Silhouette concept abstract
          content: 'https://images.unsplash.com/photo-1544367563-12123d832d61?q=80&w=800&auto=format&fit=crop',
        ),
        ArticleBlock(
          type: ArticleContentType.recipeStep,
          title: "Запуск системы",
          content: "1. Прыжки на пятках утром.\n2. Больше воды.\n3. Движение стопами под столом.",
        ),
      ];
    }

// ... 

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(
          title: title,
          headerImage: imagePath,
          blocks: blocks,
        ),
      ),
    );
  }

  void _showSleepEditDialog(BuildContext context, HealthProvider health) async {
    final initialStart = health.sleepStart ?? DateTime(2024, 1, 1, 23, 0);
    final initialEnd = health.sleepEnd ?? DateTime(2024, 1, 2, 7, 0);
    
    DateTime start = DateTime(2024, 1, 1, initialStart.hour, initialStart.minute);
    DateTime end = DateTime(2024, 1, 1, initialEnd.hour, initialEnd.minute);
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: 600,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Настройка сна',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Sleep Bar Chart
                Container(
                  height: 160,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'За неделю: ${health.weeklySleepAverage.toStringAsFixed(1)} ч',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            'За месяц: ${health.monthlySleepAverage.toStringAsFixed(1)} ч',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceEvenly,
                            maxY: 12,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                                    if (value.toInt() >= 0 && value.toInt() < 7) {
                                      return Text(days[value.toInt()], 
                                        style: const TextStyle(color: Colors.white54, fontSize: 10));
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            barGroups: List.generate(7, (index) {
                              // Get sleep data for each day of week (reversed to show most recent)
                              final now = DateTime.now();
                              final dayData = health.sleepHistory.where((h) {
                                final date = h['date'] as DateTime;
                                final diff = now.difference(date).inDays;
                                return diff == (6 - index);
                              }).toList();
                              final hours = dayData.isNotEmpty ? (dayData.first['hours'] as double) : 0.0;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: hours,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: LinearGradient(
                                      colors: hours >= 7 
                                        ? [Colors.greenAccent, Colors.teal]
                                        : hours >= 5 
                                          ? [Colors.orangeAccent, Colors.amber]
                                          : [Colors.redAccent, Colors.red],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Отбой 🌙',
                              style: TextStyle(
                                color: Colors.indigoAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: CupertinoTheme(
                                data: const CupertinoThemeData(
                                  brightness: Brightness.dark,
                                  textTheme: CupertinoTextThemeData(
                                    dateTimePickerTextStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.time,
                                  use24hFormat: true,
                                  initialDateTime: start,
                                  onDateTimeChanged: (val) {
                                    setModalState(() => start = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, color: Colors.white10, margin: const EdgeInsets.symmetric(vertical: 20)),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Подъём ☀️',
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: CupertinoTheme(
                                data: const CupertinoThemeData(
                                  brightness: Brightness.dark,
                                  textTheme: CupertinoTextThemeData(
                                    dateTimePickerTextStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.time,
                                  use24hFormat: true,
                                  initialDateTime: end,
                                  onDateTimeChanged: (val) {
                                    setModalState(() => end = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            final now = DateTime.now();
                            final s = DateTime(now.year, now.month, now.day, start.hour, start.minute);
                            var e = DateTime(now.year, now.month, now.day, end.hour, end.minute);
                            
                            // Adjust for next day if end < start (e.g. 23:00 -> 07:00)
                            if (e.isBefore(s)) {
                              e = e.add(const Duration(days: 1));
                            }
                            
                            health.setSleepTimes(s, e);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Сохранить',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlueAccent, Color(0xFFF8BBD0)],
          ),
        ),
        child: Consumer<HealthProvider>(
            builder: (context, health, _) {
              return SingleChildScrollView(
                // Use MediaQuery padding for top (status bar) and adequate bottom padding
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20, 
                  right: 20, 
                  bottom: 120 // Space for floating nav
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Здоровье',
                      style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!health.isAuthorized) {
                                health.connectHealth();
                              }
                            },
                            child: _StatusCard(
                              title: 'Шаги',
                              value: health.isAuthorized ? '${health.steps}' : 'Подкл.',
                              subtitle: health.isAuthorized ? 'шагов сегодня' : 'Health/Google Fit',
                              icon: Icons.directions_walk,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatusCard(
                            title: 'Ккал',
                            value: health.isAuthorized ? '${health.calories.toInt()}' : '-',
                            subtitle: 'активная энергия',
                            icon: Icons.local_fire_department,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                                        const SizedBox(height: 16),
                      
                      // Sleep Card
                      GestureDetector(
                        onTap: () => _showSleepEditDialog(context, health),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.indigoAccent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: const Icon(Icons.bedtime, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Сон', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  Text(
                                    '${health.sleepHours.toStringAsFixed(1)} ч',
                                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (health.sleepStart != null && health.sleepEnd != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${TimeOfDay.fromDateTime(health.sleepStart!).format(context)} - ${TimeOfDay.fromDateTime(health.sleepEnd!).format(context)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                )
                              else
                                const Icon(Icons.edit, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    
                    const SizedBox(height: 16),
                    const WaterTracker(),
                    const SizedBox(height: 16),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: health.mentalColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                            BoxShadow(color: health.mentalColor.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Ментальное здоровье',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            health.mentalStatus,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          if (health.moodHistory.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: health.moodHistory.take(7).map((e) {
                                return Container(
                                  width: 12, height: 12,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(color: (e['color'] as Color).withValues(alpha: 0.8), shape: BoxShape.circle),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _measureMentalHealth(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('Измерить', style: TextStyle(color: health.mentalColor)),
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BreathingScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.air, size: 40, color: Colors.blueAccent),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Дыхание', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey[900])),
                                Text('Практика 2 минуты', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                              ],
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text('Дневник', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    _NoteCard(
                      title: 'Сон',
                      content: health.sleepNote,
                      icon: Icons.nights_stay,
                      color: Colors.indigo,
                      onTap: () => _editNote(context, "Запись сна", health.sleepNote, (val) => health.updateSleepNote(val)),
                    ),
                    const SizedBox(height: 12),
                    _NoteCard(
                      title: 'Мой день',
                      content: health.dayNote,
                      icon: Icons.wb_sunny,
                      color: Colors.orange,
                      onTap: () => _editNote(context, "Мой день", health.dayNote, (val) => health.updateDayNote(val)),
                    ),

                    const SizedBox(height: 24),
                    const Text('Полезное', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _HealthTipCard(
                            title: 'Сахарные качели',
                            imagePath: 'assets/images/health_nutrition.png',
                            onTap: () => _openArticle(context, "Питание", 'assets/images/health_nutrition.png'),
                          ),
                          const SizedBox(width: 14),
                          _HealthTipCard(
                            title: 'Кофе и аденозин',
                            imagePath: 'assets/images/health_sleep.png',
                            onTap: () => _openArticle(context, "Сон", 'assets/images/health_sleep.png'),
                          ),
                          const SizedBox(width: 14),
                          _HealthTipCard(
                            title: 'Лимфа и движение',
                            imagePath: 'assets/images/health_sport.png',
                            onTap: () => _openArticle(context, "Спорт", 'assets/images/health_sport.png'),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }
          ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[900])),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NoteCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[900])),
                  ],
                ),
                Icon(Icons.edit, size: 18, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: content == "Пока пусто" ? Colors.grey[500] : Colors.grey[800],
                fontStyle: content == "Пока пусто" ? FontStyle.italic : FontStyle.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthTipCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  
  const _HealthTipCard({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            
            // Title
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
