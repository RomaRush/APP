import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/friend.dart';

class FriendProfileScreen extends StatelessWidget {
  final Friend friend;

  const FriendProfileScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    // Generate some mock achievements for visual completeness
    final List<Map<String, String>> achievementsList = [
      {
        'title': 'Здоровый дух',
        'desc': 'Проверка здоровья в течение 7 дней',
        'icon': '🥇',
      },
      {
        'title': 'Первый шаг',
        'desc': 'Выполнена первая задача в DAYLO',
        'icon': '🎯',
      },
      {
        'title': 'Мастер фокуса',
        'desc': 'Завершено 5 сессий работы',
        'icon': '⏱️',
      },
    ];

    // Mock history/shared stories for the friend
    final List<String> mockStoriesList = [
      'assets/images/wallpapers/IMG_0062.jpeg',
      'assets/images/wallpapers/IMG_0063.jpeg',
      'assets/images/wallpapers/IMG_0064.jpeg',
      'assets/images/wallpapers/IMG_0065.jpeg',
    ];

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
          
          // Back button and title
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
                            friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
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
                        friend.name,
                        style: AppTheme.headlineStyle.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friend.nickname,
                        style: AppTheme.captionStyle.copyWith(color: AppTheme.accentGreen, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          friend.bio,
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
                          value: 'Lvl ${friend.level}',
                          label: '${friend.points} очков',
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppTheme.white12),
                      Expanded(
                        child: _StatItem(
                          value: '${mockStoriesList.length}',
                          label: 'Дней в DAYLO',
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppTheme.white12),
                      Expanded(
                        child: _StatItem(
                          value: '${achievementsList.length}',
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
                          Text('Все →', style: AppTheme.captionStyle.copyWith(color: AppTheme.accentGreen)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: mockStoriesList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.white12),
                                image: DecorationImage(
                                  image: AssetImage(mockStoriesList[index]),
                                  fit: BoxFit.cover,
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
