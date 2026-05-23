import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../models/story_entry.dart';
import '../models/friend.dart';
import '../services/online_friends_service.dart';
import 'dart:convert';
import 'dart:math';


class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final bool isUnlocked;
  final String criteriaLabel;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.isUnlocked,
    required this.criteriaLabel,
  });
  
  Achievement copyWith({bool? isUnlocked}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      iconPath: iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      criteriaLabel: criteriaLabel,
    );
  }
}

class UserProvider extends ChangeNotifier {
  String _name = 'RomaRush';
  String _subtitle = 'Владелец приложения DAYLO';
  String? _avatarPath;
  String _wallpaperPath = 'assets/images/home_bg_dark.png';
  int _userPoints = 0;
  String _myFriendCode = '';
  
  // Daily checklist: task_id -> isCompleted
  final Map<String, bool> _dailyTasks = {
    'note': false,
    'calories': false,
    'water': false,
    'mood': false,
    'breathing': false,
  };
  
  DateTime _lastDailyReset = DateTime.now();


  int _storyDaysCount = 0; 
  
  Locale _appLocale = const Locale('ru');
  bool _notificationsEnabled = true;

  Locale get appLocale => _appLocale;
  bool get notificationsEnabled => _notificationsEnabled;
  
  List<Friend> _friends = [];
  
  // Store actual content?
  List<StoryEntry> _storyImages = [];
  
  final List<Achievement> _achievements = [
    // Health Achievements
    Achievement(
      id: 'health_spirit',
      title: 'Здоровый дух',
      description: 'Выполняйте проверки здоровья 7 дней подряд.',
      iconPath: 'assets/images/achievements/achievement_health.png',
      isUnlocked: false,
      criteriaLabel: '0/7 дней',
    ),
    Achievement(
      id: 'sleep_master',
      title: 'Мастер сна',
      description: 'Спите 8+ часов 5 дней подряд.',
      iconPath: 'assets/images/achievements/achievement_health.png',
      isUnlocked: false,
      criteriaLabel: '0/5 дней',
    ),
    Achievement(
      id: 'steps_10k',
      title: '10,000 шагов',
      description: 'Пройдите 10,000 шагов за день.',
      iconPath: 'assets/images/achievements/achievement_health.png',
      isUnlocked: false,
      criteriaLabel: '0/10,000',
    ),
    
    // Productivity Achievements
    Achievement(
      id: 'master_planner',
      title: 'Мастер планирования',
      description: 'Завершите 50 задач.',
      iconPath: 'assets/images/achievements/achievement_tasks.png',
      isUnlocked: false,
      criteriaLabel: '0/50 задач',
    ),
    Achievement(
      id: 'unstoppable',
      title: 'Неудержимый',
      description: 'Используйте приложение 30 дней подряд.',
      iconPath: 'assets/images/achievements/achievement_streak.png',
      isUnlocked: false,
      criteriaLabel: '0/30 дней',
    ),
    Achievement(
      id: 'task_crusher',
      title: 'Покоритель задач',
      description: 'Завершите 10 задач за один день.',
      iconPath: 'assets/images/achievements/achievement_tasks.png',
      isUnlocked: false,
      criteriaLabel: '0/10 задач',
    ),
    
    // Finance Achievements
    Achievement(
      id: 'budget_guardian',
      title: 'Страж бюджета',
      description: 'Сэкономьте 10% от месячного дохода.',
      iconPath: 'assets/images/achievements/achievement_budget.png',
      isUnlocked: false,
      criteriaLabel: '0%',
    ),
    Achievement(
      id: 'wealth_builder',
      title: 'Строитель капитала',
      description: 'Накопите 100,000₽.',
      iconPath: 'assets/images/achievements/achievement_savings.png',
      isUnlocked: false,
      criteriaLabel: '0/100,000',
    ),
    Achievement(
      id: 'no_impulse',
      title: 'Без импульсов',
      description: 'Не совершайте импульсивных покупок неделю.',
      iconPath: 'assets/images/achievements/achievement_budget.png',
      isUnlocked: false,
      criteriaLabel: '0/7 дней',
    ),
    
    // First Steps (Easy to unlock)
    Achievement(
      id: 'first_note',
      title: 'Первая заметка',
      description: 'Создайте свою первую заметку.',
      iconPath: 'assets/images/achievements/achievement_tasks.png',
      isUnlocked: false,
      criteriaLabel: 'Создать',
    ),
    Achievement(
      id: 'first_task',
      title: 'Первая задача',
      description: 'Создайте и выполните первую задачу.',
      iconPath: 'assets/images/achievements/achievement_tasks.png',
      isUnlocked: false,
      criteriaLabel: 'Выполнить',
    ),
    Achievement(
      id: 'health_connected',
      title: 'Apple Health',
      description: 'Подключите Apple Health к приложению.',
      iconPath: 'assets/images/achievements/achievement_health.png',
      isUnlocked: false,
      criteriaLabel: 'Подключить',
    ),
  ];
  
