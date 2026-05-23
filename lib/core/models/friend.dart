class Friend {
  final String id;
  final String name;
  final String nickname;
  final String bio;
  final String? avatarPath;
  final int points;
  final int level;
  final List<String> mockStories; // Paths or mock URLs to show stories
  final List<String> mockAchievements; // Unlocked achievement IDs

  Friend({
    required this.id,
    required this.name,
    required this.nickname,
    this.bio = 'Пользователь DAYLO',
    this.avatarPath,
    this.points = 120,
    this.level = 1,
    this.mockStories = const [],
    this.mockAchievements = const [],
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      bio: (json['bio'] ?? 'Пользователь DAYLO') as String,
      avatarPath: json['avatarPath'] as String?,
      points: (json['points'] ?? 120) as int,
      level: (json['level'] ?? 1) as int,
      mockStories: List<String>.from(json['mockStories'] ?? []),
      mockAchievements: List<String>.from(json['mockAchievements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'bio': bio,
      'avatarPath': avatarPath,
      'points': points,
      'level': level,
      'mockStories': mockStories,
      'mockAchievements': mockAchievements,
    };
  }
}
