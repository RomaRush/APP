import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/health_service.dart';

class HealthProvider extends ChangeNotifier {
  final HealthService _service = HealthService();
  
  bool _isAuthorized = false;
  int _steps = 0;
  double _calories = 0;
  bool _isLoading = false;
  
  // Mental Health
  String _mentalStatus = "Нормально";
  Color _mentalColor = Colors.green;
  
  // New Fields for Context Engine
  int _sleepQuality = 7; // 1-10
  String _stressLevel = 'Low'; // Low, Medium, High
  
  final List<Map<String, dynamic>> _moodHistory = [];

  // Notes
  String _sleepNote = "Пока пусто";
  String _dayNote = "Пока пусто";
  
  // Sleep (placeholder for now, can be linked to health later)
  double _sleepHours = 7.5;
  DateTime? _sleepStart;
  DateTime? _sleepEnd;
  
  // Sleep history for statistics
  List<Map<String, dynamic>> _sleepHistory = [];

  bool get isAuthorized => _isAuthorized;
  int get steps => _steps;
  double get calories => _calories;
  bool get isLoading => _isLoading;
  
  String get mentalStatus => _mentalStatus;
  Color get mentalColor => _mentalColor;
  int get sleepQuality => _sleepQuality;
  String get stressLevel => _stressLevel;
  List<Map<String, dynamic>> get moodHistory => _moodHistory;
  
  String get sleepNote => _sleepNote;
  String get dayNote => _dayNote;
  double get sleepHours => _sleepHours;
  DateTime? get sleepStart => _sleepStart;
  DateTime? get sleepEnd => _sleepEnd;
  List<Map<String, dynamic>> get sleepHistory => _sleepHistory;
  
  // Sleep statistics
  double get weeklySleepAverage {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekData = _sleepHistory.where((h) => 
      (h['date'] as DateTime).isAfter(weekAgo)
    ).toList();
    if (weekData.isEmpty) return _sleepHours;
    final total = weekData.fold<double>(0, (sum, h) => sum + (h['hours'] as double));
    return total / weekData.length;
  }
  
  double get monthlySleepAverage {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final monthData = _sleepHistory.where((h) => 
      (h['date'] as DateTime).isAfter(monthAgo)
    ).toList();
    if (monthData.isEmpty) return _sleepHours;
    final total = monthData.fold<double>(0, (sum, h) => sum + (h['hours'] as double));
    return total / monthData.length;
  }

  HealthProvider() {
    _loadData();
  }

  Future<void> connectHealth() async {
    _isLoading = true;
    notifyListeners();
    
    _isAuthorized = await _service.requestPermissions();
    if (_isAuthorized) {
      await fetchHealthData();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHealthData() async {
    if (!_isAuthorized) return;
    
    try {
      _steps = await _service.fetchTotalSteps();
      _calories = await _service.fetchCalories();
      
      // Also try to get sleep from Apple Health
      final healthSleep = await _service.fetchSleepHours();
      if (healthSleep > 0) {
        _sleepHours = healthSleep;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Provider Health Error: $e');
    }
  }
  
  // Persistence
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _sleepQuality = prefs.getInt('health_sleep_quality') ?? 7;
      _stressLevel = prefs.getString('health_stress_level') ?? 'Low';
      _mentalStatus = prefs.getString('health_mental_status') ?? "Нормально";
      
      final colorVal = prefs.getInt('health_mental_color');
      if (colorVal != null) {
        _mentalColor = Color(colorVal);
      }
      
      _sleepNote = prefs.getString('health_sleep_note') ?? "Пока пусто";
      _dayNote = prefs.getString('health_day_note') ?? "Пока пусто";
      
      final moodJson = prefs.getString('health_mood_history');
      if (moodJson != null) {
        final decoded = jsonDecode(moodJson) as List;
        _moodHistory.clear();
        for (var item in decoded) {
            _moodHistory.add({
              'status': item['status'],
              'color': Color(item['color']),
              'date': DateTime.parse(item['date']),
            });
        }
      }
      
      final sleepStartIso = prefs.getString('health_sleep_start');
      if (sleepStartIso != null) _sleepStart = DateTime.tryParse(sleepStartIso);
      
      final sleepEndIso = prefs.getString('health_sleep_end');
      if (sleepEndIso != null) _sleepEnd = DateTime.tryParse(sleepEndIso);
      
      // Load sleep history
      final sleepHistoryJson = prefs.getString('health_sleep_history');
      if (sleepHistoryJson != null) {
        final decoded = jsonDecode(sleepHistoryJson) as List;
        _sleepHistory.clear();
        for (var item in decoded) {
          _sleepHistory.add({
            'date': DateTime.parse(item['date']),
            'hours': (item['hours'] as num).toDouble(),
            'start': DateTime.parse(item['start']),
            'end': DateTime.parse(item['end']),
          });
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading health data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('health_sleep_quality', _sleepQuality);
      await prefs.setString('health_stress_level', _stressLevel);
      await prefs.setString('health_mental_status', _mentalStatus);
      await prefs.setInt('health_mental_color', _mentalColor.value);
      
      await prefs.setString('health_sleep_note', _sleepNote);
      await prefs.setString('health_day_note', _dayNote);
      
      final moodList = _moodHistory.map((m) => {
        'status': m['status'],
        'color': (m['color'] as Color).value,
        'date': (m['date'] as DateTime).toIso8601String(),
      }).toList();
      
      await prefs.setString('health_mood_history', jsonEncode(moodList));
      
      if (_sleepStart != null) await prefs.setString('health_sleep_start', _sleepStart!.toIso8601String());
      if (_sleepEnd != null) await prefs.setString('health_sleep_end', _sleepEnd!.toIso8601String());
      
      // Save sleep history
      final sleepList = _sleepHistory.map((s) => {
        'date': (s['date'] as DateTime).toIso8601String(),
        'hours': s['hours'],
        'start': (s['start'] as DateTime).toIso8601String(),
        'end': (s['end'] as DateTime).toIso8601String(),
      }).toList();
      await prefs.setString('health_sleep_history', jsonEncode(sleepList));
    } catch (e) {
      debugPrint('Error saving health data: $e');
    }
  }
  
  void updateSleepQuality(int quality) {
    _sleepQuality = quality.clamp(1, 10);
    _saveData();
    notifyListeners();
  }
  
  void updateStressLevel(String level) {
    _stressLevel = level;
    _saveData();
    notifyListeners();
  }
  
  void updateMentalHealth(String status, Color color) {
    _mentalStatus = status;
    _mentalColor = color;
    _moodHistory.add({'status': status, 'color': color, 'date': DateTime.now()});
    _saveData();
    notifyListeners();
  }
  
  void updateSleepNote(String note) {
    _sleepNote = note;
    _saveData();
    notifyListeners();
  }
  
  void updateDayNote(String note) {
    _dayNote = note;
    _saveData();
    notifyListeners();
  }
  
  void setSleepTimes(DateTime start, DateTime end) {
    _sleepStart = start;
    _sleepEnd = end;
    
    // Calculate hours
    double hours;
    if (end.isAfter(start)) {
      final duration = end.difference(start);
      hours = duration.inMinutes / 60.0;
    } else {
       // Handle cross-midnight (e.g. 23:00 to 07:00 next day)
       final duration = end.add(const Duration(days: 1)).difference(start);
       hours = duration.inMinutes / 60.0;
    }
    _sleepHours = hours;
    
    // Add to history
    _sleepHistory.add({
      'date': DateTime.now(),
      'hours': hours,
      'start': start,
      'end': end,
    });
    
    _saveData();
    notifyListeners();
  }
}
