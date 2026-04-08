import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg_dark.png',
              fit: BoxFit.cover,
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Достижения',
                        style: AppTheme.headlineStyle.copyWith(fontSize: 28),
                      ),
                    ],
                  ),
                ),
                
                // Stats Summary Card
                Consumer<UserProvider>(
                  builder: (context, user, _) {
                    final unlocked = user.achievements.where((a) => a.isUnlocked).length;
                    final total = user.achievements.length;
                    final progress = total > 0 ? unlocked / total : 0.0;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.withOpacity(0.15),
                            Colors.orange.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$unlocked / $total',
                                    style: AppTheme.headlineStyle.copyWith(
                                      fontSize: 32,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  Text(
                                    'достижений получено',
                                    style: TextStyle(color: Colors.white60, fontSize: 14),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 6,
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation(Colors.amber),
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: AppTheme.titleStyle.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation(Colors.amber),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Achievement Categories
                Expanded(
                  child: Consumer<UserProvider>(
                    builder: (context, user, _) {
                      // Group achievements
                      final healthAchievements = user.achievements.where((a) => 
                        a.id.contains('health') || a.id.contains('sleep') || a.id.contains('steps')
                      ).toList();
                      final financeAchievements = user.achievements.where((a) => 
                        a.id.contains('budget') || a.id.contains('wealth') || a.id.contains('savings')
                      ).toList();
                      final productivityAchievements = user.achievements.where((a) => 
                        a.id.contains('task') || a.id.contains('planner') || a.id.contains('streak')
                      ).toList();
                      final otherAchievements = user.achievements.where((a) => 
                        !healthAchievements.contains(a) && 
                        !financeAchievements.contains(a) && 
                        !productivityAchievements.contains(a)
                      ).toList();
                      
                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          if (healthAchievements.isNotEmpty) ...[
                            _buildCategoryHeader('🏃 Здоровье', healthAchievements.where((a) => a.isUnlocked).length, healthAchievements.length),
                            const SizedBox(height: 12),
                            ...healthAchievements.map((a) => _AchievementCard(achievement: a)),
                          ],
                          if (financeAchievements.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildCategoryHeader('💰 Финансы', financeAchievements.where((a) => a.isUnlocked).length, financeAchievements.length),
                            const SizedBox(height: 12),
                            ...financeAchievements.map((a) => _AchievementCard(achievement: a)),
                          ],
                          if (productivityAchievements.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildCategoryHeader('⚡ Продуктивность', productivityAchievements.where((a) => a.isUnlocked).length, productivityAchievements.length),
                            const SizedBox(height: 12),
                            ...productivityAchievements.map((a) => _AchievementCard(achievement: a)),
                          ],
                          if (otherAchievements.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildCategoryHeader('🏆 Другие', otherAchievements.where((a) => a.isUnlocked).length, otherAchievements.length),
                            const SizedBox(height: 12),
                            ...otherAchievements.map((a) => _AchievementCard(achievement: a)),
                          ],
                          const SizedBox(height: 100),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryHeader(String title, int unlocked, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: 18),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$unlocked/$total',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = achievement.isUnlocked ? Colors.amber : Colors.white30;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isUnlocked 
            ? Colors.amber.withOpacity(0.4) 
            : Colors.white.withOpacity(0.1),
          width: achievement.isUnlocked ? 1.5 : 1,
        ),
        boxShadow: achievement.isUnlocked ? [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: achievement.isUnlocked ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Image.asset(
                      achievement.iconPath,
                      width: 32,
                      height: 32,
                      opacity: AlwaysStoppedAnimation(achievement.isUnlocked ? 1.0 : 0.4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: TextStyle(
                          color: achievement.isUnlocked ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: achievement.isUnlocked 
                        ? Colors.green.withOpacity(0.5)
                        : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    achievement.isUnlocked ? '✓' : achievement.criteriaLabel,
                    style: TextStyle(
                      color: achievement.isUnlocked ? Colors.green : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
