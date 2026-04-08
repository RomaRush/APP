import 'dart:math';
import '../services/open_food_facts_service.dart';
import '../providers/nutrition_provider.dart';

/// AI Service for recipe generation and product suggestions
/// Uses demo mode with predefined recipes. Can be extended with Gemini API.
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Demo recipes database
  static final List<Recipe> _recipes = [
    // Breakfast
    Recipe(
      name: 'Овсянка с фруктами',
      category: 'breakfast',
      ingredients: ['овсянка', 'банан', 'мёд', 'молоко'],
      steps: [
        'Залейте овсянку молоком и поставьте на огонь',
        'Варите 5-7 минут помешивая',
        'Нарежьте банан кружочками',
        'Выложите кашу в тарелку, добавьте банан и мёд',
      ],
      calories: 350,
      proteins: 12,
      fats: 8,
      carbs: 55,
      cookTime: 15,
    ),
    Recipe(
      name: 'Омлет с овощами',
      category: 'breakfast',
      ingredients: ['яйца', 'помидоры', 'перец', 'сыр', 'молоко'],
      steps: [
        'Взбейте яйца с молоком',
        'Нарежьте овощи кубиками',
        'Обжарьте овощи на сковороде 3 минуты',
        'Залейте яичной смесью и готовьте под крышкой',
        'Посыпьте тёртым сыром',
      ],
      calories: 420,
      proteins: 28,
      fats: 32,
      carbs: 8,
      cookTime: 15,
    ),
    Recipe(
      name: 'Творожная запеканка',
      category: 'breakfast',
      ingredients: ['творог', 'яйца', 'сахар', 'манка', 'изюм'],
      steps: [
        'Смешайте творог с яйцами и сахаром',
        'Добавьте манку и изюм',
        'Выложите в форму и запекайте 30 минут при 180°',
      ],
      calories: 280,
      proteins: 18,
      fats: 12,
      carbs: 25,
      cookTime: 45,
    ),
    // Meat
    Recipe(
      name: 'Куриная грудка с овощами',
      category: 'meat',
      ingredients: ['курица', 'брокколи', 'морковь', 'чеснок', 'соевый соус'],
      steps: [
        'Нарежьте курицу на кусочки',
        'Обжарьте курицу до золотистой корочки',
        'Добавьте нарезанные овощи',
        'Влейте соевый соус и тушите 10 минут',
      ],
      calories: 380,
      proteins: 45,
      fats: 12,
      carbs: 15,
      cookTime: 25,
    ),
    Recipe(
      name: 'Котлеты домашние',
      category: 'meat',
      ingredients: ['фарш', 'лук', 'яйцо', 'хлеб', 'специи'],
      steps: [
        'Замочите хлеб в молоке',
        'Смешайте фарш с луком, яйцом и хлебом',
        'Сформируйте котлеты',
        'Обжарьте с двух сторон до готовности',
      ],
      calories: 450,
      proteins: 32,
      fats: 28,
      carbs: 18,
      cookTime: 30,
    ),
    // Salads
    Recipe(
      name: 'Греческий салат',
      category: 'salad',
      ingredients: ['огурцы', 'помидоры', 'перец', 'фета', 'оливки', 'оливковое масло'],
      steps: [
        'Нарежьте овощи крупными кубиками',
        'Добавьте оливки и кубики феты',
        'Заправьте оливковым маслом',
        'Посолите и поперчите по вкусу',
      ],
      calories: 220,
      proteins: 8,
      fats: 18,
      carbs: 10,
      cookTime: 10,
    ),
    Recipe(
      name: 'Цезарь с курицей',
      category: 'salad',
      ingredients: ['салат', 'курица', 'сыр пармезан', 'сухарики', 'соус цезарь'],
      steps: [
        'Обжарьте курицу и нарежьте полосками',
        'Порвите листья салата',
        'Смешайте с курицей и сухариками',
        'Заправьте соусом и посыпьте пармезаном',
      ],
      calories: 380,
      proteins: 32,
      fats: 22,
      carbs: 15,
      cookTime: 20,
    ),
    // Soups
    Recipe(
      name: 'Борщ',
      category: 'soup',
      ingredients: ['свёкла', 'капуста', 'картофель', 'морковь', 'лук', 'мясо'],
      steps: [
        'Сварите мясной бульон',
        'Добавьте картофель',
        'Обжарьте свёклу, морковь и лук',
        'Добавьте зажарку и капусту',
        'Варите до готовности, подавайте со сметаной',
      ],
      calories: 180,
      proteins: 12,
      fats: 8,
      carbs: 20,
      cookTime: 90,
    ),
    Recipe(
      name: 'Куриный суп с лапшой',
      category: 'soup',
      ingredients: ['курица', 'лапша', 'морковь', 'лук', 'зелень'],
      steps: [
        'Сварите куриный бульон',
        'Достаньте курицу и нарежьте',
        'Добавьте морковь и лук',
        'За 5 минут до готовности добавьте лапшу',
        'Посыпьте зеленью при подаче',
      ],
      calories: 150,
      proteins: 14,
      fats: 5,
      carbs: 12,
      cookTime: 45,
    ),
    // Garnish
    Recipe(
      name: 'Картофельное пюре',
      category: 'garnish',
      ingredients: ['картофель', 'молоко', 'сливочное масло', 'соль'],
      steps: [
        'Отварите картофель до готовности',
        'Слейте воду и разомните',
        'Добавьте горячее молоко и масло',
        'Взбейте до пышности',
      ],
      calories: 180,
      proteins: 4,
      fats: 8,
      carbs: 25,
      cookTime: 30,
    ),
    Recipe(
      name: 'Рис с овощами',
      category: 'garnish',
      ingredients: ['рис', 'морковь', 'горошек', 'кукуруза', 'соевый соус'],
      steps: [
        'Отварите рис',
        'Обжарьте морковь',
        'Добавьте горошек и кукурузу',
        'Смешайте с рисом и соевым соусом',
      ],
      calories: 220,
      proteins: 6,
      fats: 4,
      carbs: 42,
      cookTime: 25,
    ),
    // Fish
    Recipe(
      name: 'Запечённый лосось',
      category: 'fish',
      ingredients: ['лосось', 'лимон', 'чеснок', 'укроп', 'оливковое масло'],
      steps: [
        'Натрите рыбу специями и чесноком',
        'Сбрызните лимоном и маслом',
        'Запекайте 20 минут при 200°',
        'Украсьте укропом',
      ],
      calories: 320,
      proteins: 35,
      fats: 18,
      carbs: 2,
      cookTime: 25,
    ),
    // Snacks
    Recipe(
      name: 'Брускетты с томатами',
      category: 'snack',
      ingredients: ['багет', 'помидоры', 'базилик', 'чеснок', 'оливковое масло'],
      steps: [
        'Нарежьте багет и подсушите в духовке',
        'Натрите чесноком',
        'Выложите нарезанные томаты',
        'Добавьте базилик и сбрызните маслом',
      ],
      calories: 180,
      proteins: 5,
      fats: 8,
      carbs: 22,
      cookTime: 15,
    ),
    // Desserts
    Recipe(
      name: 'Панкейки',
      category: 'dessert',
      ingredients: ['мука', 'яйца', 'молоко', 'сахар', 'разрыхлитель'],
      steps: [
        'Смешайте сухие ингредиенты',
        'Добавьте яйца и молоко',
        'Взбейте до однородности',
        'Жарьте на сковороде с двух сторон',
        'Подавайте с мёдом или ягодами',
      ],
      calories: 280,
      proteins: 8,
      fats: 10,
      carbs: 40,
      cookTime: 20,
    ),
  ];

  // Category mapping
  static const Map<String, List<String>> categoryKeywords = {
    'breakfast': ['завтрак', 'утро', 'каша', 'омлет'],
    'meat': ['мясо', 'курица', 'говядина', 'свинина', 'котлеты'],
    'salad': ['салат', 'овощи', 'лёгкое'],
    'soup': ['суп', 'борщ', 'бульон', 'первое'],
    'garnish': ['гарнир', 'рис', 'картофель', 'пюре'],
    'fish': ['рыба', 'лосось', 'морепродукты'],
    'snack': ['закуска', 'перекус', 'брускетта'],
    'dessert': ['десерт', 'сладкое', 'выпечка', 'торт'],
  };

  /// Get recipes by category
  List<Recipe> getRecipesByCategory(String category) {
    return _recipes.where((r) => r.category == category).toList();
  }

  /// Get all recipes
  List<Recipe> getAllRecipes() => List.from(_recipes);

  /// Get random recipes
  List<Recipe> getRandomRecipes(int count) {
    final shuffled = List<Recipe>.from(_recipes)..shuffle(Random());
    return shuffled.take(count).toList();
  }

  /// Generate recipe from ingredients (demo version)
  Future<Recipe?> generateRecipeFromIngredients(List<String> ingredients) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (ingredients.isEmpty) return null;

    // Find recipes that match at least some ingredients
    final lowerIngredients = ingredients.map((i) => i.toLowerCase()).toList();
    
    Recipe? bestMatch;
    int bestScore = 0;

    for (final recipe in _recipes) {
      int score = 0;
      for (final ingredient in recipe.ingredients) {
        if (lowerIngredients.any((i) => ingredient.toLowerCase().contains(i) || i.contains(ingredient.toLowerCase()))) {
          score++;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestMatch = recipe;
      }
    }

    if (bestMatch != null && bestScore >= 1) {
      return bestMatch;
    }

    // If no match, return a random recipe with a note
    return _recipes[Random().nextInt(_recipes.length)];
  }

  /// Search for product nutrition (demo version)
  Future<ProductNutrition?> searchProductNutrition(String productName) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Local product database lookup would happen here
    // For now, return null to indicate using local database
    return null;
  }
  /// Process user natural language command
  Future<String> processUserCommand(String text, dynamic nutritionProvider) async {
    final lower = text.toLowerCase().trim();
    
    // 1. Check for "Eat" intent relative to Russian language
    bool isEat = lower.contains('съел') || lower.contains('выпил') || lower.contains('поел') || lower.contains('добавь');
    if (!isEat) {
      if (lower.contains('привет') || lower.contains('как дела')) return 'Привет! Я могу помочь записать вашу еду. Просто напишите "Съел яблоко".';
      return 'Я пока понимаю только команды о еде, например: "Съел банан".';
    }

    // 2. Extract product name
    // Remove keywords
    String query = lower.replaceAll('съел', '').replaceAll('выпил', '').replaceAll('поел', '').replaceAll('добавь', '').trim();
    
    if (query.isEmpty) return 'Что именно вы съели?';

    // 3. Search Product via OpenFoodFacts (using the service you have)
    // We need to import OpenFoodFactsService. 
    // Since we can't easily import here without top-level changes, we assume it's available or we pass it? 
    // Let's rely on the service being static or singleton.
    
    // We will use a callback or dynamic lookup if import is tricky, but let's try to add import at top next.
    // For now, let's assume we can search.
    try {
        final products = await OpenFoodFactsService.searchProducts(query);
        if (products.isNotEmpty) {
           final product = products.first;
           // Determine meal type by time
           final hour = DateTime.now().hour;
           MealType type = MealType.breakfast;
           if (hour >= 12 && hour < 17) type = MealType.lunch;
           if (hour >= 17) type = MealType.dinner;
           if (hour >= 21 || hour < 6) type = MealType.snack;
           
           // We need to cast nutritionProvider to NutritionProvider
           if (nutritionProvider is NutritionProvider) {
             nutritionProvider.addToMeal(type, product);
             return 'Добавлено: ${product.name} (${product.calories.round()} ккал) в ${_getMealName(type)}.';
           }
           return 'Ошибка доступа к данным питания.';
        } else {
           return 'Не удалось найти продукт "$query". Попробуйте уточнить название.';
        }
    } catch (e) {
      return 'Ошибка при обработке запроса: $e';
    }
  }

  String _getMealName(MealType type) {
    switch (type) {
      case MealType.breakfast: return 'Завтрак';
      case MealType.lunch: return 'Обед';
      case MealType.dinner: return 'Ужин';
      case MealType.snack: return 'Перекус';
    }
  }
}

class Recipe {
  final String name;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final int cookTime; // in minutes

  Recipe({
    required this.name,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.cookTime,
  });
}

class ProductNutrition {
  final String name;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;

  ProductNutrition({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.fatsPer100g,
    required this.carbsPer100g,
  });
}
