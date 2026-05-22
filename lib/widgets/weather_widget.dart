import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/services/weather_service.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherService>(
      builder: (context, weather, _) {
        if (weather.isLoading) {
           return const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    weather.condition.split(' ').last,
                    style: const TextStyle(fontSize: 28),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  weather.temperature != null ? '${weather.temperature!.round()}°' : '--',
                  style: AppTheme.headlineStyle.copyWith(fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              weather.city,
              style: AppTheme.labelStyle.copyWith(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
    );
  }
}