  String get name => _name;
  String get subtitle => _subtitle;
  String? get avatarPath => _avatarPath;
  String get wallpaperPath => _wallpaperPath;
  
  int get storyDaysCount => _storyImages.length; // Dynamic based on images? Or separate counter?
  // Prompt says "increases as user adds". If I link it to the list length, it's easier.
  // But strictly, let's keep separate counters if needed. The screenshot shows 148, but only few images.
  // I'll make them standalone counters for flexibility, but update storyDaysCount when adding a story.
  
  int get friendsCount => _friends.length;
  List<Friend> get friends => _friends;
  int get achievementsCount => _achievements.where((a) => a.isUnlocked).length;
  List<Achievement> get achievements => _achievements;
  List<StoryEntry> get storyImages => _storyImages;
  int get userPoints => _userPoints;
  Map<String, bool> get dailyTasks => _dailyTasks;
  String get myFriendCode => _myFriendCode;

  UserProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _name = prefs.getString('user_name') ?? 'RomaRush';
      _subtitle = prefs.getString('user_subtitle') ?? 'Владелец приложения DAYLO';
      _avatarPath = prefs.getString('user_avatar_path');
      
      _storyDaysCount = prefs.getInt('user_story_days') ?? 0;
      
      final friendsJson = prefs.getString('user_friends_list');
      if (friendsJson != null) {
        final List<dynamic> decoded = jsonDecode(friendsJson);
        _friends = decoded.map((f) => Friend.fromJson(f)).toList();
      } else {
        _friends = [];
      }
      _wallpaperPath = prefs.getString('user_wallpaper_path') ?? 'assets/images/home_bg_dark.png';
      
      final localeCode = prefs.getString('user_locale');
      if (localeCode != null) {
        _appLocale = Locale(localeCode);
      }
      
      _notificationsEnabled = prefs.getBool('user_notifications_enabled') ?? true;
      _userPoints = prefs.getInt('user_points') ?? 0;
      
      final lastResetStr = prefs.getString('user_last_reset');
      if (lastResetStr != null) {
        _lastDailyReset = DateTime.parse(lastResetStr);
        _checkDailyReset();
      }
      
      final completedTasks = prefs.getStringList('user_completed_daily_tasks') ?? [];
      for (var taskKey in completedTasks) {
        if (_dailyTasks.containsKey(taskKey)) {
          _dailyTasks[taskKey] = true;
        }
      }
      
      final unlockedIds = prefs.getStringList('user_unlocked_achievements') ?? [];
      for (var id in unlockedIds) {
         final index = _achievements.indexWhere((a) => a.id == id);
         if (index != -1) {
           _achievements[index] = _achievements[index].copyWith(isUnlocked: true);
         }
      }
      
      _checkDailyReset();
      
      _myFriendCode = prefs.getString('user_friend_code') ?? '';
      if (_myFriendCode.isEmpty) {
        _myFriendCode = _generateFriendCode();
        await prefs.setString('user_friend_code', _myFriendCode);
      }
      
      syncProfileOnline();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('user_name', _name);
      await prefs.setString('user_subtitle', _subtitle);
      if (_avatarPath != null) {
        await prefs.setString('user_avatar_path', _avatarPath!);
      }
      await prefs.setInt('user_story_days', _storyDaysCount);
      
      final friendsJson = jsonEncode(_friends.map((f) => f.toJson()).toList());
      await prefs.setString('user_friends_list', friendsJson);
      await prefs.setString('user_wallpaper_path', _wallpaperPath);
      await prefs.setString('user_locale', _appLocale.languageCode);
      await prefs.setBool('user_notifications_enabled', _notificationsEnabled);
      
