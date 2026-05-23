import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/friend.dart';
import '../../core/models/story_entry.dart';
import '../home/story_view_screen.dart';

class FriendProfileScreen extends StatefulWidget {
  final Friend friend;

  const FriendProfileScreen({super.key, required this.friend});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  bool _isLoadingStories = false;

  ImageProvider _getStoryImageProvider(String path) {
    if (path.startsWith('data:image') || !path.startsWith('assets/')) {
      try {
        final base64Str = path.contains(',') ? path.split(',')[1] : path;
        final bytes = base64.decode(base64Str);
        return MemoryImage(bytes);
      } catch (_) {
        return const AssetImage('assets/images/home_background.png');
      }
    }
    return AssetImage(path);
  }

  Future<void> _openStoryViewer(int initialIndex) async {
    if (widget.friend.mockStories.isEmpty) return;

    setState(() {
      _isLoadingStories = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final List<StoryEntry> entries = [];

      for (int i = 0; i < widget.friend.mockStories.length; i++) {
        final story = widget.friend.mockStories[i];
        if (story.startsWith('assets/')) {
          try {
            final byteData = await rootBundle.load(story);
            final tempFile = File('${tempDir.path}/friend_story_${widget.friend.id}_$i.jpg');
            await tempFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
            entries.add(StoryEntry(
              file: tempFile,
              timestamp: DateTime.now().subtract(Duration(hours: widget.friend.mockStories.length - i)),
            ));
          } catch (_) {}
        } else {
          // base64
          try {
            final base64Str = story.contains(',') ? story.split(',')[1] : story;
            final bytes = base64.decode(base64Str);
            final tempFile = File('${tempDir.path}/friend_story_${widget.friend.id}_$i.png');
            await tempFile.writeAsBytes(bytes);
            entries.add(StoryEntry(
              file: tempFile,
              timestamp: DateTime.now().subtract(Duration(hours: widget.friend.mockStories.length - i)),
            ));
          } catch (_) {}
        }
      }

      if (mounted) {
        setState(() {
          _isLoadingStories = false;
        });

        if (entries.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось загрузить истории')),
          );
          return;
        }

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, _, __) => StoryViewScreen(
              stories: entries,
              initialIndex: initialIndex,
              userName: widget.friend.name,
              userAvatar: widget.friend.avatarPath ?? 'assets/images/user_avatar.png',
            ),
            opaque: false,
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки историй: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map unlocked achievement IDs to their details
    final List<Map<String, String>> achievementsList = [];
    final allAchievements = {
      'health_spirit': {'title': 'Здоровый дух', 'desc': 'Проверки здоровья 7 дней подряд', 'icon': '🥇'},
      'sleep_master': {'title': 'Мастер сна', 'desc': 'Сон 8+ часов 5 дней подряд', 'icon': '💤'},
      'steps_10k': {'title': '10,000 шагов', 'desc': '10,000 шагов за день', 'icon': '👣'},
      'master_planner': {'title': 'Мастер планирования', 'desc': 'Завершено 50 задач', 'icon': '📅'},
      'unstoppable': {'title': 'Неудержимый', 'desc': 'Использование приложения 30 дней', 'icon': '🔥'},
      'task_crusher': {'title': 'Покоритель задач', 'desc': '10 задач за один день', 'icon': '💥'},
      'budget_guardian': {'title': 'Страж бюджета', 'desc': 'Экономия 10% от дохода', 'icon': '🛡️'},
      'wealth_builder': {'title': 'Строитель капитала', 'desc': 'Накоплено 100,000₽', 'icon': '💰'},
      'no_impulse': {'title': 'Без импульсов', 'desc': 'Без импульсивных покупок неделю', 'icon': '🚫'},
      'first_note': {'title': 'Первая заметка', 'desc': 'Создана первая заметка', 'icon': '📝'},
      'first_task': {'title': 'Первая задача', 'desc': 'Выполнена первая задача', 'icon': '🎯'},
      'health_connected': {'title': 'Apple Health', 'desc': 'Подключен Apple Health', 'icon': '🍏'},
    };

    for (final id in widget.friend.mockAchievements) {
      if (allAchievements.containsKey(id)) {
        achievementsList.add({
          'title': allAchievements[id]!['title']!,
          'desc': allAchievements[id]!['desc']!,
          'icon': allAchievements[id]!['icon']!,
        });
      }
    }

    if (achievementsList.isEmpty) {
      achievementsList.add({
        'title': 'Первые шаги',
        'desc': 'Пользователь только начинает свой путь в DAYLO',
        'icon': '🌱',
      });
    }

    final stories = widget.friend.mockStories;

    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: Stack(
        children: [
          // Hero Wallpaper (blurred)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home_bg_dark.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      const Color(0xFF080810),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Loading stories overlay
          if (_isLoadingStories)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGreen),
                ),
              ),
            ),

          // Main Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                
                // Profile Avatar & Basic Info
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: AppTheme.accentGreen.withOpacity(0.15),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF13131F),
                          child: Text(
                            widget.friend.name.isNotEmpty ? widget.friend.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppTheme.accentGreen,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      Text(
                        widget.friend.name,
                        style: AppTheme.headlineStyle.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.friend.nickname,
                        style: AppTheme.captionStyle.copyWith(color: AppTheme.accentGreen, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          widget.friend.bio,
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stats row
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13131F),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.white05),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          value: 'Lvl ${widget.friend.level}',
                          label: '${widget.friend.points} очков',
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppTheme.white12),
                      Expanded(
                        child: _StatItem(
                          value: '${stories.length}',
                          label: 'Историй сегодня',
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppTheme.white12),
                      Expanded(
                        child: _StatItem(
                          value: '${widget.friend.mockAchievements.length}',
                          label: 'Достижений',
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut),

                const SizedBox(height: 32),

                // Section 1: Shared Stories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Истории дня', style: AppTheme.titleStyle),
                          if (stories.isNotEmpty)
                            GestureDetector(
                              onTap: () => _openStoryViewer(0),
                              child: Text('Смотреть все →', style: AppTheme.captionStyle.copyWith(color: AppTheme.accentGreen)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (stories.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13131F),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.white05),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.photo_library_outlined, color: AppTheme.white38, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  'Нет историй за сегодня',
                                  style: AppTheme.captionStyle.copyWith(color: AppTheme.white38),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: stories.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _openStoryViewer(index),
                                child: Container(
                                  width: 110,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.white12),
                                    image: DecorationImage(
                                      image: _getStoryImageProvider(stories[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Section 2: Achievements
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Достижения друга', style: AppTheme.titleStyle),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: achievementsList.length,
                        itemBuilder: (context, index) {
                          final ach = achievementsList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF13131F),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.white05),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  ach['icon']!,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ach['title']!,
                                        style: AppTheme.titleStyle.copyWith(fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ach['desc']!,
                                        style: AppTheme.captionStyle.copyWith(color: AppTheme.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.titleStyle.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(fontSize: 11, color: AppTheme.white38),
        ),
      ],
    );
  }
}
