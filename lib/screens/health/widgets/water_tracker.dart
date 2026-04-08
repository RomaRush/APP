import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/nutrition_provider.dart';

class WaterTracker extends StatefulWidget {
  const WaterTracker({super.key});

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  DrinkType _selectedType = DrinkType.water;

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, nutrition, child) {
        final mlCurrent = nutrition.waterMl;
        final mlGoal = nutrition.waterGoalMl;
        final mlLeft = (mlGoal - mlCurrent).clamp(0, 9999);
        final double progress = (mlGoal > 0 ? mlCurrent / mlGoal : 0.0).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Водный баланс',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (mlLeft > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Осталось: $mlLeft мл',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Цель достигнута! 🎉',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Drink Type Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: DrinkType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blueAccent : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.blueAccent : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getDrinkIcon(type),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getDrinkName(type),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
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
              
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(icon: Icons.remove, onTap: () => nutrition.removeLastDrink()),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showDrinkHistory(context, nutrition),
                            child: Text(
                              '$mlCurrent / $mlGoal мл',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: Colors.grey[200],
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _CircleButton(
                    icon: Icons.add, 
                    onTap: () {
                      nutrition.addDrink(_selectedType, 250); // Default 250ml
                    },
                    color: Colors.blueAccent,
                    iconColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                 child: Text(
                   'Выбрано: ${_getDrinkName(_selectedType)} (250 мл)',
                   style: TextStyle(color: Colors.grey[600], fontSize: 13),
                 ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showDrinkHistory(BuildContext context, NutritionProvider nutrition) {
    // Access drink history from provider - we need to add a getter
    final drinks = nutrition.todaysDrinks;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'История напитков 💧',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: drinks.isEmpty
                  ? const Center(
                      child: Text(
                        'Пока ничего не выпито',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: drinks.length,
                      itemBuilder: (context, index) {
                        final drink = drinks[drinks.length - 1 - index]; // Newest first
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getDrinkIcon(drink.type),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getDrinkName(drink.type),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${drink.time.hour.toString().padLeft(2, '0')}:${drink.time.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${drink.amountMl} мл',
                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
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

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;

  const _CircleButton({
    required this.icon, 
    required this.onTap,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color ?? Colors.blue[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.blueAccent),
      ),
    );
  }
}
