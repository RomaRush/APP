import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/finance_provider.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/nutrition_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/work_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/minimal_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMonths = 1; // 1, 3, 6

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Consumer<UserProvider>(
              builder: (_, user, __) =>
                  Image.asset(user.wallpaperPath, fit: BoxFit.cover),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                  child: Text('Статистика', style: AppTheme.headlineStyle),
                ),
                const SizedBox(height: 16),
                // Period selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                  child: Row(
                    children: [
                      _PeriodChip(label: '1 мес', selected: _selectedMonths == 1,
                          onTap: () => setState(() => _selectedMonths = 1)),
                      const SizedBox(width: 8),
                      _PeriodChip(label: '3 мес', selected: _selectedMonths == 3,
                          onTap: () => setState(() => _selectedMonths = 3)),
                      const SizedBox(width: 8),
                      _PeriodChip(label: '6 мес', selected: _selectedMonths == 6,
                          onTap: () => setState(() => _selectedMonths = 6)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tabs
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                      decoration: BoxDecoration(
                        color: AppTheme.white08,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.white12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppTheme.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: AppTheme.white,
                        unselectedLabelColor: AppTheme.white38,
                        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        unselectedLabelStyle: const TextStyle(fontSize: 11),
                        dividerColor: Colors.transparent,
                        padding: const EdgeInsets.all(4),
                        tabs: const [
                          Tab(text: 'Питание'),
                          Tab(text: 'Работа'),
                          Tab(text: 'Здоровье'),
                          Tab(text: 'Финансы'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _NutritionStats(months: _selectedMonths),
                      _WorkStats(months: _selectedMonths),
                      _HealthStats(months: _selectedMonths),
                      _FinanceStats(months: _selectedMonths),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── NUTRITION ───────────────────────────────────────────────────────────────
class _NutritionStats extends StatelessWidget {
  final int months;
  const _NutritionStats({required this.months});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (_, nutrition, __) {
        final now = DateTime.now();
        final cutoff = DateTime(now.year, now.month - months + 1, 1);

        // Build daily calorie data from meals map
        final List<FlSpot> calorieSpots = [];
        int dayIndex = 0;
        for (int m = 0; m < months; m++) {
          final month = DateTime(now.year, now.month - m, 1);
          final days = DateTimeRange(
            start: DateTime(month.year, month.month, 1),
            end: DateTime(month.year, month.month + 1, 0),
          ).duration.inDays + 1;
          for (int d = 1; d <= days; d++) {
            final key =
                '${month.year}-${month.month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
            final dayMeals = nutrition.allMeals[key] as Map?;
            double cal = 0;
            if (dayMeals != null) {
              for (var mealProducts in dayMeals.values) {
                for (var p in mealProducts) {
                  cal += (p.actualCalories as double);
                }
              }
            }
            calorieSpots.add(FlSpot(dayIndex.toDouble(), cal));
            dayIndex++;
          }
        }

        final avgCal = calorieSpots.isEmpty
            ? 0.0
            : calorieSpots.fold(0.0, (s, e) => s + e.y) / calorieSpots.length;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
          children: [
            _StatsCard(
              title: 'Калории по дням',
              subtitle: 'Среднее: ${avgCal.toInt()} ккал',
              child: _buildLineChart(calorieSpots, AppTheme.accentPink, 3000),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _StatTile(label: 'Цель', value: '${nutrition.calorieGoal.toInt()} ккал', color: AppTheme.accentGold)),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Среднее', value: '${avgCal.toInt()} ккал', color: AppTheme.accentPink)),
            ]),
            const SizedBox(height: 120),
          ],
        );
      },
    );
  }
}

