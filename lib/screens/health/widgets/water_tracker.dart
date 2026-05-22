import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/nutrition_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/minimal_card.dart';

class WaterTracker extends StatefulWidget {
  const WaterTracker({super.key});

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  DrinkType _selectedType = DrinkType.water;

  Color _getDrinkColor(DrinkType type) {
    switch (type) {
      case DrinkType.water: return AppTheme.accentBlue;
      case DrinkType.coffee: return Colors.brown;
      case DrinkType.tea: return Colors.green;
      case DrinkType.juice: return Colors.orange;
      case DrinkType.soda: return Colors.redAccent;
      case DrinkType.other: return AppTheme.accentPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, nutrition, child) {
        final mlCurrent = nutrition.waterMl;
        final mlGoal = nutrition.waterGoalMl;
        final double progress = (mlGoal > 0 ? mlCurrent / mlGoal : 0.0).clamp(0.0, 1.0);
        final activeColor = _getDrinkColor(_selectedType);

        return MinimalCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop_rounded, color: activeColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Вода', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                  const Spacer(),
                  Text(
                    '$mlCurrent / $mlGoal мл',
                    style: AppTheme.captionStyle.copyWith(color: AppTheme.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Progress Bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Type Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: DrinkType.values.map((type) {
                    final isSelected = _selectedType == type;
                    final typeColor = _getDrinkColor(type);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? typeColor : AppTheme.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(_getDrinkIcon(type), style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                _getDrinkName(type),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.white38,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: _AddWaterButton(
                      label: '250 мл',
                      onTap: () => nutrition.addDrink(_selectedType, 250),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AddWaterButton(
                      label: '500 мл',
                      onTap: () => nutrition.addDrink(_selectedType, 500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => nutrition.removeLastDrink(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.undo_rounded, color: AppTheme.white38, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDrinkIcon(DrinkType type) {
    switch (type) {
      case DrinkType.water: return '💧';
      case DrinkType.tea: return '🍵';
      case DrinkType.coffee: return '☕';
      case DrinkType.juice: return '🧃';
      case DrinkType.soda: return '🥤';
      case DrinkType.other: return '🥛';
    }
  }

  String _getDrinkName(DrinkType type) {
    switch (type) {
      case DrinkType.water: return 'Вода';
      case DrinkType.tea: return 'Чай';
      case DrinkType.coffee: return 'Кофе';
      case DrinkType.juice: return 'Сок';
      case DrinkType.soda: return 'Газ-ка';
      case DrinkType.other: return 'Другое';
    }
  }
}

class _AddWaterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddWaterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.white12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.titleStyle.copyWith(fontSize: 13, color: AppTheme.white70),
        ),
      ),
    );
  }
}
