import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService extends ChangeNotifier {
  // Singleton pattern
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  double? _temperature;
  String _condition = 'Поиск...';
  String _city = 'Локация...';
  bool _isLoading = false;

  double? get temperature => _temperature;
  String get condition => _condition;
  String get city => _city;
  bool get isLoading => _isLoading;

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check Permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      // 2. Get Position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // 3. Update basic city cache (mock for now or use reverse geocoding if package available)
      // Since we don't have geocoding pkg, we'll genericize or simple lookup if possible.
      // OpenMeteo doesn't return city name directly.
      _city = 'Мое место'; 

      // 4. Fetch from Open-Meteo (Free, No Key)
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,weather_code&hourly=temperature_2m&forecast_days=1');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];
        
        _temperature = current['temperature_2m'];
        final code = current['weather_code'];
        _condition = _mapWmoCodeToDescription(code);
        
        // Cache data
        final prefs = await SharedPreferences.getInstance();
        prefs.setDouble('last_temp', _temperature!);
        prefs.setString('last_cond', _condition);
      }
    } catch (e) {
      debugPrint('Weather Error: $e');
      _condition = 'Нет данных';
      
      // Try load cache
       final prefs = await SharedPreferences.getInstance();
       _temperature = prefs.getDouble('last_temp');
       _condition = prefs.getString('last_cond') ?? 'N/A';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapWmoCodeToDescription(int code) {
    // WMO Weather interpretation codes (WW)
    if (code == 0) return 'Ясно ☀️';
    if (code == 1 || code == 2 || code == 3) return 'Облачно ☁️';
    if (code == 45 || code == 48) return 'Туман 🌫️';
    if (code >= 51 && code <= 55) return 'Морось 💧';
    if (code >= 61 && code <= 67) return 'Дождь 🌧️';
    if (code >= 71 && code <= 77) return 'Снег ❄️';
    if (code >= 80 && code <= 82) return 'Ливень ☔️';
    if (code >= 95) return 'Гроза ⛈️';
    return 'Пасмурно';
  }
}
