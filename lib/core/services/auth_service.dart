import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _setBaseUrl = 'https://setget.net/set/daylo_acc_';
  static const String _getBaseUrl = 'https://setget.net/get/daylo_acc_';

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
      final checkUrl = Uri.parse('$_getBaseUrl$key');

      // Check if user already exists
      final checkResponse = await http.get(checkUrl);
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

      final writeUrl = Uri.parse('$_setBaseUrl$key');
      final response = await http.post(
        writeUrl,
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
      final url = Uri.parse('$_getBaseUrl$key');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('value')) {
          final data = decoded['value'] as Map<String, dynamic>;
          if (data['password'] == password) {
            return data;
          } else {
            throw Exception('Неверный пароль');
          }
        } else {
          throw Exception('Ошибка структуры данных сервера');
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
      final getUrl = Uri.parse('$_getBaseUrl$key');

      // Fetch existing data first to preserve password
      final getResponse = await http.get(getUrl);
      if (getResponse.statusCode == 200) {
        final decoded = jsonDecode(getResponse.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('value')) {
          final existing = decoded['value'] as Map<String, dynamic>;
          final updatedData = {
            ...existing,
            ...profileData,
          };

          final writeUrl = Uri.parse('$_setBaseUrl$key');
          final response = await http.post(
            writeUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updatedData),
          );
          return response.statusCode == 200 || response.statusCode == 201;
        }
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('Update account error: $e');
      return false;
    }
  }
}
