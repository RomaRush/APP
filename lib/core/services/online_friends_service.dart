import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/friend.dart';

class OnlineFriendsService {
  static const String _setBaseUrl = 'https://setget.net/set/daylo_friend_';
  static const String _getBaseUrl = 'https://setget.net/get/daylo_friend_';

  static Future<bool> publishProfile({
    required String code,
    required String name,
    required String nickname,
    required String bio,
    required int points,
    required int level,
    required List<String> mockStories,
    required List<String> mockAchievements,
  }) async {
    try {
      final url = Uri.parse('$_setBaseUrl$code');
      final body = jsonEncode({
        'id': code,
        'name': name,
        'nickname': nickname,
        'bio': bio,
        'points': points,
        'level': level,
        'mockStories': mockStories,
        'mockAchievements': mockAchievements,
      });
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // ignore: avoid_print
      print('Error publishing profile online: $e');
      return false;
    }
  }

  static Future<Friend?> lookupProfile(String code) async {
    try {
      final url = Uri.parse('$_getBaseUrl$code');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('value')) {
          final val = decoded['value'];
          if (val != null) {
            return Friend.fromJson(val);
          }
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error looking up profile: $e');
      return null;
    }
  }

  static Future<void> registerInGlobalDirectory({
    required String code,
    required String name,
    required String nickname,
    required int points,
    required int level,
  }) async {
    try {
      final getUrl = Uri.parse('https://setget.net/get/daylo_global_registry');
      final response = await http.get(getUrl);
      List<dynamic> registry = [];
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('value')) {
          registry = List<dynamic>.from(decoded['value'] ?? []);
        }
      }
      
      final index = registry.indexWhere((item) => item['code'] == code);
      final itemData = {
        'code': code,
        'name': name,
        'nickname': nickname,
        'points': points,
        'level': level,
      };
      if (index != -1) {
        registry[index] = itemData;
      } else {
        registry.add(itemData);
      }
      
      if (registry.length > 100) {
        registry.removeAt(0);
      }
      
      final setUrl = Uri.parse('https://setget.net/set/daylo_global_registry');
      await http.post(
        setUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registry),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error updating global registry: $e');
    }
  }

  static Future<List<Friend>> fetchGlobalDirectory() async {
    try {
      final url = Uri.parse('https://setget.net/get/daylo_global_registry');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('value')) {
          final list = decoded['value'] as List<dynamic>;
          return list.map((item) => Friend(
            id: item['code'] ?? '',
            name: item['name'] ?? '',
            nickname: item['nickname'] ?? '',
            points: item['points'] ?? 0,
            level: item['level'] ?? 1,
            bio: 'Пользователь DAYLO',
          )).toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching global directory: $e');
    }
    return [];
  }
}
