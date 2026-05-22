import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/providers/nutrition_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/health_provider.dart';
import '../../core/data/recipe_database.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/minimal_card.dart';
import '../../widgets/premium_dialog.dart';
import 'tasty_recipe_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _shoppingItemController = TextEditingController();
  double _targetWeight = 70;

  @override
  void dispose() {
    _ingredientController.dispose();
    _shoppingItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Consumer<UserProvider>(
              builder: (context, user, _) => Image.asset(user.wallpaperPath, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.1),
                    AppTheme.primaryDark,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Consumer<NutritionProvider>(
              builder: (context, nutrition, _) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: Text('Питание', style: AppTheme.headlineStyle),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 12),
                      _buildWeekDates(nutrition)
                          .animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: _buildTopStats(nutrition),
                      ).animate().fadeIn(duration: 600.ms, delay: 150.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: _buildDailyStats(nutrition),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: _buildMealsSection(nutrition),
                      ).animate().fadeIn(duration: 600.ms, delay: 250.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: Text('Что приготовить?', style: AppTheme.titleStyle),
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: _buildRecipeCategories(context),
                      ).animate().fadeIn(duration: 600.ms, delay: 350.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: Text('Список покупок', style: AppTheme.titleStyle),
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: _buildShoppingList(context, nutrition),
                      ).animate().fadeIn(duration: 600.ms, delay: 450.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: Text('Сохраненные корзины', style: AppTheme.titleStyle),
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                        child: _buildBasketsGrid(context, nutrition),
                      ).animate().fadeIn(duration: 600.ms, delay: 550.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDates(NutritionProvider nutrition) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final dates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == nutrition.currentDate.year &&
              date.month == nutrition.currentDate.month &&
              date.day == nutrition.currentDate.day;

          return GestureDetector(
            onTap: () => nutrition.setDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.white : AppTheme.white08,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.transparent : AppTheme.white12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdays[index],
                    style: TextStyle(color: isSelected ? Colors.black : AppTheme.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.black : AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopStats(NutritionProvider nutrition) {
    final hour = DateTime.now().hour;
    String timeMessage = 'Пара перекусить!';
    if (hour >= 5 && hour < 11) timeMessage = 'Пора завтракать!';
    else if (hour >= 11 && hour < 16) timeMessage = 'Пора обедать!';
    else if (hour >= 16 && hour < 22) timeMessage = 'Пора ужинать!';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.monitor_weight_outlined,
            'Масса тела',
            '${_targetWeight.toInt()} кг',
            AppTheme.accentGold,
            onTap: () => _showWeightDialog(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.local_fire_department_outlined,
            'Инд. макс.',
            '${nutrition.calorieGoal.toInt()} ккал',
            AppTheme.accentPink,
            onTap: () => _showCalculatorDialog(context, nutrition),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.restaurant_outlined,
            'Сейчас',
            timeMessage,
            AppTheme.accentGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color, {VoidCallback? onTap}) {
    return MinimalCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.captionStyle.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.titleStyle.copyWith(fontSize: 14, color: AppTheme.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats(NutritionProvider nutrition) {
    final allMeals = [
      ...nutrition.getMeals(MealType.breakfast),
      ...nutrition.getMeals(MealType.lunch),
      ...nutrition.getMeals(MealType.dinner),
      ...nutrition.getMeals(MealType.snack),
    ];

    final currentCal = allMeals.fold(0.0, (s, p) => s + p.actualCalories);
    final currentP = allMeals.fold(0.0, (s, p) => s + p.actualProteins);
    final currentF = allMeals.fold(0.0, (s, p) => s + p.actualFats);
    final currentC = allMeals.fold(0.0, (s, p) => s + p.actualCarbs);

    return MinimalCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildMacroRow(
            label: 'Калории',
            current: currentCal,
            goal: nutrition.calorieGoal,
            color: AppTheme.white,
            isMain: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMacroRow(
                  label: 'Белки',
                  current: currentP,
                  goal: nutrition.proteinGoal,
                  color: AppTheme.errorRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroRow(
                  label: 'Жиры',
                  current: currentF,
                  goal: nutrition.fatGoal,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroRow(
                  label: 'Углеводы',
                  current: currentC,
                  goal: nutrition.carbGoal,
                  color: AppTheme.accentBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow({
    required String label,
    required double current,
    required double goal,
    required Color color,
    bool isMain = false,
  }) {
    final percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    if (isMain) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70, fontSize: 14)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${current.toInt()}',
                      style: AppTheme.titleStyle.copyWith(fontSize: 18),
                    ),
                    TextSpan(
                      text: ' / ${goal.toInt()}',
                      style: AppTheme.captionStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(percent, color, isMain: true),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${current.toInt()}',
                  style: AppTheme.titleStyle.copyWith(fontSize: 14),
                ),
                TextSpan(
                  text: '/${goal.toInt()}',
                  style: AppTheme.captionStyle.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        _buildProgressBar(percent, color),
      ],
    );
  }

  Widget _buildProgressBar(double percent, Color color, {bool isMain = false}) {
    return Stack(
      children: [
        Container(
          height: isMain ? 10 : 6,
          decoration: BoxDecoration(
            color: AppTheme.white12,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        FractionallySizedBox(
          widthFactor: percent > 0 ? percent : 0.001,
          child: Container(
            height: isMain ? 10 : 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealsSection(NutritionProvider nutrition) {
    return Column(
      children: [
        _buildMealRow(context, nutrition, MealType.breakfast, 'Завтрак'),
        const SizedBox(height: 12),
        _buildMealRow(context, nutrition, MealType.lunch, 'Обед'),
        const SizedBox(height: 12),
        _buildMealRow(context, nutrition, MealType.dinner, 'Ужин'),
        const SizedBox(height: 12),
        _buildMealRow(context, nutrition, MealType.snack, 'Перекусы'),
      ],
    );
  }

  Widget _buildMealRow(BuildContext context, NutritionProvider nutrition, MealType type, String title) {
    final products = nutrition.getMeals(type);
    final cal = products.fold(0.0, (s, p) => s + p.actualCalories).toInt();
    final p = products.fold(0.0, (s, p) => s + p.actualProteins).toInt();
    final f = products.fold(0.0, (s, p) => s + p.actualFats).toInt();
    final c = products.fold(0.0, (s, p) => s + p.actualCarbs).toInt();

    final hasData = products.isNotEmpty;
    final displayStr = hasData ? '$cal · Б$p Ж$f У$c' : 'Пока пусто';

    return MinimalCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () {
        if (hasData) {
          _showMealDetailsDialog(context, type, title);
        } else {
          _showAddMealDialog(context, nutrition, type);
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _mealColor(type).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_mealIcon(type), color: _mealColor(type), size: 18),
          ),
          const SizedBox(width: 14),
          Text(title, style: AppTheme.titleStyle.copyWith(fontSize: 15)),
          const Spacer(),
          Text(
            displayStr,
            style: TextStyle(
              color: hasData ? AppTheme.white70 : AppTheme.white38,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showAddMealDialog(context, nutrition, type),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.white08,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded, color: AppTheme.white54, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  IconData _mealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast: return Icons.free_breakfast_rounded;
      case MealType.lunch:     return Icons.lunch_dining_rounded;
      case MealType.dinner:    return Icons.dinner_dining_rounded;
      case MealType.snack:     return Icons.cookie_rounded;
    }
  }

  Color _mealColor(MealType type) {
    switch (type) {
      case MealType.breakfast: return AppTheme.accentGold;
      case MealType.lunch:     return AppTheme.accentGreen;
      case MealType.dinner:    return AppTheme.accentIndigo;
      case MealType.snack:     return AppTheme.accentPink;
    }
  }

  Widget _buildRecipeCategories(BuildContext context) {
    final categories = [
      ('🍳', 'Завтрак', 'breakfast'),
      ('🥩', 'Мясо', 'meat'),
      ('🥗', 'Салат', 'salad'),
      ('🍲', 'Суп', 'soup'),
      ('🍚', 'Гарнир', 'garnish'),
      ('🐟', 'Рыба', 'fish'),
      ('🍰', 'Десерт', 'dessert'),
      ('🥪', 'Закуски', 'snack'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) => GestureDetector(
        onTap: () => _showRecipesDialog(context, c.$3, c.$2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.white08,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(c.$1, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(c.$2, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white, fontSize: 13)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildChefSection(BuildContext context, NutritionProvider nutrition) {
    return MinimalCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [AppTheme.white08, AppTheme.white05],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.kitchen_rounded, color: AppTheme.accentGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Мой холодильник', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
              ),
              if (nutrition.fridgeInventory.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${nutrition.fridgeInventory.length}',
                    style: AppTheme.captionStyle.copyWith(color: AppTheme.accentGreen, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Добавьте продукты, а я предложу рецепт', style: AppTheme.captionStyle),
          const SizedBox(height: 16),
          _buildChefInput(context, nutrition),

          if (nutrition.isSearchingRecipes)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: CircularProgressIndicator(color: AppTheme.accentGreen)),
            )
          else if (nutrition.foundRecipes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Найдено для вас:', style: AppTheme.titleStyle.copyWith(fontSize: 14)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: nutrition.foundRecipes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _buildRecipeCardSmall(context, nutrition.foundRecipes[index]);
                },
              ),
            ),
          ] else if (nutrition.fridgeInventory.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: nutrition.fridgeInventory.map((item) => Chip(
                label: Text(item, style: const TextStyle(color: AppTheme.white)),
                backgroundColor: AppTheme.white08,
                deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.white54),
                onDeleted: () => nutrition.removeFromFridge(item),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              )).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => nutrition.searchRecipesByFridge(),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Подобрать рецепт'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildChefInput(BuildContext context, NutritionProvider nutrition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.white08,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ingredientController,
              style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
              decoration: InputDecoration(
                hintText: 'Помидор, сыр, яйцо...',
                hintStyle: AppTheme.captionStyle,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (value) {
                final items = value.split(',').where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList();
                for (var item in items) {
                  nutrition.addToFridge(item);
                }
                _ingredientController.clear();
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_ingredientController.text.trim().isNotEmpty) {
                final items = _ingredientController.text.split(',').where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList();
                for (var item in items) {
                  nutrition.addToFridge(item);
                }
                _ingredientController.clear();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                color: AppTheme.accentGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 20),
            ),
          ),
          GestureDetector(
            onTap: () => _showAiSettings(context, nutrition),
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: nutrition.useAiChef ? AppTheme.accentPurple : AppTheme.white08,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: nutrition.useAiChef ? AppTheme.white : AppTheme.white54, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCardSmall(BuildContext context, RecipeData recipe) {
    return GestureDetector(
      onTap: () => _showRecipeDetails(context, recipe),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (recipe.videoThumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: 'recipe_${recipe.name}',
                  child: Opacity(
                    opacity: 0.7,
                    child: Image.asset(recipe.videoThumbnail!, fit: BoxFit.cover),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: AppTheme.titleStyle.copyWith(fontSize: 14, color: AppTheme.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: AppTheme.accentGreen, size: 12),
                      const SizedBox(width: 4),
                      Text('${recipe.cookTime} мин', style: AppTheme.captionStyle.copyWith(color: AppTheme.white70, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCarousel(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final recipes = RecipeDatabase.recipes.take(5).toList();
          if (index < recipes.length) {
            return _buildRecipeCardLarge(context, recipes[index]);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildRecipeCardLarge(BuildContext context, RecipeData recipe) {
    return GestureDetector(
      onTap: () => _showRecipeDetails(context, recipe),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (recipe.videoThumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Hero(
                  tag: 'recipe_${recipe.name}',
                  child: Opacity(
                    opacity: 0.7,
                    child: Image.asset(recipe.videoThumbnail!, fit: BoxFit.cover),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: AppTheme.headlineStyle.copyWith(fontSize: 18, color: AppTheme.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag(Icons.schedule, '${recipe.cookTime} мин'),
                      const SizedBox(width: 8),
                      _buildTag(Icons.local_fire_department, '${recipe.calories.toInt()} ккал'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Перейти',
                        style: AppTheme.buttonTextStyle.copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.white, size: 12),
          const SizedBox(width: 4),
          Text(text, style: AppTheme.captionStyle.copyWith(color: AppTheme.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildShoppingList(BuildContext context, NutritionProvider nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Список покупок', style: AppTheme.titleStyle),
            if (nutrition.shoppingList.isNotEmpty)
              GestureDetector(
                onTap: () => _showSaveBasketDialog(context, nutrition),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.save, color: AppTheme.accentGreen, size: 16),
                      const SizedBox(width: 4),
                      Text('Сохранить', style: AppTheme.captionStyle.copyWith(color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.white08,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.white12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _shoppingItemController,
                  style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
                  decoration: InputDecoration(
                    hintText: 'Добавить продукт...',
                    hintStyle: AppTheme.captionStyle,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      nutrition.addToShoppingList(value.trim());
                      _shoppingItemController.clear();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.accentGreen),
                onPressed: () {
                  if (_shoppingItemController.text.trim().isNotEmpty) {
                    nutrition.addToShoppingList(_shoppingItemController.text.trim());
                    _shoppingItemController.clear();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (nutrition.shoppingList.isEmpty)
          MinimalCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Center(child: Text('Список пуст', style: AppTheme.captionStyle)),
          )
        else
          MinimalCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: nutrition.shoppingList.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.white05),
              itemBuilder: (context, index) {
                final item = nutrition.shoppingList[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  leading: Checkbox(
                    value: item.isChecked,
                    activeColor: AppTheme.accentGreen,
                    checkColor: Colors.black,
                    side: const BorderSide(color: AppTheme.white54, width: 2),
                    onChanged: (val) => nutrition.toggleShoppingItem(index),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      color: item.isChecked ? AppTheme.white38 : AppTheme.white,
                      decoration: item.isChecked ? TextDecoration.lineThrough : null,
                      decorationColor: AppTheme.white38,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.white38, size: 18),
                    onPressed: () => nutrition.removeFromShoppingList(index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBasketsGrid(BuildContext context, NutritionProvider nutrition) {
    final sets = nutrition.productSets;
    if (sets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Нет сохраненных корзин', style: AppTheme.captionStyle)),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        return _buildBasketCard(context, sets[index], nutrition);
      },
    );
  }

  Widget _buildBasketCard(BuildContext context, ProductSet set, NutritionProvider nutrition) {
    return GestureDetector(
      onTap: () => _showProductSetDetails(context, nutrition, set),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161618).withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        set.name,
                        style: AppTheme.titleStyle.copyWith(fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _confirmDeleteBasket(context, nutrition, set),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: set.products.take(3).map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• ${p.name}', style: AppTheme.captionStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    nutrition.addSetToShoppingList(set);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Продукты добавлены в текущий список'),
                      backgroundColor: AppTheme.accentGreen,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.white.withValues(alpha: 0.15)),
                    ),
                    child: Center(
                      child: Text('Выбрать', style: AppTheme.buttonTextStyle.copyWith(fontSize: 12, color: AppTheme.white)),
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

  void _confirmDeleteBasket(BuildContext context, NutritionProvider nutrition, ProductSet set) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131F),
        title: Text('Удалить корзину?', style: AppTheme.titleStyle),
        content: Text('"${set.name}" будет удалена.', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white38)),
          ),
          TextButton(
            onPressed: () {
              nutrition.removeProductSet(set);
              Navigator.pop(ctx);
            },
            child: Text('Удалить', style: AppTheme.titleStyle.copyWith(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  // ── Dialogs ──

  void _showAiSettings(BuildContext context, NutritionProvider nutrition) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('AI Шеф-повар', style: TextStyle(color: AppTheme.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Для работы умного поиска рецептов нужен API ключ Gemini.',
              style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
              decoration: InputDecoration(
                hintText: 'Вставьте Gemini API Key',
                hintStyle: AppTheme.captionStyle,
                filled: true,
                fillColor: AppTheme.white08,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white54)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                nutrition.setAiApiKey(controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI Шеф активирован!')),
                );
              }
            },
            child: Text('Сохранить', style: AppTheme.bodyStyle.copyWith(color: AppTheme.accentGreen)),
          ),
        ],
      ),
    );
  }

  void _showCalculatorDialog(BuildContext context, NutritionProvider nutrition) {
    bool isMale = true;
    final ageController = TextEditingController();
    final heightController = TextEditingController();
    final weightController = TextEditingController(text: '${_targetWeight.toInt()}');
    double activity = 1.2;
    String goal = 'maintain';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppTheme.white38, borderRadius: BorderRadius.circular(2)),
                ),
                Text('Калькулятор КБЖУ', style: AppTheme.titleStyle.copyWith(fontSize: 20)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.white08,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildCalcTab('Мужчина', isMale, () => setState(() => isMale = true))),
                            Expanded(child: _buildCalcTab('Женщина', !isMale, () => setState(() => isMale = false))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildCalcInput('Возраст', ageController, 'лет')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCalcInput('Рост', heightController, 'см')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCalcInput('Вес', weightController, 'кг')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Уровень активности', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70)),
                      const SizedBox(height: 12),
                      _buildActivityOption('Сидячий', 'Без нагрузок', 1.2, activity, (v) => setState(() => activity = v)),
                      _buildActivityOption('Малый', '1-3 тренировки', 1.375, activity, (v) => setState(() => activity = v)),
                      _buildActivityOption('Средний', '3-5 тренировок', 1.55, activity, (v) => setState(() => activity = v)),
                      _buildActivityOption('Высокий', '6-7 тренировок', 1.725, activity, (v) => setState(() => activity = v)),
                      const SizedBox(height: 24),
                      Text('Ваша цель', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildCalcGoal('Похудеть', 'lose', goal, (v) => setState(() => goal = v))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCalcGoal('Держать', 'maintain', goal, (v) => setState(() => goal = v))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCalcGoal('Набрать', 'gain', goal, (v) => setState(() => goal = v))),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final age = double.tryParse(ageController.text) ?? 25;
                            final height = double.tryParse(heightController.text) ?? 175;
                            final weight = double.tryParse(weightController.text) ?? _targetWeight;

                            double bmr = isMale
                                ? 10 * weight + 6.25 * height - 5 * age + 5
                                : 10 * weight + 6.25 * height - 5 * age - 161;

                            double tdee = bmr * activity;
                            if (goal == 'lose') tdee *= 0.8;
                            if (goal == 'gain') tdee *= 1.15;

                            final p = weight * 2;
                            final f = (tdee * 0.25) / 9;
                            final c = (tdee - (p * 4 + f * 9)) / 4;

                            nutrition.setGoals(calories: tdee, proteins: p, fats: f, carbs: c < 0 ? 0 : c);
                            setState(() => _targetWeight = weight);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('План питания обновлен!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Рассчитать программу', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showManualGoalDialog(context, nutrition);
                        },
                        child: Text('Ввести вручную', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white54)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalcTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : AppTheme.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalcInput(String label, TextEditingController controller, String suffix, {TextInputType keyboardType = TextInputType.number}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.white08,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.captionStyle),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTheme.titleStyle.copyWith(fontSize: 18, color: AppTheme.white),
            decoration: InputDecoration(
              isDense: true,
              hintText: keyboardType == TextInputType.number ? '0' : '',
              hintStyle: TextStyle(color: AppTheme.white38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              suffixText: suffix,
              suffixStyle: TextStyle(color: AppTheme.accentGreen, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInput(String label, TextEditingController controller, String suffix, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: AppTheme.captionStyle.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: AppTheme.titleStyle.copyWith(fontSize: 22, color: AppTheme.white),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: '0',
                    hintStyle: TextStyle(color: AppTheme.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(suffix, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOption(String title, String subtitle, double value, double groupValue, Function(double) onChanged) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGreen.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.accentGreen : AppTheme.white12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.accentGreen : AppTheme.white38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: AppTheme.captionStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcGoal(String label, String value, String groupValue, Function(String) onChanged) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGreen : AppTheme.white08,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.accentGreen : AppTheme.white12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : AppTheme.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  void _showManualGoalDialog(BuildContext context, NutritionProvider nutrition) {
    final cController = TextEditingController(text: '${nutrition.calorieGoal.toInt()}');
    final pController = TextEditingController(text: '${nutrition.proteinGoal.toInt()}');
    final fController = TextEditingController(text: '${nutrition.fatGoal.toInt()}');
    final carbController = TextEditingController(text: '${nutrition.carbGoal.toInt()}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text('Ручная настройка', style: AppTheme.titleStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCalcInput('Калории', cController, ''),
            const SizedBox(height: 8),
            _buildCalcInput('Белки (г)', pController, ''),
            const SizedBox(height: 8),
            _buildCalcInput('Жиры (г)', fController, ''),
            const SizedBox(height: 8),
            _buildCalcInput('Углеводы (г)', carbController, ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              nutrition.setGoals(
                calories: double.tryParse(cController.text),
                proteins: double.tryParse(pController.text),
                fats: double.tryParse(fController.text),
                carbs: double.tryParse(carbController.text),
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.black,
            ),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text('Целевой вес', style: AppTheme.titleStyle),
        content: TextField(
          keyboardType: TextInputType.number,
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
          decoration: InputDecoration(
            hintText: 'кг',
            hintStyle: AppTheme.captionStyle,
            filled: true,
            fillColor: AppTheme.white08,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (v) {
            final w = double.tryParse(v);
            if (w != null) setState(() => _targetWeight = w);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white54)),
          ),
        ],
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, NutritionProvider nutrition, MealType mealType) {
    int selectedTab = 0;
    bool saveToMyDishes = false;
    String? selectedImagePath;
    final searchController = TextEditingController();
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final pController = TextEditingController();
    final fController = TextEditingController();
    final carbController = TextEditingController();
    List<Product> results = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.white38, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.white08,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 0 ? AppTheme.accentGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text('Поиск', style: TextStyle(
                                color: selectedTab == 0 ? Colors.black : AppTheme.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              )),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 1 ? AppTheme.accentGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text('Свое', style: TextStyle(
                                color: selectedTab == 1 ? Colors.black : AppTheme.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              )),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedTab = 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 2 ? AppTheme.accentGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text('Мои', style: TextStyle(
                                color: selectedTab == 2 ? Colors.black : AppTheme.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (selectedTab == 0) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
                    decoration: InputDecoration(
                      hintText: 'Поиск продуктов...',
                      hintStyle: AppTheme.captionStyle,
                      prefixIcon: const Icon(Icons.search, color: AppTheme.white38),
                      filled: true,
                      fillColor: AppTheme.white08,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    onChanged: (q) async {
                      if (q.length > 1) {
                        final res = await nutrition.searchProducts(q);
                        setModalState(() => results = res);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.isEmpty ? 1 : results.length,
                    itemBuilder: (ctx, i) {
                      if (results.isEmpty) {
                        return Center(
                          child: Text('Введите название продукта', style: AppTheme.captionStyle),
                        );
                      }
                      final p = results[i];
                      return ListTile(
                        leading: p.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(p.imagePath!), width: 40, height: 40, fit: BoxFit.cover),
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(color: AppTheme.white08, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.restaurant, color: AppTheme.white38, size: 20),
                              ),
                        title: Text(p.name, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
                        subtitle: Text(
                          '${p.calories.toInt()} ккал | Б${p.proteins.toInt()} Ж${p.fats.toInt()} У${p.carbs.toInt()} на 100г',
                          style: AppTheme.captionStyle,
                        ),
                        trailing: const Icon(Icons.add_circle, color: AppTheme.accentGreen),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showGramsDialog(context, p, (newProduct) {
                            nutrition.addToMeal(mealType, newProduct);
                            if (context.mounted) context.read<UserProvider>().completeDailyTask('calories');
                          });
                        },
                      );
                    },
                  ),
                ),
              ] else if (selectedTab == 1) ...[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final source = await showModalBottomSheet<ImageSource>(
                              context: context,
                              backgroundColor: AppTheme.surfaceDark,
                              builder: (ctx) => Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt, color: AppTheme.accentGreen),
                                      title: Text('Камера', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
                                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library, color: AppTheme.accentGreen),
                                      title: Text('Галерея', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
                                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            if (source != null) {
                              final XFile? image = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
                              if (image != null) {
                                final appDir = await getApplicationDocumentsDirectory();
                                final fileName = 'dish_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                final savedPath = '${appDir.path}/$fileName';
                                await File(image.path).copy(savedPath);
                                setModalState(() => selectedImagePath = savedPath);
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.white08,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.white12),
                            ),
                            child: selectedImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(File(selectedImagePath!), fit: BoxFit.cover),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () => setModalState(() => selectedImagePath = null),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo, color: AppTheme.white38, size: 32),
                                      SizedBox(height: 8),
                                      Text('Добавить фото', style: TextStyle(color: AppTheme.white38)),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCalcInput('Название блюда', nameController, '', keyboardType: TextInputType.text),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildMacroInput('КАЛОРИИ', calController, 'ккал', AppTheme.accentGreen, Icons.local_fire_department_rounded)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildMacroInput('БЕЛКИ', pController, 'г', Colors.redAccent, Icons.fitness_center_rounded)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildMacroInput('ЖИРЫ', fController, 'г', Colors.orangeAccent, Icons.water_drop_rounded)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildMacroInput('УГЛЕВОДЫ', carbController, 'г', Colors.blueAccent, Icons.grain_rounded)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: saveToMyDishes,
                                onChanged: (v) => setModalState(() => saveToMyDishes = v ?? false),
                                activeColor: AppTheme.accentGreen,
                                checkColor: Colors.black,
                                side: const BorderSide(color: AppTheme.white54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Text('Сохранить в "Мои блюда"', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (nameController.text.isNotEmpty) {
                                final newItem = Product(
                                  name: nameController.text,
                                  calories: double.tryParse(calController.text) ?? 0,
                                  proteins: double.tryParse(pController.text) ?? 0,
                                  fats: double.tryParse(fController.text) ?? 0,
                                  carbs: double.tryParse(carbController.text) ?? 0,
                                  imagePath: selectedImagePath,
                                );

                                if (saveToMyDishes) {
                                  nutrition.saveUserProduct(newItem);
                                }

                                nutrition.addToMeal(mealType, newItem);
                                if (context.mounted) context.read<UserProvider>().completeDailyTask('calories');
                                Navigator.pop(ctx);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentGreen,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Добавить', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: nutrition.userProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.restaurant_menu, color: AppTheme.white38, size: 48),
                              SizedBox(height: 16),
                              Text('Нет сохранённых блюд', style: TextStyle(color: AppTheme.white38, fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Создайте блюдо во вкладке "Свое"', style: TextStyle(color: AppTheme.white38, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: nutrition.userProducts.length,
                          itemBuilder: (ctx, i) {
                            final p = nutrition.userProducts[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.white08,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.white12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                leading: p.imagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(File(p.imagePath!), width: 50, height: 50, fit: BoxFit.cover),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(color: AppTheme.white08, borderRadius: BorderRadius.circular(12)),
                                        child: const Icon(Icons.restaurant, color: AppTheme.white38, size: 24),
                                      ),
                                title: Text(p.name, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  '${p.calories.toInt()} ккал • Б${p.proteins.toInt()} Ж${p.fats.toInt()} У${p.carbs.toInt()}',
                                  style: AppTheme.captionStyle,
                                ),
                                trailing: const Icon(Icons.add_circle, color: AppTheme.accentGreen, size: 28),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _showGramsDialog(context, p, (newProduct) {
                                    nutrition.addToMeal(mealType, newProduct);
                                    if (context.mounted) context.read<UserProvider>().completeDailyTask('calories');
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMealDetailsDialog(BuildContext context, MealType type, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Consumer<NutritionProvider>(
            builder: (ctx, nutrition, _) {
              final products = nutrition.getMeals(type);
              final totalCal = products.fold(0.0, (s, p) => s + p.actualCalories).toInt();
              final totalP = products.fold(0.0, (s, p) => s + p.actualProteins).toInt();
              final totalF = products.fold(0.0, (s, p) => s + p.actualFats).toInt();
              final totalC = products.fold(0.0, (s, p) => s + p.actualCarbs).toInt();

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppTheme.white38, borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: AppTheme.headlineStyle.copyWith(fontSize: 24)),
                        Text(
                          '$totalCal ккал',
                          style: AppTheme.titleStyle.copyWith(color: AppTheme.accentGreen, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text('Б: $totalP  Ж: $totalF  У: $totalC', style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppTheme.white12),
                  Expanded(
                    child: products.isEmpty
                        ? Center(child: Text('Нет продуктов', style: AppTheme.captionStyle))
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.only(bottom: 40),
                            itemCount: products.length,
                            separatorBuilder: (_, __) => const Divider(color: AppTheme.white12, indent: 20, endIndent: 20),
                            itemBuilder: (ctx, index) {
                              final p = products[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                title: Text(p.name, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
                                subtitle: Text(
                                  '${p.grams.toInt()}г • ${p.actualCalories.toInt()} ккал\nБ: ${p.actualProteins.toInt()} Ж: ${p.actualFats.toInt()} У: ${p.actualCarbs.toInt()}',
                                  style: AppTheme.captionStyle.copyWith(height: 1.5),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.errorRed),
                                  onPressed: () => nutrition.removeProductFromMeal(type, p),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddMealDialog(context, nutrition, type);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить продукт'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showGramsDialog(BuildContext context, Product product, Function(Product) onConfirm) {
    double grams = 100;
    final controller = TextEditingController(text: '100');

    showPremiumDialog(
      context: context,
      title: product.name,
      content: StatefulBuilder(
        builder: (context, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              style: AppTheme.headlineStyle.copyWith(fontSize: 32, color: AppTheme.white),
              decoration: InputDecoration(
                suffixText: 'г',
                suffixStyle: const TextStyle(color: AppTheme.white54),
                filled: true,
                fillColor: AppTheme.white08,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setDialogState(() => grams = double.tryParse(v) ?? 100),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white05,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPreviewNutrient('Ккал', (product.calories * grams / 100).toInt(), AppTheme.accentGold),
                  _buildPreviewNutrient('Б', (product.proteins * grams / 100).toInt(), AppTheme.errorRed),
                  _buildPreviewNutrient('Ж', (product.fats * grams / 100).toInt(), AppTheme.accentGold),
                  _buildPreviewNutrient('У', (product.carbs * grams / 100).toInt(), AppTheme.accentBlue),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white38)),
        ),
        TextButton(
          onPressed: () {
            final double finalGrams = double.tryParse(controller.text) ?? 100;
            final newProduct = Product(
              name: product.name,
              calories: product.calories,
              proteins: product.proteins,
              fats: product.fats,
              carbs: product.carbs,
              grams: finalGrams,
            );
            onConfirm(newProduct);
            Navigator.pop(context);
          },
          child: Text('Добавить', style: AppTheme.titleStyle.copyWith(color: AppTheme.accentGreen, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildPreviewNutrient(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: AppTheme.captionStyle),
      ],
    );
  }

  void _showRecipesDialog(BuildContext context, String category, String title) {
    final recipes = RecipeDatabase.getByCategory(category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppTheme.white38, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: AppTheme.titleStyle.copyWith(fontSize: 20)),
            ),
            Expanded(
              child: recipes.isEmpty
                  ? Center(child: Text('Рецептов пока нет', style: AppTheme.captionStyle))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recipes.length,
                      itemBuilder: (context, i) {
                        final r = recipes[i];
                        return ListTile(
                          title: Text(r.name, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
                          subtitle: Text(
                            '${r.cookTime} мин • ${r.calories.toInt()} ккал',
                            style: AppTheme.captionStyle,
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppTheme.white38),
                          onTap: () => _showRecipeDetails(context, r),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, RecipeData recipe) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TastyRecipeScreen(recipe: recipe),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _showProductSetDetails(BuildContext context, NutritionProvider nutrition, ProductSet set) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(set.name, style: AppTheme.headlineStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            if (set.products.isNotEmpty)
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: set.products.map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(p.name, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white), overflow: TextOverflow.ellipsis)),
                          Text('${p.grams.toInt()}г', style: AppTheme.captionStyle),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
            if (set.products.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('В корзине нет продуктов', style: AppTheme.captionStyle),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  nutrition.addSetToShoppingList(set);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${set.name} добавлен в список')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Добавить в список', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveBasketDialog(BuildContext context, NutritionProvider nutrition) {
    String name = 'Корзина ${nutrition.productSets.length + 1}';
    final controller = TextEditingController(text: name);

    showPremiumDialog(
      context: context,
      title: 'Сохранить корзину',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Поместить текущий список продуктов в раздел "Корзины"?',
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.center,
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
            decoration: InputDecoration(
              hintText: 'Название корзины',
              hintStyle: AppTheme.captionStyle,
              filled: true,
              fillColor: AppTheme.white08,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white38)),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              nutrition.saveShoppingListToSet(controller.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Список сохранен в корзины')),
              );
            }
          },
          child: Text('Сохранить', style: AppTheme.titleStyle.copyWith(color: AppTheme.accentGreen, fontSize: 16)),
        ),
      ],
    );
  }
}
