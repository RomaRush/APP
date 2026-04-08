import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/providers/nutrition_provider.dart';

import '../../core/data/recipe_database.dart';
import 'tasty_recipe_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  // Premium green color scheme
  static const Color bgGreen = Color(0xFF1B3D2F);
  static const Color cardGreen = Color(0xFF254D3B);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color cream = Color(0xFFF5F5DC);
  
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _shoppingItemController = TextEditingController(); // Added for shopping list
  double _targetWeight = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/nutrition_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<NutritionProvider>(
          builder: (context, nutrition, _) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
              // Header with Date Selector
              SliverPadding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                sliver: SliverToBoxAdapter(
                  child: _buildHeader(context, nutrition),
                ),
              ),
                
                // Top Stats (Weight, Goal, Params)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildTopStats(context, nutrition),
                  ),
                ),
                
                // Daily Stats (Replaces BJU Summary)
                SliverToBoxAdapter(
                  child: _buildDailyStats(context, nutrition),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Meals Section (Dark Strips)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildMealRow(context, nutrition, MealType.breakfast, 'Завтрак', '500 - 50 - 20 - 10'),
                        const SizedBox(height: 8),
                        _buildMealRow(context, nutrition, MealType.lunch, 'Обед', '700 - 50 - 45 - 20'),
                        const SizedBox(height: 8),
                        _buildMealRow(context, nutrition, MealType.dinner, 'Ужин', '600 - 40 - 25 - 10'),
                        const SizedBox(height: 8),
                        _buildMealRow(context, nutrition, MealType.snack, 'Перекусы', '400 - 20 - 10 - 5'),
                      ],
                    ),
                  ),
                ),
                
                // What to cook section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Что приготовить?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildRecipeCategories(context),
                      ],
                    ),
                  ),
                ),
                
                // Chef Mode (Fridge Magic)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cardGreen, bgGreen],
                          begin: Alignment.topLeft, 
                          end: Alignment.bottomRight
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.kitchen, color: accentGreen, size: 28),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Мой холодильник', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ),
                              if (nutrition.fridgeInventory.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: accentGreen, borderRadius: BorderRadius.circular(12)),
                                  child: Text('${nutrition.fridgeInventory.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                            ],
                           ),
                           const SizedBox(height: 16),
                           const Text('Добавьте продукты, а я предложу рецепт', style: TextStyle(color: Colors.white54, fontSize: 13)),
                           const SizedBox(height: 16),
                           _buildChefInput(context, nutrition),
                           
                           if (nutrition.isSearchingRecipes)
                             const Padding(
                               padding: EdgeInsets.only(top: 20),
                               child: Center(child: CircularProgressIndicator(color: Colors.white)),
                             )
                           else if (nutrition.foundRecipes.isNotEmpty) ...[
                             const SizedBox(height: 20),
                             const Text('Найдено для вас:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                                   label: Text(item),
                                   backgroundColor: Colors.white10,
                                   labelStyle: const TextStyle(color: Colors.white),
                                   deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white54),
                                   onDeleted: () => nutrition.removeFromFridge(item),
                                   side: BorderSide.none,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                 )).toList(),
                               ),
                               const SizedBox(height: 20),
                               SizedBox(
                                 width: double.infinity,
                                 child: ElevatedButton.icon(
                                   onPressed: () {
                                     nutrition.searchRecipesByFridge();
                                   }, 
                                   icon: const Icon(Icons.auto_awesome, color: Colors.black),
                                   label: const Text('Подобрать рецепт', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: accentGreen,
                                     padding: const EdgeInsets.symmetric(vertical: 12),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                   ),
                                 ),
                               ),
                           ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Recipe Carousel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Что готовим мы', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Собственные вкусные и полезные рецепты', style: TextStyle(color: Colors.white54, fontSize: 14)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 240, // Taller for immersive cards
                          child: ListView.separated(
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
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                // Shopping List Section (Replaces Baskets)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildShoppingList(context, nutrition),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                // Saved Baskets (Restored)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Сохраненные корзины', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildBasketsGrid(context, nutrition),
                      ],
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildShoppingList(BuildContext context, NutritionProvider nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             const Text('Список покупок', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
             if (nutrition.shoppingList.isNotEmpty)
               GestureDetector(
                 onTap: () => _showSaveBasketDialog(context, nutrition),
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(color: accentGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                   child: Row(
                     children: const [
                       Icon(Icons.save, color: accentGreen, size: 16),
                       SizedBox(width: 4),
                       Text('Сохранить', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                     ],
                   ),
                 ),
               ),
           ],
        ),
        const SizedBox(height: 16),
        
        // Add Item Field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _shoppingItemController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Добавить продукт...',
                    hintStyle: TextStyle(color: Colors.white38),
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
                icon: const Icon(Icons.add_circle, color: accentGreen),
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
        
        // List of items
        if (nutrition.shoppingList.isEmpty)
           const Center(
             child: Padding(
               padding: EdgeInsets.all(20.0),
               child: Text('Список пуст', style: TextStyle(color: Colors.white24)),
             ),
           )
        else
          Container(
            decoration: BoxDecoration(
              color: cardGreen.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: nutrition.shoppingList.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                final item = nutrition.shoppingList[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  leading: Checkbox(
                    value: item.isChecked,
                    activeColor: accentGreen,
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.white54, width: 2),
                    onChanged: (val) => nutrition.toggleShoppingItem(index),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      color: item.isChecked ? Colors.white38 : Colors.white,
                      decoration: item.isChecked ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white38,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white24, size: 18),
                    onPressed: () => nutrition.removeFromShoppingList(index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, NutritionProvider nutrition) {
    // Generate dates (Mon-Sun of current week)
    final now = DateTime.now();
    // Start from Monday of this week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final dates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Text(
            'Питание',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = date.year == nutrition.currentDate.year && date.month == nutrition.currentDate.month && date.day == nutrition.currentDate.day;
              
              return GestureDetector(
                onTap: () => nutrition.setDate(date),
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdays[index],
                        style: TextStyle(color: isSelected ? Colors.black : Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${date.day}',
                        style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopStats(BuildContext context, NutritionProvider nutrition) {
    // Dynamic greeting based on time
    final hour = DateTime.now().hour;
    String timeMessage = 'Пара перекусить!';
    if (hour >= 5 && hour < 11) timeMessage = 'Пора завтракать!';
    else if (hour >= 11 && hour < 16) timeMessage = 'Пора обедать!';
    else if (hour >= 16 && hour < 22) timeMessage = 'Пора ужинать!';
    
    return Row(
      children: [
        Expanded(child: _buildStatCard('Масса тела', '${_targetWeight.toInt()}кг', onTap: () => _showWeightDialog(context))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Инд. макс.', '${nutrition.calorieGoal.toInt()}кк', onTap: () => _showCalculatorDialog(context, nutrition))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Сейчас', timeMessage)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStats(BuildContext context, NutritionProvider nutrition) {
    // Calculate totals using getMeals method
    final allMeals = [
      ...nutrition.getMeals(MealType.breakfast), 
      ...nutrition.getMeals(MealType.lunch), 
      ...nutrition.getMeals(MealType.dinner), 
      ...nutrition.getMeals(MealType.snack)
    ];
    
    final currentCal = allMeals.fold(0.0, (s, p) => s + p.actualCalories);
    final currentP = allMeals.fold(0.0, (s, p) => s + p.actualProteins);
    final currentF = allMeals.fold(0.0, (s, p) => s + p.actualFats);
    final currentC = allMeals.fold(0.0, (s, p) => s + p.actualCarbs);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Calories Row (Big)
          _buildStatRow('Калории', currentCal, nutrition.calorieGoal, Colors.white, isMain: true),
          const SizedBox(height: 24),
          // Macros Row
          Row(
            children: [
              Expanded(child: _buildStatRow('Белки', currentP, nutrition.proteinGoal, const Color(0xFFFF5252))), // Red accent
              const SizedBox(width: 12),
              Expanded(child: _buildStatRow('Жиры', currentF, nutrition.fatGoal, const Color(0xFFFFD740))), // Amber accent
              const SizedBox(width: 12),
              Expanded(child: _buildStatRow('Углеводы', currentC, nutrition.carbGoal, const Color(0xFF448AFF))), // Blue accent
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double current, double goal, Color color, {bool isMain = false}) {
    final percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    
    // For main (Calories), keep Row layout. For 3-column macros, use Column layout to prevent overflow.
    if (isMain) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '${current.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    TextSpan(text: ' / ${goal.toInt()}', style: const TextStyle(color: Colors.white38, fontSize: 13, fontFamily: 'Courier')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(isMain, percent, color),
        ],
      );
    } else {
      // Compact column layout for mapped stats
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '${current.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  TextSpan(text: '/${goal.toInt()}', style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'Courier')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildProgressBar(isMain, percent, color),
        ],
      );
    }
  }

  Widget _buildProgressBar(bool isMain, double percent, Color color) {
    return Stack(
      children: [
        Container(
          height: isMain ? 10 : 6,
          decoration: BoxDecoration(
            color: Colors.white10,
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

  Widget _buildMealRow(BuildContext context, NutritionProvider nutrition, MealType type, String title, String rangeHint) {
    final products = nutrition.getMeals(type);
    final cal = products.fold(0.0, (s, p) => s + p.actualCalories).toInt();
    final p = products.fold(0.0, (s, p) => s + p.actualProteins).toInt();
    final f = products.fold(0.0, (s, p) => s + p.actualFats).toInt();
    final c = products.fold(0.0, (s, p) => s + p.actualCarbs).toInt();
    
    final hasData = products.isNotEmpty;
    // User requested "пока пусто" if no data, instead of placeholder numbers
    final displayStr = hasData ? '$cal - $p - $f - $c' : 'Пока пусто';

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent, 
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (hasData) {
                  _showMealDetailsDialog(context, type, title);
                } else {
                  _showAddMealDialog(context, nutrition, type);
                }
              },
              child: Row(
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const Spacer(),
                  Text(
                    displayStr,
                    style: TextStyle(
                      color: hasData ? Colors.white : Colors.white38,
                      fontSize: 14,
                      fontFamily: hasData ? 'Courier' : null, // Monospace only for numbers
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showAddMealDialog(context, nutrition, type),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 16),
            ),
          ),
        ],
      ),
    );
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
            color: cardGreen,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(c.$1, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(c.$2, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildChefInput(BuildContext context, NutritionProvider nutrition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ingredientController, 
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Помидор, сыр, яйцо...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (value) {
                  final items = value.split(',').where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList();
                  for (var item in items) {
                    nutrition.addToFridge(item);
                  }
                  _ingredientController.clear();
                }
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
                color: accentGreen,
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
                color: nutrition.useAiChef ? Colors.purpleAccent : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: nutrition.useAiChef ? Colors.white : Colors.white54, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showAiSettings(BuildContext context, NutritionProvider nutrition) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('AI Шеф-повар 🤖', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Для работы умного поиска рецептов (как в промпте) нужен API ключ Gemini.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Вставьте Gemini API Key',
                hintStyle: TextStyle(color: Colors.white30),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentGreen)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                nutrition.setAiApiKey(controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI Шеф активирован! 🔥'))
                );
              }
            },
            child: const Text('Сохранить', style: TextStyle(color: accentGreen)),
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
          color: cardGreen,
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: recipe.videoThumbnail != null 
                ? AssetImage(recipe.videoThumbnail!) 
                : (recipe.videoUrl != null && (recipe.videoUrl!.startsWith('http') || recipe.videoUrl!.isNotEmpty))
                   ? NetworkImage(recipe.videoThumbnail ?? 'https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg') 
                   : const AssetImage('assets/images/nutrition_bg.png') as ImageProvider,
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: Stack(
          children: [
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
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: accentGreen, size: 12),
                      const SizedBox(width: 4),
                      Text('${recipe.cookTime} мин', style: const TextStyle(color: Colors.white70, fontSize: 10)),
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

  Widget _buildRecipeCardLarge(BuildContext context, RecipeData recipe) {
    return GestureDetector(
      onTap: () => _showRecipeDetails(context, recipe),
      child: Container(
        width: 280, 
        decoration: BoxDecoration(
          color: cardGreen,
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: recipe.videoThumbnail != null 
                ? AssetImage(recipe.videoThumbnail!) 
                : const AssetImage('assets/images/nutrition_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: Stack(
          children: [
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Перейти',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
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
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  // --- Dialogs ---

  void _showSaveBasketDialog(BuildContext context, NutritionProvider nutrition) {
    String name = 'Корзина ${nutrition.productSets.length + 1}';
    final controller = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardGreen,
        title: const Text('Сохранить корзину', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text('Поместить текущий список продуктов в раздел "Корзины"?', style: TextStyle(color: Colors.white70)),
             const SizedBox(height: 16),
             TextField(
               controller: controller,
               autofocus: true,
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(
                hintText: 'Название корзины',
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                 focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentGreen)),
              ),
             ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
               if (controller.text.isNotEmpty) {
                 nutrition.saveShoppingListToSet(controller.text.trim());
                 Navigator.pop(ctx);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Список сохранен в корзины')));
               }
            }, 
            child: const Text('Сохранить', style: TextStyle(color: accentGreen))
          ),
        ],
      ),
    );
  }

  Widget _buildBasketsGrid(BuildContext context, NutritionProvider nutrition) {
    final sets = nutrition.productSets;
    if (sets.isEmpty) return const Text('Нет сохраненных корзин', style: TextStyle(color: Colors.white38));

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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardGreen,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(set.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: set.products.take(3).map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• ${p.name}', style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                nutrition.addSetToShoppingList(set);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Продукты добавлены в текущий список'),
                  backgroundColor: accentGreen,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('Выбрать', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
              ),
            ),
          ],
        ),
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
            color: bgGreen,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const Text('Калькулятор КБЖУ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Gender
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black26, 
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildSelectableTab('Мужчина', isMale, () => setState(() => isMale = true))),
                          Expanded(child: _buildSelectableTab('Женщина', !isMale, () => setState(() => isMale = false))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Params
                    Row(
                      children: [
                        Expanded(child: _buildInputCard('Возраст', ageController, 'лет')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInputCard('Рост', heightController, 'см')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInputCard('Вес', weightController, 'кг')),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Уровень активности', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildActivityOption('Сидячий', 'Без нагрузок', 1.2, activity, (v) => setState(() => activity = v)),
                    _buildActivityOption('Малый', '1-3 тренировки', 1.375, activity, (v) => setState(() => activity = v)),
                    _buildActivityOption('Средний', '3-5 тренировок', 1.55, activity, (v) => setState(() => activity = v)),
                    _buildActivityOption('Высокий', '6-7 тренировок', 1.725, activity, (v) => setState(() => activity = v)),
                    
                    const SizedBox(height: 24),
                    const Text('Ваша цель', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildGoalOption('Похудеть', 'lose', goal, (v) => setState(() => goal = v))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildGoalOption('Держать', 'maintain', goal, (v) => setState(() => goal = v))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildGoalOption('Набрать', 'gain', goal, (v) => setState(() => goal = v))),
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
                          // Logic remains same
                          final age = double.tryParse(ageController.text) ?? 25;
                          final height = double.tryParse(heightController.text) ?? 175;
                          final weight = double.tryParse(weightController.text) ?? _targetWeight;

                          double bmr = isMale 
                              ? 10 * weight + 6.25 * height - 5 * age + 5
                              : 10 * weight + 6.25 * height - 5 * age - 161;

                          double tdee = bmr * activity;
                          if (goal == 'lose') tdee *= 0.8;
                          if (goal == 'gain') tdee *= 1.15;

                          final p = weight * 2; // 2g/kg
                          final f = (tdee * 0.25) / 9; // 25%
                          final c = (tdee - (p * 4 + f * 9)) / 4;

                          nutrition.setGoals(calories: tdee, proteins: p, fats: f, carbs: c < 0 ? 0 : c);
                          setState(() => _targetWeight = weight);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('План питания обновлен!')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Рассчитать программу', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                         Navigator.pop(ctx); 
                         _showManualGoalDialog(context, nutrition);
                      }, 
                      child: const Text('Ввести вручную', style: TextStyle(color: Colors.white54))
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

  Widget _buildSelectableTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white54, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildInputCard(String label, TextEditingController controller, String suffix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              isDense: true,
              hintText: '0',
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              suffixText: suffix,
              suffixStyle: const TextStyle(color: accentGreen, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Compatibility helper for manual dialog
  Widget _buildCalcInput(String label, TextEditingController controller) {
    return _buildInputCard(label, controller, ''); 
  }

  Widget _buildActivityOption(String title, String subtitle, double value, double groupValue, Function(double) onChanged) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentGreen.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? accentGreen : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? accentGreen : Colors.white24, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String label, String value, String groupValue, Function(String) onChanged) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? accentGreen : cardGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? accentGreen : Colors.white10),
        ),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
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
         backgroundColor: cardGreen,
         title: const Text('Ручная настройка', style: TextStyle(color: Colors.white)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             _buildCalcInput('Калории', cController),
             const SizedBox(height: 8),
             _buildCalcInput('Белки (г)', pController),
             const SizedBox(height: 8),
             _buildCalcInput('Жиры (г)', fController),
             const SizedBox(height: 8),
             _buildCalcInput('Углеводы (г)', carbController),
           ],
         ),
         actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена', style: TextStyle(color: Colors.white54))),
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
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen),
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
        backgroundColor: cardGreen,
        title: const Text('Целевой вес', style: TextStyle(color: Colors.white)),
        content: TextField(
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'кг',
            hintStyle: TextStyle(color: Colors.white38),
            filled: true,
            fillColor: bgGreen,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (v) {
            final w = double.tryParse(v);
            if (w != null) setState(() => _targetWeight = w);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }


  void _showAddMealDialog(BuildContext context, NutritionProvider nutrition, MealType mealType) {
    // 0 = search, 1 = custom, 2 = my dishes
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
            color: bgGreen,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              
              // Toggle tabs - now 3 tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 0 ? accentGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text('Поиск', style: TextStyle(color: selectedTab == 0 ? Colors.black : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 1 ? accentGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text('Свое', style: TextStyle(color: selectedTab == 1 ? Colors.black : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedTab = 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 2 ? accentGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text('Мои', style: TextStyle(color: selectedTab == 2 ? Colors.black : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab 0: Search
              if (selectedTab == 0) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Поиск продуктов...',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38),
                      filled: true,
                      fillColor: cardGreen,
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
                        return const Center(child: Text('Введите название продукта', style: TextStyle(color: Colors.white38)));
                      }
                      final p = results[i];
                      return ListTile(
                        leading: p.imagePath != null 
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(p.imagePath!), width: 40, height: 40, fit: BoxFit.cover),
                            )
                          : Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: cardGreen, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.restaurant, color: Colors.white38, size: 20),
                            ),
                        title: Text(p.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text('${p.calories.toInt()} ккал | Б${p.proteins.toInt()} Ж${p.fats.toInt()} У${p.carbs.toInt()} на 100г', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        trailing: const Icon(Icons.add_circle, color: accentGreen),
                        onTap: () {
                           Navigator.pop(ctx);
                           _showGramsDialog(context, p, (newProduct) {
                              nutrition.addToMeal(mealType, newProduct);
                           });
                        },
                      );
                    },
                  ),
                ),
              ] 
              // Tab 1: Custom Meal Form
              else if (selectedTab == 1) ...[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Photo picker
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final source = await showModalBottomSheet<ImageSource>(
                              context: context,
                              backgroundColor: cardGreen,
                              builder: (ctx) => Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt, color: accentGreen),
                                      title: const Text('Камера', style: TextStyle(color: Colors.white)),
                                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library, color: accentGreen),
                                      title: const Text('Галерея', style: TextStyle(color: Colors.white)),
                                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            
                            if (source != null) {
                              final XFile? image = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
                              if (image != null) {
                                // Save to app directory
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
                              color: cardGreen,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: selectedImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(File(selectedImagePath!), fit: BoxFit.cover),
                                      Positioned(
                                        top: 8, right: 8,
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
                                    Icon(Icons.add_a_photo, color: Colors.white38, size: 32),
                                    SizedBox(height: 8),
                                    Text('Добавить фото', style: TextStyle(color: Colors.white38)),
                                  ],
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInputCard('Название блюда', nameController, ''),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildInputCard('Калории', calController, 'ккал')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildInputCard('Белки', pController, 'г')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildInputCard('Жиры', fController, 'г')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildInputCard('Углеводы', carbController, 'г')),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Save Checkbox
                        Row(
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: saveToMyDishes,
                                onChanged: (v) => setModalState(() => saveToMyDishes = v ?? false),
                                activeColor: accentGreen,
                                checkColor: Colors.black,
                                side: const BorderSide(color: Colors.white54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const Text('Сохранить в "Мои блюда"', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                                  Navigator.pop(ctx);
                               }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Добавить', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
              // Tab 2: My Dishes
              else ...[
                Expanded(
                  child: nutrition.userProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.restaurant_menu, color: Colors.white24, size: 48),
                            SizedBox(height: 16),
                            Text('Нет сохранённых блюд', style: TextStyle(color: Colors.white38, fontSize: 16)),
                            SizedBox(height: 8),
                            Text('Создайте блюдо во вкладке "Свое"', style: TextStyle(color: Colors.white24, fontSize: 13)),
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
                              color: cardGreen,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: p.imagePath != null 
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(File(p.imagePath!), width: 50, height: 50, fit: BoxFit.cover),
                                  )
                                : Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(color: bgGreen, borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.restaurant, color: Colors.white38, size: 24),
                                  ),
                              title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${p.calories.toInt()} ккал • Б${p.proteins.toInt()} Ж${p.fats.toInt()} У${p.carbs.toInt()}',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.add_circle, color: accentGreen, size: 28),
                              onTap: () {
                                Navigator.pop(ctx);
                                _showGramsDialog(context, p, (newProduct) {
                                  nutrition.addToMeal(mealType, newProduct);
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
            color: bgGreen,
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
                  Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('$totalCal ккал', style: const TextStyle(color: accentGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Row(
                      children: [
                        Text('Б: $totalP  Ж: $totalF  У: $totalC', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white12),
                  Expanded(
                    child: products.isEmpty
                        ? const Center(child: Text('Нет продуктов', style: TextStyle(color: Colors.white38)))
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.only(bottom: 40),
                            itemCount: products.length,
                            separatorBuilder: (_, __) => const Divider(color: Colors.white12, indent: 20, endIndent: 20),
                            itemBuilder: (ctx, index) {
                              final p = products[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                title: Text(p.name, style: const TextStyle(color: Colors.white)),
                                subtitle: Text(
                                  '${p.grams.toInt()}г • ${p.actualCalories.toInt()} ккал\nБ: ${p.actualProteins.toInt()} Ж: ${p.actualFats.toInt()} У: ${p.actualCarbs.toInt()}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    nutrition.removeProductFromMeal(type, p);
                                  },
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
                          backgroundColor: accentGreen,
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
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cardGreen,
          title: Text(product.name, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 28),
                decoration: InputDecoration(
                  suffixText: 'г',
                  suffixStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: bgGreen,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setDialogState(() => grams = double.tryParse(v) ?? 100),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bgGreen, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPreviewNutrient('Ккал', (product.calories * grams / 100).toInt(), Colors.orange),
                    _buildPreviewNutrient('Б', (product.proteins * grams / 100).toInt(), Colors.red),
                    _buildPreviewNutrient('Ж', (product.fats * grams / 100).toInt(), Colors.amber),
                    _buildPreviewNutrient('У', (product.carbs * grams / 100).toInt(), Colors.blue),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final g = double.tryParse(controller.text) ?? 100;
                final newProduct = Product(
                  name: product.name,
                  calories: product.calories,
                  proteins: product.proteins,
                  fats: product.fats,
                  carbs: product.carbs,
                  grams: g,
                );
                onConfirm(newProduct);
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen),
              child: const Text('Добавить', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
      ),
    ),
    );
  }

  Widget _buildPreviewNutrient(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.white54, fontSize: 10)),
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
          color: bgGreen,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
            Expanded(
              child: recipes.isEmpty
                  ? Center(child: Text('Рецептов пока нет', style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recipes.length,
                      itemBuilder: (context, i) {
                        final r = recipes[i];
                        return ListTile(
                          title: Text(r.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text('${r.cookTime} мин • ${r.calories.toInt()} ккал', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white38),
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
          color: cardGreen,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(set.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                          Expanded(child: Text(p.name, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis)),
                          Text('${p.grams.toInt()}г', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
             if (set.products.isEmpty)
                const Text('В корзине нет продуктов', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  nutrition.addSetToShoppingList(set);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${set.name} добавлен в список')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Добавить в список', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
