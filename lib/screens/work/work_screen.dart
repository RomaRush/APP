import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/providers/work_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/minimal_card.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatTime(double seconds) {
    final int sec = seconds.toInt();
    final int m = sec ~/ 60;
    final int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
              builder: (context, user, _) => Image.asset(user.wallpaperPath, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.1),
                    AppTheme.primaryDark,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Consumer<WorkProvider>(
              builder: (context, work, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Работа', style: AppTheme.headlineStyle)
                              .animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.white70),
                                onPressed: () => _exportPdf(context, work),
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings_rounded, color: AppTheme.white70),
                                onPressed: () => _showSettingsSheet(context, work),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      _buildTimerCard(work).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 20),
                      
                      _buildScheduleCard(work).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _WorkStatCard(
                              title: 'Часы',
                              value: '${work.totalHoursThisMonth.toInt()}',
                              icon: Icons.schedule_rounded,
                              color: AppTheme.accentGold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _WorkStatCard(
                              title: 'Дни',
                              value: '${work.totalDaysWorked}',
                              icon: Icons.calendar_month_rounded,
                              color: AppTheme.accentIndigo,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 20),
                      
                      MinimalCard(
                        padding: const EdgeInsets.all(24),
                        color: AppTheme.accentGold.withValues(alpha: 0.05),
                        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Заработано', style: AppTheme.captionStyle),
                                const SizedBox(height: 6),
                                Text(
                                  '${work.totalEarned.toInt()} ₽',
                                  style: AppTheme.headlineStyle.copyWith(color: AppTheme.accentGold, fontSize: 32, letterSpacing: -1),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.2)),
                              ),
                              child: const Icon(Icons.payments_rounded, color: AppTheme.accentGold, size: 28),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1, end: 0),
                      
                       const SizedBox(height: 32),
                       Text('Комментарии дней', style: AppTheme.titleStyle),
                       const SizedBox(height: 16),
                       
                       MinimalCard(
                         padding: EdgeInsets.zero,
                         child: Column(
                           children: [
                             if (work.dayComments.isEmpty)
                               Padding(
                                 padding: const EdgeInsets.all(32),
                                 child: Text('Комментариев пока нет', style: AppTheme.captionStyle),
                               )
                             else
                               ListView.separated(
                                 shrinkWrap: true,
                                 physics: const NeverScrollableScrollPhysics(),
                                 itemCount: work.dayComments.length,
                                 separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.white12, indent: 20, endIndent: 20),
                                 itemBuilder: (context, index) {
                                   final entry = work.dayComments.entries.elementAt(index);
                                   final dayKey = entry.key;
                                   final comment = entry.value;
                                   final date = DateTime(work.currentMonth.year, work.currentMonth.month, dayKey);
                                   final formattedDate = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
                                   return ListTile(
                                     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                     title: Text('$formattedDate: $comment', style: AppTheme.bodyStyle.copyWith(fontSize: 15)),
                                     trailing: IconButton(
                                       icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.white38),
                                       onPressed: () => work.setDayComment(entry.key, ''), // Empty string removes comment
                                     ),
                                   );
                                 },
                               ),
                           ],
                         ),
                       ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
                       
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

  Widget _buildTimerCard(WorkProvider work) {
    return MinimalCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => work.setTimerMode(TimerMode.standard),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: work.timerMode == TimerMode.standard ? AppTheme.accentGold.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Таймер', style: TextStyle(color: work.timerMode == TimerMode.standard ? AppTheme.accentGold : AppTheme.white54, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => work.setTimerMode(TimerMode.pomodoro),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: work.timerMode == TimerMode.pomodoro ? AppTheme.accentGold.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Помодоро', style: TextStyle(color: work.timerMode == TimerMode.pomodoro ? AppTheme.accentGold : AppTheme.white54, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => work.setTimerMode(TimerMode.countdown),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: work.timerMode == TimerMode.countdown ? AppTheme.accentGold.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Обратный', style: TextStyle(color: work.timerMode == TimerMode.countdown ? AppTheme.accentGold : AppTheme.white54, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (work.timerMode == TimerMode.pomodoro) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: (work.isBreak ? AppTheme.accentGreen : AppTheme.accentGold).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                work.isBreak ? 'ПЕРЕРЫВ' : 'ФОКУС',
                style: TextStyle(
                  letterSpacing: 2,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: work.isBreak ? AppTheme.accentGreen : AppTheme.accentGold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          GestureDetector(
            onTap: work.timerMode == TimerMode.countdown ? () => _showCountdownDurationPicker(context, work) : null,
            child: Text(
              _formatTime(
                work.timerMode == TimerMode.standard 
                  ? work.timerSeconds 
                  : (work.timerMode == TimerMode.pomodoro 
                      ? work.pomodoroSecondsLeft.toDouble() 
                      : work.countdownSecondsLeft.toDouble())
              ),
              style: AppTheme.headlineStyle.copyWith(fontSize: 64, letterSpacing: -3, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimerButton(
                      icon: Icons.refresh_rounded,
                      onTap: () => work.resetTimer(),
                      isPrimary: false,
                    ),
                    const SizedBox(width: 24),
                    _TimerButton(
                      icon: work.isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      onTap: () => work.toggleTimer(),
                      isPrimary: true,
                    ),
                    const SizedBox(width: 24),
                    _TimerButton(
                      icon: Icons.check_circle_outline_rounded,
                      onTap: () {
                        if (work.timerMode == TimerMode.standard && work.timerSeconds > 0) {
                           _showSaveSessionDialog(context, work);
                        } else {
                           work.stopTimer();
                        }
                      },
                      isPrimary: false,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(WorkProvider work) {
    return MinimalCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(work.monthName, style: AppTheme.titleStyle.copyWith(fontSize: 16)),
              Row(
                children: [
                  _NavIconButton(icon: Icons.chevron_left_rounded, onTap: () => work.previousMonth()),
                  const SizedBox(width: 8),
                  _NavIconButton(icon: Icons.chevron_right_rounded, onTap: () => work.nextMonth()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'].map((d) => Expanded(
              child: Center(
                child: Text(d, style: AppTheme.captionStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(work),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(WorkProvider work) {
    final daysInMonth = work.daysInMonth;
    final firstDayOffset = work.firstDayOffset;
    final totalCells = ((daysInMonth + firstDayOffset) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final int day = index - firstDayOffset + 1;
        if (day < 1 || day > daysInMonth) return const SizedBox();

        final isToday = day == DateTime.now().day && work.currentMonth.month == DateTime.now().month;
        final hasHours = (work.workedDays[day] ?? 0) > 0;
        final isSelected = _selectedDay == day;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDay = day);
            _showDayEditSheet(context, work, day);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                ? AppTheme.accentGold.withValues(alpha: 0.2)
                : (hasHours ? AppTheme.white08 : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isToday ? AppTheme.accentGold : (isSelected ? AppTheme.accentGold.withValues(alpha: 0.4) : Colors.transparent),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isToday ? AppTheme.accentGold : (hasHours ? Colors.white : AppTheme.white38),
                  fontSize: 14,
                  fontWeight: isToday || hasHours ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void _showSettingsSheet(BuildContext context, WorkProvider work) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF13131F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Настройки ставки', style: AppTheme.titleStyle),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            work.setRateType(true);
                            setState((){});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: work.isHourlyRate ? AppTheme.accentGold.withValues(alpha: 0.2) : AppTheme.white08,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: work.isHourlyRate ? AppTheme.accentGold : Colors.transparent),
                            ),
                            alignment: Alignment.center,
                            child: Text('За час', style: TextStyle(color: work.isHourlyRate ? AppTheme.accentGold : AppTheme.white54, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            work.setRateType(false);
                            setState((){});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !work.isHourlyRate ? AppTheme.accentGold.withValues(alpha: 0.2) : AppTheme.white08,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: !work.isHourlyRate ? AppTheme.accentGold : Colors.transparent),
                            ),
                            alignment: Alignment.center,
                            child: Text('За смену', style: TextStyle(color: !work.isHourlyRate ? AppTheme.accentGold : AppTheme.white54, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Стоимость', style: AppTheme.captionStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: work.isHourlyRate ? work.hourlyRate.toString() : work.shiftRate.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.white05,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) {
                      final rate = double.tryParse(val) ?? 0.0;
                      if (work.isHourlyRate) {
                        work.setHourlyRate(rate);
                      } else {
                        work.setShiftRate(rate);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _showDayEditSheet(BuildContext context, WorkProvider work, int day) {
    bool isWorked = work.workedDays.containsKey(day);
    double hours = work.workedDays[day] ?? work.hoursPerDay;
    String comment = work.dayComments[day] ?? '';
    final hourController = TextEditingController(
      text: hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF13131F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('День $day', style: AppTheme.titleStyle),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Рабочий день', style: AppTheme.bodyStyle),
                      Switch(
                        value: isWorked,
                        activeColor: AppTheme.accentGold,
                        onChanged: (val) {
                          setState(() => isWorked = val);
                          if (val) {
                            work.setHoursForDay(day, hours);
                          } else {
                            work.setHoursForDay(day, 0);
                          }
                        },
                      ),
                    ],
                  ),
                  if (isWorked) ...[
                    const SizedBox(height: 16),
                    Text('Смена / Количество часов', style: AppTheme.captionStyle),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HourChip(label: '4ч', hours: 4, selected: hours == 4, onTap: () {
                          setState(() { hours = 4; hourController.text = '4'; });
                          work.setHoursForDay(day, 4);
                        }),
                        _HourChip(label: '6ч', hours: 6, selected: hours == 6, onTap: () {
                          setState(() { hours = 6; hourController.text = '6'; });
                          work.setHoursForDay(day, 6);
                        }),
                        _HourChip(label: '8ч', hours: 8, selected: hours == 8, onTap: () {
                          setState(() { hours = 8; hourController.text = '8'; });
                          work.setHoursForDay(day, 8);
                        }),
                        _HourChip(label: '10ч', hours: 10, selected: hours == 10, onTap: () {
                          setState(() { hours = 10; hourController.text = '10'; });
                          work.setHoursForDay(day, 10);
                        }),
                        _HourChip(label: '12ч', hours: 12, selected: hours == 12, onTap: () {
                          setState(() { hours = 12; hourController.text = '12'; });
                          work.setHoursForDay(day, 12);
                        }),
                        _HourChip(label: 'Смена', hours: work.hoursPerDay, selected: hours == work.hoursPerDay && hours != 4 && hours != 6 && hours != 8 && hours != 10 && hours != 12, onTap: () {
                          setState(() { hours = work.hoursPerDay; hourController.text = work.hoursPerDay.toString(); });
                          work.setHoursForDay(day, work.hoursPerDay);
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: hourController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
                      decoration: InputDecoration(
                        hintText: 'Или введите вручную...',
                        hintStyle: AppTheme.captionStyle,
                        filled: true,
                        fillColor: AppTheme.white05,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        suffixText: 'ч.',
                        suffixStyle: AppTheme.captionStyle,
                      ),
                      onChanged: (val) {
                        final h = double.tryParse(val);
                        if (h != null && h > 0) {
                          setState(() => hours = h);
                          work.setHoursForDay(day, h);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('Комментарий', style: AppTheme.captionStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: comment,
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
                    decoration: InputDecoration(
                      hintText: 'Оставьте заметку к смене',
                      hintStyle: AppTheme.captionStyle,
                      filled: true,
                      fillColor: AppTheme.white05,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) {
                      work.setDayComment(day, val);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _showCountdownDurationPicker(BuildContext context, WorkProvider work) {
    int minutes = work.countdownTotalDuration ~/ 60;
    final controller = TextEditingController(text: '$minutes');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131F),
        title: Text('Длительность (мин)', style: AppTheme.titleStyle),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.white05,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white38)),
          ),
          TextButton(
            onPressed: () {
              final m = int.tryParse(controller.text) ?? 10;
              work.setCountdownDuration(m * 60);
              Navigator.pop(ctx);
            },
            child: Text('OK', style: AppTheme.titleStyle.copyWith(color: AppTheme.accentGold)),
          ),
        ],
      ),
    );
  }

  void _showSaveSessionDialog(BuildContext context, WorkProvider work) {
    final hours = (work.timerSeconds / 3600).toStringAsFixed(1);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131F),
        title: Text('Сохранить сессию?', style: AppTheme.titleStyle),
        content: Text('Добавить $hours ч. к сегодняшнему дню?', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70)),
        actions: [
          TextButton(
            onPressed: () {
              work.stopTimer();
              Navigator.pop(ctx);
            },
            child: Text('Сбросить', style: AppTheme.bodyStyle.copyWith(color: AppTheme.errorRed)),
          ),
          TextButton(
            onPressed: () {
              final day = DateTime.now().day;
              final currentHours = work.workedDays[day] ?? 0;
              work.setHoursForDay(day, currentHours + (work.timerSeconds / 3600));
              work.stopTimer();
              Navigator.pop(ctx);
            },
            child: Text('Сохранить', style: AppTheme.titleStyle.copyWith(color: AppTheme.accentGreen)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WorkProvider work) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: font));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Report for ${work.monthName}', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Days worked: ${work.totalDaysWorked}'),
              pw.Text('Hours worked: ${work.totalHoursThisMonth}'),
              pw.Text('Earned: ${work.totalEarned.toInt()} RUB'),
              pw.SizedBox(height: 20),
              pw.Text('Daily details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Day', 'Hours', 'Comment'],
                  ...work.workedDays.entries.map((e) {
                    final day = e.key;
                    final hours = e.value;
                    final comment = work.dayComments[day] ?? '';
                    return [day.toString(), hours.toString(), comment];
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Report_${work.monthName}.pdf');
  }
}

class _WorkStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _WorkStatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return MinimalCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardIconPill(icon: icon, color: color),
          const SizedBox(height: 20),
          Text(value, style: AppTheme.headlineStyle.copyWith(fontSize: 28, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(title, style: AppTheme.captionStyle),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _TimerButton({required this.icon, required this.onTap, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isPrimary ? 20 : 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.white : AppTheme.white08,
          shape: BoxShape.circle,
          boxShadow: isPrimary ? [BoxShadow(color: Colors.white24, blurRadius: 20)] : null,
        ),
        child: Icon(icon, color: isPrimary ? Colors.black : AppTheme.white70, size: isPrimary ? 36 : 24),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: AppTheme.white08, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.white70, size: 18),
      ),
    );
  }
}

class _HourChip extends StatelessWidget {
  final String label;
  final double hours;
  final bool selected;
  final VoidCallback onTap;

  const _HourChip({required this.label, required this.hours, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentGold.withValues(alpha: 0.2) : AppTheme.white08,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.accentGold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accentGold : AppTheme.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

