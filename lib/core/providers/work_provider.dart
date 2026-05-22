import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkProvider extends ChangeNotifier {
  Timer? _ticker;
  // Current month and year
  DateTime _currentMonth = DateTime.now();
  
  // Map of worked days: "YYYY-MM-DD" -> hours worked
  Map<String, double> _workedDays = {};
  
  // Comments for days: "YYYY-MM-DD" -> comment
  Map<String, String> _dayComments = {};
  
  // Hourly rate
  double _hourlyRate = 180.0;
  
  // Rate type (hourly or per shift)
  bool _isHourlyRate = true;
  double _shiftRate = 1500.0;
  
  // Standard hours per work day
  double _hoursPerDay = 8.0;

  // === TIMER STATE FIELDS ===
  bool _isTimerRunning = false;
  double _sessionSeconds = 0.0;
  DateTime? _timerStartTime;
  DateTime? _lastTickTime;
  String _workMode = 'standard';
  TimerMode _timerMode = TimerMode.standard;
  PomodoroState _pomodoroState = PomodoroState.work;
  int _pomodoroSecondsLeft = 25 * 60;
  int _pomodoroWorkDuration = 25 * 60;
  int _pomodoroShortBreak = 5 * 60;
  int _pomodoroLongBreak = 15 * 60;
  int _pomodoroCycles = 0;

  // Countdown mode
  int _countdownSecondsLeft = 600; // default 10 min
  int _countdownTotalDuration = 600;

  // Getters
  DateTime get currentMonth => _currentMonth;
  double get hourlyRate => _hourlyRate;
  bool get isHourlyRate => _isHourlyRate;
  double get shiftRate => _shiftRate;
  double get hoursPerDay => _hoursPerDay;
  bool get isTimerRunning => _isTimerRunning;
  double get currentSessionEarnings => (_sessionSeconds / 3600) * _hourlyRate; // Consider shift mode later if needed
  double get currentSessionDuration => _sessionSeconds;
  String get workMode => _workMode;

  bool get isBreak => _timerMode == TimerMode.pomodoro && 
      (_pomodoroState == PomodoroState.shortBreak || _pomodoroState == PomodoroState.longBreak);

  double get timerSeconds => _sessionSeconds;

  TimerMode get timerMode => _timerMode;
  PomodoroState get pomodoroState => _pomodoroState;
  int get pomodoroSecondsLeft => _pomodoroSecondsLeft;
  int get countdownSecondsLeft => _countdownSecondsLeft;
  int get countdownTotalDuration => _countdownTotalDuration;
  int get pomodoroTotalDuration => _getPomodoroTotalDuration();
  
  int _getPomodoroTotalDuration() {
    switch (_pomodoroState) {
      case PomodoroState.work: return _pomodoroWorkDuration;
      case PomodoroState.shortBreak: return _pomodoroShortBreak;
      case PomodoroState.longBreak: return _pomodoroLongBreak;
    }
  }
  
  // Get worked days for current month only
  Map<int, double> get workedDays {
    final prefix = _getMonthPrefix();
    final Map<int, double> result = {};
    _workedDays.forEach((key, value) {
      if (key.startsWith(prefix)) {
        final day = int.tryParse(key.split('-').last);
        if (day != null) result[day] = value;
      }
    });
    return result;
  }
  
  // Get comments for current month only
  Map<int, String> get dayComments {
    final prefix = _getMonthPrefix();
    final Map<int, String> result = {};
    _dayComments.forEach((key, value) {
      if (key.startsWith(prefix)) {
        final day = int.tryParse(key.split('-').last);
        if (day != null) result[day] = value;
      }
    });
    return result;
  }
  
  String _getMonthPrefix() {
    return '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
  }
  
  String _getDayKey(int day) {
    return '${_getMonthPrefix()}-${day.toString().padLeft(2, '0')}';
  }
  
  // Calculated values
  double get totalHoursThisMonth {
    return workedDays.values.fold(0.0, (sum, hours) => sum + hours);
  }
  
  int get totalDaysWorked {
    return workedDays.values.where((h) => h > 0).length;
  }
  
  double get totalEarned {
    if (_isHourlyRate) {
      return totalHoursThisMonth * _hourlyRate;
    } else {
      return totalDaysWorked * _shiftRate;
    }
  }
  
  // Initialize
  WorkProvider() {
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _loadData();
  }
  
  // Load data from SharedPreferences
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load hourly rate and settings
      _hourlyRate = prefs.getDouble('work_hourly_rate') ?? 180.0;
      _hoursPerDay = prefs.getDouble('work_hours_per_day') ?? 8.0;
      _isHourlyRate = prefs.getBool('work_is_hourly_rate') ?? true;
      _shiftRate = prefs.getDouble('work_shift_rate') ?? 1500.0;
      
      // Load worked days
      final workedDaysJson = prefs.getString('work_worked_days');
      if (workedDaysJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(workedDaysJson);
        _workedDays = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
      
      // Load comments
      final commentsJson = prefs.getString('work_comments');
      if (commentsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(commentsJson);
        _dayComments = decoded.map((k, v) => MapEntry(k, v.toString()));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading work data: $e');
    }
  }
  
  // Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setDouble('work_hourly_rate', _hourlyRate);
      await prefs.setDouble('work_hours_per_day', _hoursPerDay);
      await prefs.setBool('work_is_hourly_rate', _isHourlyRate);
      await prefs.setDouble('work_shift_rate', _shiftRate);
      await prefs.setString('work_worked_days', jsonEncode(_workedDays));
      await prefs.setString('work_comments', jsonEncode(_dayComments));
    } catch (e) {
      debugPrint('Error saving work data: $e');
    }
  }
  
  // Toggle work day
  void toggleWorkDay(int day) {
    final key = _getDayKey(day);
    if (_workedDays.containsKey(key) && _workedDays[key]! > 0) {
      _workedDays.remove(key);
    } else {
      _workedDays[key] = _hoursPerDay;
    }
    _saveData();
    notifyListeners();
  }
  
  // Set hours for a specific day
  void setHoursForDay(int day, double hours) {
    final key = _getDayKey(day);
    if (hours > 0) {
      _workedDays[key] = hours;
    } else {
      _workedDays.remove(key);
    }
    _saveData();
    notifyListeners();
  }
  
  // Add comment to day
  void setDayComment(int day, String comment) {
    final key = _getDayKey(day);
    if (comment.isNotEmpty) {
      _dayComments[key] = comment;
    } else {
      _dayComments.remove(key);
    }
    _saveData();
    notifyListeners();
  }
  
  // Update hourly rate
  void setHourlyRate(double rate) {
    _hourlyRate = rate;
    _saveData();
    notifyListeners();
  }
  
  void setShiftRate(double rate) {
    _shiftRate = rate;
    _saveData();
    notifyListeners();
  }
  
  void setRateType(bool isHourly) {
    _isHourlyRate = isHourly;
    _saveData();
    notifyListeners();
  }
  
  // Update hours per day
  void setHoursPerDay(double hours) {
    _hoursPerDay = hours;
    _saveData();
    notifyListeners();
  }
  
  // Navigate months
  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    notifyListeners();
  }
  
  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    notifyListeners();
  }
  
  // Get days in current month
  int get daysInMonth {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }
  
  // Get first weekday of month (1 = Monday, 7 = Sunday)
  int get firstWeekday {
    return DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
  }
  
  // Month name in Russian
  String get monthName {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return months[_currentMonth.month - 1];
  }
  
  // Get all worked days data for export
  Map<String, double> get allWorkedDays => Map.from(_workedDays);
  Map<String, String> get allDayComments => Map.from(_dayComments);

  // Timer Methods
  void startTimer() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;
    _timerStartTime = DateTime.now();
    _lastTickTime = DateTime.now();
    
    // Start internal ticker
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      tickTimer();
    });
    
    // Schedule notification for Pomodoro
    if (_timerMode == TimerMode.pomodoro) {
       _schedulePomodoroNotification();
    }
    
    notifyListeners();
  }

  void stopTimer() {
    if (!_isTimerRunning) return;
    _isTimerRunning = false;
    _timerStartTime = null;
    _lastTickTime = null;
    _ticker?.cancel();
    
    // Cancel any scheduled pomodoro notifications
    NotificationService().cancelNotification(1001);
    
    // Reset session seconds when stopping completely
    _sessionSeconds = 0;
    notifyListeners();
  }

  void pauseTimer() {
    if (!_isTimerRunning) return;
    _isTimerRunning = false;
    _ticker?.cancel();
    // Keep _sessionSeconds and timerStartTime for resume functionality
    notifyListeners();
  }

  void resumeTimer() {
    if (_isTimerRunning) return;
    if (_timerStartTime == null) return;
    
    _isTimerRunning = true;
    _lastTickTime = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      tickTimer();
    });
    notifyListeners();
  }

  void tickTimer() {
    if (_isTimerRunning) {
      final now = DateTime.now();
      final delta = _lastTickTime != null ? now.difference(_lastTickTime!).inMilliseconds / 1000.0 : 0.0;
      _lastTickTime = now;

      if (_timerMode == TimerMode.standard) {
        _sessionSeconds += delta;
      } else if (_timerMode == TimerMode.pomodoro) {
        // Pomodoro Countdown
        if (_pomodoroSecondsLeft > 0) {
          // Subtract exactly the time passed to be accurate after background return
          _pomodoroSecondsLeft -= delta.round();
          if (_pomodoroSecondsLeft < 0) _pomodoroSecondsLeft = 0;
        } 
        
        if (_pomodoroSecondsLeft <= 0) {
          // Timer finished
          _handlePomodoroFinish();
        }
      } else if (_timerMode == TimerMode.countdown) {
        if (_countdownSecondsLeft > 0) {
          _countdownSecondsLeft -= delta.round();
          if (_countdownSecondsLeft < 0) _countdownSecondsLeft = 0;
        }
        if (_countdownSecondsLeft <= 0) {
          _isTimerRunning = false;
          _ticker?.cancel();
          // Optionally notify
        }
      }
      notifyListeners();
    }
  }

  void _schedulePomodoroNotification() {
    final finishTime = DateTime.now().add(Duration(seconds: _pomodoroSecondsLeft));
    final title = _pomodoroState == PomodoroState.work ? "Время работать вышло!" : "Перерыв окончен!";
    final body = _pomodoroState == PomodoroState.work ? "Пора немного отдохнуть." : "Пора возвращаться к делам.";
    
    NotificationService().scheduleNotification(
      id: 1001,
      title: title,
      body: body,
      scheduledDate: finishTime,
    );
  }
  
  void _handlePomodoroFinish() {
    _isTimerRunning = false;
    _timerStartTime = null;
    
    // Play sound or notify (UI will handle)
    
    if (_pomodoroState == PomodoroState.work) {
      _pomodoroCycles++;
      
      // Auto-switch to break
      if (_pomodoroCycles % 4 == 0) {
        _pomodoroState = PomodoroState.longBreak;
        _pomodoroSecondsLeft = _pomodoroLongBreak;
      } else {
        _pomodoroState = PomodoroState.shortBreak;
        _pomodoroSecondsLeft = _pomodoroShortBreak;
      }
    } else {
      // Break finished, back to work
      _pomodoroState = PomodoroState.work;
      _pomodoroSecondsLeft = _pomodoroWorkDuration;
    }
    
    // Pomodoro does NOT add hours to work schedule
    notifyListeners();
  }
  
  void setTimerMode(TimerMode mode) {
    _timerMode = mode;
    _isTimerRunning = false;
    if (mode == TimerMode.pomodoro) {
      _pomodoroState = PomodoroState.work;
      _pomodoroSecondsLeft = _pomodoroWorkDuration;
    } else if (mode == TimerMode.countdown) {
      _countdownSecondsLeft = _countdownTotalDuration;
    }
    notifyListeners();
  }

  void setCountdownDuration(int seconds) {
    _countdownTotalDuration = seconds;
    _countdownSecondsLeft = seconds;
    notifyListeners();
  }

  void resetTimer() {
    _isTimerRunning = false;
    _ticker?.cancel();
    if (_timerMode == TimerMode.standard) {
      _sessionSeconds = 0;
    } else if (_timerMode == TimerMode.pomodoro) {
      _pomodoroState = PomodoroState.work;
      _pomodoroSecondsLeft = _pomodoroWorkDuration;
    } else if (_timerMode == TimerMode.countdown) {
      _countdownSecondsLeft = _countdownTotalDuration;
    }
    notifyListeners();
  }
  
  void skipPomodoroStage() {
    _handlePomodoroFinish();
    notifyListeners();
  }
  
  void setWorkMode(String mode) {
    _workMode = mode;
    notifyListeners();
  }

  void toggleTimer() {
    if (_isTimerRunning) {
      pauseTimer();
    } else if (_sessionSeconds > 0) {
      resumeTimer();
    } else {
      startTimer();
    }
  }


  int get firstDayOffset => firstWeekday - 1;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

enum TimerMode { standard, pomodoro, countdown }
enum PomodoroState { work, shortBreak, longBreak }
