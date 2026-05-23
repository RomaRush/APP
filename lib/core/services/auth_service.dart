import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'https://kvdb.io/DayloAccountsBucket_2026_v2/';

  static String _encodeEmail(String email) {
    return base64Url.encode(utf8.encode(email.trim().toLowerCase()));
  }

  static Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String name,
    required String friendCode,
  }) async {
    try {
      final key = _encodeEmail(email);
      final url = Uri.parse('$_baseUrl$key');

      // Check if user already exists
      final checkResponse = await http.get(url);
      if (checkResponse.statusCode == 200) {
        throw Exception('Аккаунт с таким email уже существует');
      }

      final profileData = {
        'email': email.trim().toLowerCase(),
        'password': password, // simple storage for demo purposes
        'name': name.trim(),
        'subtitle': 'Пользователь DAYLO',
        'friendCode': friendCode,
        'points': 0,
        'level': 1,
        'friends': [],
      };

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return profileData;
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Register error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final key = _encodeEmail(email);
      final url = Uri.parse('$_baseUrl$key');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['password'] == password) {
          return data;
        } else {
          throw Exception('Неверный пароль');
        }
      } else {
        throw Exception('Пользователь с таким email не найден');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Login error: $e');
      rethrow;
    }
  }

  static Future<bool> updateAccountData({
    required String email,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final key = _encodeEmail(email);
      final url = Uri.parse('$_baseUrl$key');

      // Fetch existing data first to preserve password
      final getResponse = await http.get(url);
      if (getResponse.statusCode == 200) {
        final existing = jsonDecode(getResponse.body) as Map<String, dynamic>;
        final updatedData = {
          ...existing,
          ...profileData,
        };

        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedData),
        );
        return response.statusCode == 200 || response.statusCode == 201;
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('Update account error: $e');
      return false;
    }
  }
}
