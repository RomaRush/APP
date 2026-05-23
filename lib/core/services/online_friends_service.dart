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
}