// ─── WORK ─────────────────────────────────────────────────────────────────────
class _WorkStats extends StatelessWidget {
  final int months;
  const _WorkStats({required this.months});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkProvider>(
      builder: (_, work, __) {
        final now = DateTime.now();

        // Monthly hours data
        final List<BarChartGroupData> bars = [];
        final List<String> monthLabels = [];
        double totalEarned = 0;
        int totalDays = 0;

        for (int i = months - 1; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          final prefix =
              '${month.year}-${month.month.toString().padLeft(2, '0')}';
          const months_ = [
            'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн',
            'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'
          ];
          monthLabels.add(months_[month.month - 1]);

          double monthHours = 0;
          int monthDays = 0;
          work.allWorkedDays.forEach((key, hours) {
            if (key.startsWith(prefix) && hours > 0) {
              monthHours += hours;
              monthDays++;
            }
          });

          final earnings = work.isHourlyRate
              ? monthHours * work.hourlyRate
              : monthDays * work.shiftRate;
          totalEarned += earnings;
          totalDays += monthDays;

          bars.add(BarChartGroupData(
            x: bars.length,
            barRods: [
              BarChartRodData(
                toY: monthHours,
                color: AppTheme.accentGold,
                width: 16,
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 300,
                  color: AppTheme.white05,
                ),
              ),
            ],
          ));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
          children: [
            _StatsCard(
              title: 'Часы по месяцам',
              subtitle: 'Всего дней: $totalDays',
              child: SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    barGroups: bars,
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppTheme.white08,
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(
                            monthLabels[v.toInt()],
                            style: AppTheme.captionStyle.copyWith(fontSize: 10),
                          ),
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _StatTile(label: 'Заработано', value: '${totalEarned.toInt()} ₽', color: AppTheme.accentGold)),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Рабочих дней', value: '$totalDays', color: AppTheme.accentIndigo)),
            ]),
            const SizedBox(height: 120),
          ],
        );
      },
    );
  }
}

// ─── HEALTH ───────────────────────────────────────────────────────────────────
class _HealthStats extends StatelessWidget {
  final int months;
  const _HealthStats({required this.months});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (_, health, __) {
        final history = health.sleepHistory;
        final now = DateTime.now();
        final cutoff = DateTime(now.year, now.month - months + 1, 1);
        final filtered = history
            .where((h) => (h['date'] as DateTime).isAfter(cutoff))
            .toList();

        final spots = filtered.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), (e.value['hours'] as double));
        }).toList();

        final avgSleep = spots.isEmpty
            ? 0.0
            : spots.fold(0.0, (s, e) => s + e.y) / spots.length;

        // Mood distribution
        final moodFiltered = health.moodHistory
            .where((m) => (m['date'] as DateTime).isAfter(cutoff))
            .toList();

        final moodCounts = <String, int>{};
        for (var m in moodFiltered) {
          final s = m['status'] as String;
          moodCounts[s] = (moodCounts[s] ?? 0) + 1;
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
          children: [
            _StatsCard(
              title: 'Сон по ночам',
              subtitle: 'Среднее: ${avgSleep.toStringAsFixed(1)} ч',
              child: spots.isEmpty
                  ? _emptyChart()
                  : _buildLineChart(spots, AppTheme.accentIndigo, 12),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _StatTile(label: 'Среднее', value: '${avgSleep.toStringAsFixed(1)} ч', color: AppTheme.accentIndigo)),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Записей', value: '${filtered.length}', color: AppTheme.accentGreen)),
            ]),
            if (moodCounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              _StatsCard(
                title: 'Настроение',
                subtitle: '${moodFiltered.length} записей',
                child: Column(
                  children: moodCounts.entries.map((e) {
                    final pct = e.value / moodFiltered.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        SizedBox(width: 80, child: Text(e.key, style: AppTheme.captionStyle.copyWith(fontSize: 11), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                              backgroundColor: AppTheme.white08,
                              valueColor: AlwaysStoppedAnimation(AppTheme.accentGreen),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${e.value}', style: AppTheme.captionStyle),
                      ]),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 120),
          ],
        );
      },
    );
  }
}

