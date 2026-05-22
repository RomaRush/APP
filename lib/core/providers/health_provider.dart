import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/health_service.dart';

class HeartRateEntry {
  final int bpm;
  final DateTime time;
  HeartRateEntry({required this.bpm, required this.time});

  Map<String, dynamic> toJson() => {
    'bpm': bpm,
    'time': time.toIso8601String(),
  };

  factory HeartRateEntry.fromJson(Map<String, dynamic> json) => HeartRateEntry(
    bpm: json['bpm'] as int,
    time: DateTime.parse(json['time'] as String),
  );
}

class HealthProvider extends ChangeNotifier {
  final HealthService _service = HealthService();
  
  bool _isAuthorized = false;
  int _steps = 0;
  double _calories = 0;
  bool _isLoading = false;
  
  // Mental Health
  String _mentalStatus = "Нормально";
  Color _mentalColor = Colors.green;
  
  // Context Engine
  int _sleepQuality = 7;
  String _stressLevel = 'Low';
  
  final List<Map<String, dynamic>> _moodHistory = [];

  // Notes
  String _sleepNote = "Пока пусто";
  String _dayNote = "Пока пусто";
  
  // Sleep
  double _sleepHours = 7.5;
  DateTime? _sleepStart;
  DateTime? _sleepEnd;
  
  // Sleep history
  List<Map<String, dynamic>> _sleepHistory = [];

  // Heart Rate
  List<HeartRateEntry> _heartRateHistory = [];

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
  List<HeartRateEntry> get heartRateHistory => _heartRateHistory;

  // Latest heart rate
  int? get latestHeartRate => _heartRateHistory.isEmpty ? null : _heartRateHistory.last.bpm;

  // Average heart rate (last 7 entries)
  double get averageHeartRate {
    if (_heartRateHistory.isEmpty) return 0;
    final recent = _heartRateHistory.reversed.take(7).toList();
    return recent.fold<int>(0, (s, e) => s + e.bpm) / recent.length;
  }

  // Heart rate zone
  String get heartRateZone {
    final bpm = latestHeartRate;
    if (bpm == null) return '—';
    if (bpm < 60) return 'Низкий';
    if (bpm < 100) return 'Норма';
    if (bpm < 140) return 'Повышенный';
    return 'Высокий';
  }

  Color get heartRateZoneColor {
    final bpm = latestHeartRate;
    if (bpm == null) return Colors.grey;
    if (bpm < 60) return const Color(0xFF42A5F5);
    if (bpm < 100) return const Color(0xFF66BB6A);
    if (bpm < 140) return const Color(0xFFFFCA28);
    return const Color(0xFFEF5350);
  }

  // Sleep statistics
  double get weeklySleepAverage {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekData = _sleepHistory.where((h) => (h['date'] as DateTime).isAfter(weekAgo)).toList();
    if (weekData.isEmpty) return _sleepHours;
    final total = weekData.fold<double>(0, (sum, h) => sum + (h['hours'] as double));
    return total / weekData.length;
  }
  
  double get monthlySleepAverage {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final monthData = _sleepHistory.where((h) => (h['date'] as DateTime).isAfter(monthAgo)).toList();
    if (monthData.isEmpty) return _sleepHours;
    final total = monthData.fold<double>(0, (sum, h) => sum + (h['hours'] as double));
    return total / monthData.length;
  }

  // Last 7 mood entries
  List<Map<String, dynamic>> get recentMoodHistory {
    return _moodHistory.reversed.take(7).toList().reversed.toList();
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
      
      final healthSleep = await _service.fetchSleepHours();
      if (healthSleep > 0) {
        _sleepHours = healthSleep;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Provider Health Error: $e');
    }
  }
  
  // ── Persistence ─────────────────────────────────────────────────────────────

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

      // Load heart rate history
      final hrJson = prefs.getString('health_heart_rate_history');
      if (hrJson != null) {
        final decoded = jsonDecode(hrJson) as List;
        _heartRateHistory = decoded.map((e) => HeartRateEntry.fromJson(e)).toList();
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
      await prefs.setInt('health_mental_color', _mentalColor.toARGB32());
      
      await prefs.setString('health_sleep_note', _sleepNote);
      await prefs.setString('health_day_note', _dayNote);
      
      final moodList = _moodHistory.map((m) => {
        'status': m['status'],
        'color': (m['color'] as Color).toARGB32(),
        'date': (m['date'] as DateTime).toIso8601String(),
      }).toList();
      
      await prefs.setString('health_mood_history', jsonEncode(moodList));
      
      if (_sleepStart != null) await prefs.setString('health_sleep_start', _sleepStart!.toIso8601String());
      if (_sleepEnd != null) await prefs.setString('health_sleep_end', _sleepEnd!.toIso8601String());
      
      final sleepList = _sleepHistory.map((s) => {
        'date': (s['date'] as DateTime).toIso8601String(),
        'hours': s['hours'],
        'start': (s['start'] as DateTime).toIso8601String(),
        'end': (s['end'] as DateTime).toIso8601String(),
      }).toList();
      await prefs.setString('health_sleep_history', jsonEncode(sleepList));

      // Save heart rate history
      await prefs.setString(
        'health_heart_rate_history',
        jsonEncode(_heartRateHistory.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving health data: $e');
    }
  }

  // ── Setters ──────────────────────────────────────────────────────────────────

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
  
  void setSleepTimes(DateTime start, DateTime end, {DateTime? date}) {
    double newHours;
    if (end.isAfter(start)) {
      final duration = end.difference(start);
      newHours = duration.inMinutes / 60.0;
    } else {
      final duration = end.add(const Duration(days: 1)).difference(start);
      newHours = duration.inMinutes / 60.0;
    }
    
    final entryDate = date ?? DateTime.now();
    final dateOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);
    
    double existingHours = 0;
    int existingIndex = _sleepHistory.indexWhere((h) {
      final hDate = h['date'] as DateTime;
      return DateTime(hDate.year, hDate.month, hDate.day) == dateOnly;
    });

    if (existingIndex != -1) {
      existingHours = (_sleepHistory[existingIndex]['hours'] as num).toDouble();
      _sleepHistory.removeAt(existingIndex);
    }
    
    double totalHours = existingHours + newHours;
    if (totalHours > 24.0) totalHours = 24.0;
    
    _sleepHours = totalHours;
    _sleepStart = start;
    _sleepEnd = end;

    _sleepHistory.add({
      'date': entryDate,
      'hours': totalHours,
      'start': start,
      'end': end,
    });
    
    _saveData();
    notifyListeners();
  }

  void addHeartRate(int bpm) {
    _heartRateHistory.add(HeartRateEntry(bpm: bpm, time: DateTime.now()));
    // Keep only last 50 entries
    if (_heartRateHistory.length > 50) {
      _heartRateHistory = _heartRateHistory.sublist(_heartRateHistory.length - 50);
    }
    _saveData();
    notifyListeners();
  }
}
