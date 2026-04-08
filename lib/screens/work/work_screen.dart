import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:async'; // For timer updates in UI if needed
import 'package:path_provider/path_provider.dart';
import '../../core/providers/work_provider.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  bool _isEditMode = false;
  int? _selectedDay;
  Timer? _ticker;
  
  void _startTicker(WorkProvider work) {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
         if (work.isTimerRunning) {
           work.tickTimer();
         } else {
           timer.cancel();
         }
      } else {
        timer.cancel();
      }
    });
  }
  
  @override
  void initState() {
    super.initState();
    // Start ticker to drive the provider
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final work = Provider.of<WorkProvider>(context, listen: false);
        if (work.isTimerRunning) {
          work.tickTimer();
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
  
  String _formatDuration(double seconds) {
    final int sec = seconds.toInt();
    final int h = sec ~/ 3600;
    final int m = (sec % 3600) ~/ 60;
    final int s = sec % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Rich gold color
  static const Color goldColor = Color(0xFFFFD700);
  static const Color darkGold = Color(0xFFB8860B);
  static const Color cardBg = Color(0xFF1E1E1E);
  static const Color borderColor = Color(0xFF3D3D3D);

  void _showCommentDialog(BuildContext context, WorkProvider work) {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите день (тап по дню)')),
      );
      return;
    }
    
    final day = _selectedDay!;
    final controller = TextEditingController(text: work.dayComments[day] ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Комментарий: $day ${work.monthName}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Введите комментарий...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      work.setDayComment(day, controller.text);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Комментарий сохранён для $day ${work.monthName}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showHoursDialog(BuildContext context, WorkProvider work, int day) {
    final currentHours = work.workedDays[day] ?? work.hoursPerDay;
    double selectedHours = currentHours;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Часы: $day ${work.monthName}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (selectedHours > 0) {
                        setModalState(() => selectedHours -= 0.5);
                      }
                    },
                    icon: const Icon(Icons.remove_circle, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${selectedHours.toStringAsFixed(1)}ч',
                    style: TextStyle(color: goldColor, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      if (selectedHours < 24) {
                        setModalState(() => selectedHours += 0.5);
                      }
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Quick select buttons
              Wrap(
                spacing: 8,
                children: [4, 6, 8, 10, 12].map((h) => 
                  ChoiceChip(
                    label: Text('$h ч'),
                    selected: selectedHours == h,
                    onSelected: (_) => setModalState(() => selectedHours = h.toDouble()),
                    selectedColor: goldColor,
                    labelStyle: TextStyle(color: selectedHours == h ? Colors.black : Colors.white),
                    backgroundColor: Colors.grey[800],
                  ),
                ).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        work.setHoursForDay(day, 0);
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Выходной'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        work.setHoursForDay(day, selectedHours);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Сохранить'),
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

  void _showAddPlanDialog(BuildContext context, WorkProvider work) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добавить план на выходные',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Чем заняться?',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    work.addWeekendPlan(controller.text);
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Добавить'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context, WorkProvider work) {
    final controller = TextEditingController(text: work.hourlyRate.toInt().toString());
    double rate = work.hourlyRate;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ставка в час',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Manual input field
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: goldColor, fontSize: 32, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  suffixText: '₽',
                  suffixStyle: TextStyle(color: goldColor, fontSize: 24),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null && parsed >= 0 && parsed <= 10000) {
                    setModalState(() => rate = parsed);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Slider for quick adjustment
              Row(
                children: [
                  Text('50₽', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: rate.clamp(50, 5000),
                      min: 50,
                      max: 5000,
                      divisions: 99,
                      activeColor: goldColor,
                      inactiveColor: Colors.grey[700],
                      onChanged: (v) {
                        setModalState(() {
                          rate = v;
                          controller.text = v.toInt().toString();
                        });
                      },
                    ),
                  ),
                  Text('5000₽', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              
              // Quick preset buttons
              Wrap(
                spacing: 8,
                children: [100, 200, 300, 500, 1000].map((r) => 
                  ChoiceChip(
                    label: Text('$r₽'),
                    selected: rate.toInt() == r,
                    onSelected: (_) {
                      setModalState(() {
                        rate = r.toDouble();
                        controller.text = r.toString();
                      });
                    },
                    selectedColor: goldColor,
                    labelStyle: TextStyle(color: rate.toInt() == r ? Colors.black : Colors.white, fontSize: 12),
                    backgroundColor: Colors.grey[800],
                  ),
                ).toList(),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final finalRate = double.tryParse(controller.text) ?? rate;
                    work.setHourlyRate(finalRate);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ставка установлена: ${finalRate.toInt()}₽/час')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Сохранить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportToPdf(BuildContext context, WorkProvider work) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: goldColor)),
    );

    try {
      // Generate text report (simplified PDF simulation)
      final report = StringBuffer();
      report.writeln('═══════════════════════════════════════');
      report.writeln('        ОТЧЁТ О РАБОЧЕМ ВРЕМЕНИ');
      report.writeln('═══════════════════════════════════════');
      report.writeln('');
      report.writeln('Месяц: ${work.monthName} ${work.currentMonth.year}');
      report.writeln('');
      report.writeln('───────────────────────────────────────');
      report.writeln('СТАТИСТИКА:');
      report.writeln('───────────────────────────────────────');
      report.writeln('• Отработано дней: ${work.totalDaysWorked}');
      report.writeln('• Всего часов: ${work.totalHoursThisMonth.toStringAsFixed(1)}');
      report.writeln('• Ставка в час: ${work.hourlyRate.toInt()}₽');
      report.writeln('• Заработано: ${work.totalEarned.toInt()}₽');
      report.writeln('');
      report.writeln('───────────────────────────────────────');
      report.writeln('ДЕТАЛИЗАЦИЯ ПО ДНЯМ:');
      report.writeln('───────────────────────────────────────');
      
      for (var entry in work.workedDays.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
        final comment = work.dayComments[entry.key];
        report.writeln('${entry.key.toString().padLeft(2, '0')} ${work.monthName}: ${entry.value}ч${comment != null ? ' ($comment)' : ''}');
      }
      
      report.writeln('');
      report.writeln('═══════════════════════════════════════');
      report.writeln('Создано в DAYLO');
      
      // Save to file
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/work_report_${work.monthName}_${work.currentMonth.year}.txt');
      await file.writeAsString(report.toString());
      
      Navigator.pop(context); // Close loading
      
      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Отчёт о работе: ${work.monthName} ${work.currentMonth.year}',
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка экспорта: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<WorkProvider>(
        builder: (context, work, _) {
          return SingleChildScrollView(
            // Top padding for status bar, bottom padding for nav bar + extra
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16, 
              left: 20, 
              right: 20, 
              bottom: 120
            ),
            physics: const BouncingScrollPhysics(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Работа',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const SizedBox(height: 24),
                  
                  // Timer Section
                  _buildTimerSection(context, work),

                  const SizedBox(height: 24),

                  // Work Schedule Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'График работы',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => work.previousMonth(),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: borderColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    work.monthName,
                                    style: TextStyle(color: goldColor, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => work.nextMonth(),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: borderColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Days of week header
                        Row(
                          children: ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС']
                              .map((d) => Expanded(
                                    child: Center(
                                      child: Text(
                                        d,
                                        style: TextStyle(
                                          color: (d == 'СБ' || d == 'ВС') ? Colors.red[300] : Colors.grey[500],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        
                        // Calendar Grid
                        _buildCalendarGrid(work),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Редактировать',
                          icon: Icons.edit,
                          isActive: _isEditMode,
                          onTap: () => setState(() => _isEditMode = !_isEditMode),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          label: 'Комментарий',
                          icon: Icons.comment,
                          isActive: false,
                          onTap: () => _showCommentDialog(context, work),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (_selectedDay != null) {
                            _showHoursDialog(context, work, _selectedDay!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Выберите день для установки часов')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: goldColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.access_time, color: Colors.black, size: 22),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // PDF Export Button
                  GestureDetector(
                    onTap: () => _exportToPdf(context, work),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [darkGold, goldColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Экспорт отчёта',
                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Work Time Section
                  const Text(
                    'Рабочее время',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(child: _StatCard(value: '${work.totalHoursThisMonth.toInt()}ч', label: 'Часов', icon: Icons.schedule)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(value: '${work.totalDaysWorked}', label: 'Дней', icon: Icons.calendar_today)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showRateDialog(context, work),
                          child: _StatCard(value: '${work.hourlyRate.toInt()}₽', label: 'Ставка', icon: Icons.attach_money, isEditable: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Earnings Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cardBg, const Color(0xFF2A2A2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Заработано',
                              style: TextStyle(color: Colors.grey[500], fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${work.totalEarned.toInt()}₽',
                              style: TextStyle(
                                color: goldColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: goldColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.monetization_on, color: goldColor, size: 32),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Weekend Plans Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Планы на выходные',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => _showAddPlanDialog(context, work),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: goldColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.black, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Plans List
                  if (work.weekendPlans.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.event_available, color: Colors.grey[600], size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'Нет планов на выходные',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  else
                    ...work.weekendPlans.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: Key('plan_${entry.key}_${entry.value}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => work.removeWeekendPlan(entry.key),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: goldColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
                            ],
                          ),
                        ),
                      ),
                    )),
                  
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
    );
  }

  Widget _buildCalendarGrid(WorkProvider work) {
    final daysInMonth = work.daysInMonth;
    final firstWeekday = work.firstWeekday;
    
    List<Widget> rows = [];
    List<Widget> currentRow = [];
    
    // Add empty cells for days before the first of the month
    for (int i = 1; i < firstWeekday; i++) {
      currentRow.add(Expanded(child: Container()));
    }
    
    for (int day = 1; day <= daysInMonth; day++) {
      final hours = work.workedDays[day] ?? 0;
      final isWorked = hours > 0;
      final hasComment = work.dayComments.containsKey(day);
      final isSelected = _selectedDay == day;
      final isToday = DateTime.now().day == day && 
                      DateTime.now().month == work.currentMonth.month &&
                      DateTime.now().year == work.currentMonth.year;
      
      currentRow.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_isEditMode) {
                work.toggleWorkDay(day);
              } else {
                setState(() => _selectedDay = day);
              }
            },
            onLongPress: () {
              setState(() => _selectedDay = day);
              _showHoursDialog(context, work, day);
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isWorked ? goldColor : borderColor,
                borderRadius: BorderRadius.circular(8),
                border: isSelected 
                    ? Border.all(color: Colors.white, width: 2) 
                    : isToday
                        ? Border.all(color: goldColor, width: 2)
                        : hasComment 
                            ? Border.all(color: Colors.blue, width: 1) 
                            : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      color: isWorked ? Colors.black : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hours > 0 && hours != work.hoursPerDay)
                    Positioned(
                      bottom: 2,
                      child: Text(
                        '${hours.toInt()}ч',
                        style: TextStyle(
                          color: isWorked ? Colors.black54 : Colors.grey,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  if (hasComment)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      
      if (currentRow.length == 7 || day == daysInMonth) {
        // Pad the last row if needed
        while (currentRow.length < 7) {
          currentRow.add(Expanded(child: Container()));
        }
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: currentRow),
          ),
        );
        currentRow = [];
      }
    }
    
    return Column(children: rows);
  }
  Widget _buildTimerSection(BuildContext context, WorkProvider work) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardBg, const Color(0xFF252525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Mode Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeTab('Таймер', work.timerMode == TimerMode.standard, () => work.setTimerMode(TimerMode.standard)),
                _buildModeTab('Помодоро', work.timerMode == TimerMode.pomodoro, () => work.setTimerMode(TimerMode.pomodoro)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Timer Display
          if (work.timerMode == TimerMode.standard)
            Column(
              children: [
                Text(
                  _formatDuration(work.currentSessionDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'текущая сессия',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            )
          else
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: work.pomodoroTotalDuration > 0 
                            ? work.pomodoroSecondsLeft / work.pomodoroTotalDuration 
                            : 0,
                        strokeWidth: 12,
                        backgroundColor: Colors.white10,
                        color: _getPomodoroColor(work.pomodoroState),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          _formatDuration(work.pomodoroSecondsLeft.toDouble()).substring(3), // mm:ss
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: _getPomodoroColor(work.pomodoroState).withOpacity(0.2),
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: Text(
                             _getPomodoroStatus(work.pomodoroState),
                             style: TextStyle(
                               color: _getPomodoroColor(work.pomodoroState),
                               fontWeight: FontWeight.bold,
                               fontSize: 12,
                             ),
                           ),
                         ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          
          const SizedBox(height: 32),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (work.isTimerRunning)
                 GestureDetector(
                   onTap: () => work.stopTimer(), // Pause/Stop logic
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                     decoration: BoxDecoration(
                       color: Colors.redAccent.withOpacity(0.2),
                       borderRadius: BorderRadius.circular(30),
                       border: Border.all(color: Colors.redAccent),
                     ),
                     child: const Row(
                       children: [
                         Icon(Icons.pause, color: Colors.redAccent),
                         SizedBox(width: 8),
                         Text('Стоп', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                       ],
                     ),
                   ),
                 )
              else
                 GestureDetector(
                   onTap: () => work.startTimer(),
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                     decoration: BoxDecoration(
                       color: goldColor,
                       borderRadius: BorderRadius.circular(30),
                       boxShadow: [
                         BoxShadow(color: goldColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                       ],
                     ),
                     child: const Row(
                       children: [
                         Icon(Icons.play_arrow, color: Colors.black),
                         SizedBox(width: 8),
                         Text('Старт', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                       ],
                     ),
                   ),
                 ),
                 
               if (work.timerMode == TimerMode.pomodoro && work.isTimerRunning) ...[
                 const SizedBox(width: 16),
                 GestureDetector(
                   onTap: () => work.skipPomodoroStage(),
                   child: Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Colors.white10,
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.skip_next, color: Colors.white),
                   ),
                 )
               ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3D3D3D) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Color _getPomodoroColor(PomodoroState state) {
    switch (state) {
      case PomodoroState.work: return const Color(0xFFFF5252); // Red
      case PomodoroState.shortBreak: return const Color(0xFF69F0AE); // Green
      case PomodoroState.longBreak: return const Color(0xFF448AFF); // Blue
    }
  }

  String _getPomodoroStatus(PomodoroState state) {
    switch (state) {
      case PomodoroState.work: return 'Работа 👨‍💻';
      case PomodoroState.shortBreak: return 'Перерыв ☕';
      case PomodoroState.longBreak: return 'Длинный перерыв 🌳';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFD700) : const Color(0xFF3D3D3D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.black : Colors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isEditable;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3D3D3D)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              if (isEditable) ...[
                const SizedBox(width: 2),
                Icon(Icons.edit, color: Colors.grey[600], size: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
