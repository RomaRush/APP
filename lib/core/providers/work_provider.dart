import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkProvider extends ChangeNotifier {
  // Current month and year
  DateTime _currentMonth = DateTime.now();
  
  // Map of worked days: "YYYY-MM-DD" -> hours worked
  Map<String, double> _workedDays = {};
  
  // Comments for days: "YYYY-MM-DD" -> comment
  Map<String, String> _dayComments = {};
  
  // Hourly rate
  double _hourlyRate = 180.0;
  
  // Standard hours per work day
  double _hoursPerDay = 8.0;
  
  // Weekend plans
  List<String> _weekendPlans = [];

  // Flow & Earn (Timer)
  bool _isTimerRunning = false;
  DateTime? _timerStartTime;
  double _sessionSeconds = 0;
  
  // Pomodoro Logic
  TimerMode _timerMode = TimerMode.standard;
  PomodoroState _pomodoroState = PomodoroState.work;
  int _pomodoroSecondsLeft = 25 * 60; // Default 25 min
  int _pomodoroWorkDuration = 25 * 60;
  int _pomodoroShortBreak = 5 * 60;
  int _pomodoroLongBreak = 15 * 60;
  int _pomodoroCycles = 0;
  
  // Work Mode for Synergy
  String _workMode = 'Normal'; // Normal, Light, Deep
  
  // Getters
  DateTime get currentMonth => _currentMonth;
  double get hourlyRate => _hourlyRate;
  double get hoursPerDay => _hoursPerDay;
  List<String> get weekendPlans => _weekendPlans;
  bool get isTimerRunning => _isTimerRunning;
  double get currentSessionEarnings => (_sessionSeconds / 3600) * _hourlyRate;
  double get currentSessionDuration => _sessionSeconds;
  String get workMode => _workMode;
  
  TimerMode get timerMode => _timerMode;
  PomodoroState get pomodoroState => _pomodoroState;
  int get pomodoroSecondsLeft => _pomodoroSecondsLeft;
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
    return totalHoursThisMonth * _hourlyRate;
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
      
      // Load hourly rate
      _hourlyRate = prefs.getDouble('work_hourly_rate') ?? 180.0;
      _hoursPerDay = prefs.getDouble('work_hours_per_day') ?? 8.0;
      
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
      
      // Load weekend plans
      final plansJson = prefs.getStringList('work_weekend_plans');
      if (plansJson != null) {
        _weekendPlans = plansJson;
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
      await prefs.setString('work_worked_days', jsonEncode(_workedDays));
      await prefs.setString('work_comments', jsonEncode(_dayComments));
      await prefs.setStringList('work_weekend_plans', _weekendPlans);
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
  
  // Weekend plans
  void addWeekendPlan(String plan) {
    _weekendPlans.add(plan);
    _saveData();
    notifyListeners();
  }
  
  void removeWeekendPlan(int index) {
    if (index >= 0 && index < _weekendPlans.length) {
      _weekendPlans.removeAt(index);
      _saveData();
      notifyListeners();
    }
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
    notifyListeners();
  }

  void stopTimer() {
    if (!_isTimerRunning) return;
    _isTimerRunning = false;
    _timerStartTime = null;
    
    // Timer earnings are for display only, not added to work schedule
    _sessionSeconds = 0;
    notifyListeners();
  }

  void tickTimer() {
    if (_isTimerRunning) {
      if (_timerMode == TimerMode.standard) {
        _sessionSeconds += 1;
      } else {
        // Pomodoro Countdown
        if (_pomodoroSecondsLeft > 0) {
          _pomodoroSecondsLeft -= 1;
        } else {
          // Timer finished
          _handlePomodoroFinish();
        }
      }
      notifyListeners();
    }
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
}

enum TimerMode { standard, pomodoro }
enum PomodoroState { work, shortBreak, longBreak }