// ─── FINANCE ──────────────────────────────────────────────────────────────────
class _FinanceStats extends StatelessWidget {
  final int months;
  const _FinanceStats({required this.months});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (_, finance, __) {
        final now = DateTime.now();
        final cutoff = DateTime(now.year, now.month - months + 1, 1);

        final txFiltered =
            finance.transactions.where((t) => t.date.isAfter(cutoff)).toList();

        // Group by month
        final Map<String, double> incomeByMonth = {};
        final Map<String, double> expenseByMonth = {};
        const monthNames = ['Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'];

        for (int i = months - 1; i >= 0; i--) {
          final m = DateTime(now.year, now.month - i, 1);
          final key = monthNames[m.month - 1];
          incomeByMonth[key] = 0;
          expenseByMonth[key] = 0;
        }

        for (var t in txFiltered) {
          final key = monthNames[t.date.month - 1];
          if (t.isExpense) {
            expenseByMonth[key] = (expenseByMonth[key] ?? 0) + t.amount;
          } else {
            incomeByMonth[key] = (incomeByMonth[key] ?? 0) + t.amount;
          }
        }

        final keys = incomeByMonth.keys.toList();
        final List<BarChartGroupData> bars = keys.asMap().entries.map((e) {
          final inc = incomeByMonth[e.value] ?? 0;
          final exp = expenseByMonth[e.value] ?? 0;
          return BarChartGroupData(
            x: e.key,
            barsSpace: 4,
            barRods: [
              BarChartRodData(toY: inc, color: AppTheme.accentGreen, width: 10, borderRadius: BorderRadius.circular(4)),
              BarChartRodData(toY: exp, color: AppTheme.errorRed, width: 10, borderRadius: BorderRadius.circular(4)),
            ],
          );
        }).toList();

        final totalIncome = incomeByMonth.values.fold(0.0, (s, e) => s + e);
        final totalExpense = expenseByMonth.values.fold(0.0, (s, e) => s + e);

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
          children: [
            _StatsCard(
              title: 'Доходы и расходы',
              subtitle: '🟢 Доходы  🔴 Расходы',
              child: SizedBox(
                height: 180,
                child: bars.isEmpty
                    ? _emptyChart()
                    : BarChart(BarChartData(
                        barGroups: bars,
                        gridData: FlGridData(
                          show: true,
                          getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.white08, strokeWidth: 1),
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Text(
                                keys[v.toInt()],
                                style: AppTheme.captionStyle.copyWith(fontSize: 10),
                              ),
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                      )),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _StatTile(label: 'Доходы', value: '${totalIncome.toInt()} ₽', color: AppTheme.accentGreen)),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Расходы', value: '${totalExpense.toInt()} ₽', color: AppTheme.errorRed)),
            ]),
            const SizedBox(height: 8),
            _StatTile(label: 'Баланс', value: '${(totalIncome - totalExpense).toInt()} ₽', color: totalIncome >= totalExpense ? AppTheme.accentGreen : AppTheme.errorRed),
            const SizedBox(height: 120),
          ],
        );
      },
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────
Widget _buildLineChart(List<FlSpot> spots, Color color, double maxY) {
  if (spots.isEmpty) return _emptyChart();
  return SizedBox(
    height: 180,
    child: LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.white08, strokeWidth: 1),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: color,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _emptyChart() {
  return const SizedBox(
    height: 100,
    child: Center(
      child: Text('Нет данных за период', style: TextStyle(color: AppTheme.white38, fontSize: 14)),
    ),
  );
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _StatsCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF161618).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.titleStyle.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTheme.captionStyle),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              Text(value, style: AppTheme.titleStyle.copyWith(color: color, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.white.withValues(alpha: 0.15) : AppTheme.white08,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.white.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Text(label,
          style: TextStyle(
            color: selected ? AppTheme.white : AppTheme.white54,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