      final unlockedIds = _achievements
          .where((a) => a.isUnlocked)
          .map((a) => a.id)
          .toList();
      await prefs.setStringList('user_unlocked_achievements', unlockedIds);
      
      await prefs.setInt('user_points', _userPoints);
      await prefs.setString('user_last_reset', _lastDailyReset.toIso8601String());
      await prefs.setStringList('user_completed_daily_tasks', 
          _dailyTasks.entries.where((e) => e.value).map((e) => e.key).toList());
      await prefs.setString('user_friend_code', _myFriendCode);
      
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  void updateProfile(String newName, String newSubtitle) {
    _name = newName;
    _subtitle = newSubtitle;
    _saveData();
    syncProfileOnline();
    notifyListeners();
  }

  void setAvatar(String path) {
    _avatarPath = path;
    _saveData();
    notifyListeners();
  }

  void setWallpaper(String path) {
    _wallpaperPath = path;
    _saveData();
    notifyListeners();
  }

  void changeLanguage(Locale locale) {
    if (_appLocale == locale) return;
    _appLocale = locale;
    _saveData();
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await _saveData();
    notifyListeners();

    if (value) {
      final service = NotificationService();
      await service.init();
      await service.requestPermissions();
    }
  }

  Future<void> setAppLocale(String langCode) async {
    _appLocale = Locale(langCode);
    await _saveData();
    notifyListeners();
  }

  void addStoryImage(File image) {
    _storyImages.add(StoryEntry(file: image, timestamp: DateTime.now()));
    _storyDaysCount++;
    _saveData();
    notifyListeners();
  }

  void addStoryEntry(StoryEntry entry) {
    _storyImages.add(entry);
    _storyDaysCount++;
    _saveData();
    notifyListeners();
  }
  
  // Manual increment for stats (as implied by "adds from user")
  void addFriend(Friend friend) {
    if (!_friends.any((f) => f.nickname.toLowerCase() == friend.nickname.toLowerCase())) {
      _friends.add(friend);
      _saveData();
      notifyListeners();
    }
  }
  
  void removeFriend(String id) {
    _friends.removeWhere((f) => f.id == id);
    _saveData();
    notifyListeners();
  }
  
  void incrementAchievements() {
    // Legacy simple counter logic replaced by real list logic,
    // but keeping method to avoid breaking if called elsewhere.
    // Ideally we unlock a specific achievement here.
    notifyListeners();
  }
  
  void unlockAchievement(String id) {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index] = _achievements[index].copyWith(isUnlocked: true);
      _saveData();
      notifyListeners();
    }
  }

  void completeDailyTask(String taskKey) {
    _checkDailyReset();
    if (_dailyTasks.containsKey(taskKey) && !_dailyTasks[taskKey]!) {
      _dailyTasks[taskKey] = true;
      // Random points between 50 and 100
      final points = 50 + (DateTime.now().millisecond % 51); 
      _userPoints += points;
      _saveData();
      syncProfileOnline();
      notifyListeners();
    }
  }

  String _generateFriendCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    final code = List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
    return 'DL-$code';
  }

  void syncProfileOnline() {
    if (_myFriendCode.isNotEmpty) {
      OnlineFriendsService.publishProfile(
        code: _myFriendCode,
        name: _name,
        nickname: '@${_name.toLowerCase().replaceAll(' ', '_')}',
        bio: _subtitle,
        points: _userPoints,
        level: 1 + (_userPoints ~/ 1000),
      );
    }
  }

  Future<Friend?> searchAndAddFriendOnline(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == _myFriendCode) {
      throw Exception('Нельзя добавить самого себя');
    }
    if (_friends.any((f) => f.id == cleanCode)) {
      throw Exception('Этот пользователь уже в списке друзей');
    }
    final friend = await OnlineFriendsService.lookupProfile(cleanCode);
    if (friend != null) {
      _friends.add(friend);
      _saveData();
      notifyListeners();
      return friend;
    }
    return null;
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    if (now.year != _lastDailyReset.year || 
        now.month != _lastDailyReset.month || 
        now.day != _lastDailyReset.day) {
      _dailyTasks.updateAll((key, value) => false);
      _lastDailyReset = now;
      _saveData();
      notifyListeners();
    }
  }
}
