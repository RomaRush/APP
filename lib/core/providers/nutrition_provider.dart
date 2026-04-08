import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/open_food_facts_service.dart';
import '../services/notification_service.dart';
import '../services/recipe_service.dart';
import '../services/ai_recipe_service.dart';
import '../data/recipe_database.dart';

// Product model
class Product {
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final String? imagePath; // Path to dish photo
  double grams;
  final int price; // Price in rubles

  Product({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    this.imagePath,
    this.grams = 100,
    this.price = 0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'calories': calories,
    'proteins': proteins,
    'fats': fats,
    'carbs': carbs,
    'imagePath': imagePath,
    'grams': grams,
    'price': price,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    name: json['name'],
    calories: (json['calories'] as num).toDouble(),
    proteins: (json['proteins'] as num).toDouble(),
    fats: (json['fats'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
    imagePath: json['imagePath'],
    grams: (json['grams'] as num?)?.toDouble() ?? 100,
    price: (json['price'] as num?)?.toInt() ?? 0,
  );

  // Calculate for actual grams
  double get actualCalories => calories * grams / 100;
  double get actualProteins => proteins * grams / 100;
  double get actualFats => fats * grams / 100;
  double get actualCarbs => carbs * grams / 100;
  
  // Copy with grams for meal tracking
  Product copyWith({double? grams, String? imagePath}) => Product(
    name: name,
    calories: calories,
    proteins: proteins,
    fats: fats,
    carbs: carbs,
    imagePath: imagePath ?? this.imagePath,
    grams: grams ?? this.grams,
  );
}


// Meal type enum
enum MealType { breakfast, lunch, dinner, snack }

// Drink type enum
enum DrinkType { water, tea, coffee, juice, soda, other }

class DrinkLog {
  final DrinkType type;
  final DateTime time;
  final int amountMl;

  DrinkLog({required this.type, required this.time, required this.amountMl});

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'time': time.toIso8601String(),
    'amountMl': amountMl,
  };

  factory DrinkLog.fromJson(Map<String, dynamic> json) => DrinkLog(
    type: DrinkType.values[json['type'] as int],
    time: DateTime.parse(json['time'] as String),
    amountMl: json['amountMl'] as int,
  );
}

// Product set model
class ProductSet {
  final String name;
  final String description;
  final String imagePath;
  List<Product> products;

  ProductSet({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.products,
  });
}

// Shopping list item model
class ShoppingItem {
  final String name;
  bool isChecked;

  ShoppingItem({
    required this.name,
    this.isChecked = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'isChecked': isChecked,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    name: json['name'],
    isChecked: json['isChecked'] ?? false,
  );
}

class NutritionProvider extends ChangeNotifier {
  // Daily goals
  double _calorieGoal = 2200;
  double _proteinGoal = 160;
  double _fatGoal = 100;
  double _carbGoal = 50;

  // Current date
  DateTime _currentDate = DateTime.now();

  // Meals for each day: "YYYY-MM-DD" -> { mealType: [products] }
  Map<String, Map<String, List<Product>>> _meals = {};

  // Shopping cart
  List<Product> _cart = [];

  // Ingredients for recipe generator
  List<String> _ingredients = [];

  // Shopping list
  List<ShoppingItem> _shoppingList = [];
  
  // Drink logs for today
  List<DrinkLog> _todaysDrinks = [];
  
  // Fridge Inventory
  final List<String> _fridgeInventory = []; // List of product names available
  
  // User created products
  List<Product> _userProducts = [];
  
  // API Recipe Search
  RecipeService _recipeService = TheMealDBService();
  List<RecipeData> _foundRecipes = [];
  bool _isSearchingRecipes = false;
  
  // AI Config
  String? _aiApiKey;
  bool _useAiChef = false;
  
  void setAiApiKey(String key) {
    _aiApiKey = key;
    _useAiChef = true;
    _recipeService = AiRecipeService(key);
    notifyListeners();
  }
  
  void toggleAiChef(bool value) {
    _useAiChef = value;
    if (_useAiChef && _aiApiKey != null) {
      _recipeService = AiRecipeService(_aiApiKey!);
    } else {
      _recipeService = TheMealDBService();
    }
    notifyListeners();
  }

  // Getters
  double get calorieGoal => _calorieGoal;
  bool get useAiChef => _useAiChef;
  bool get hasAiKey => _aiApiKey != null && _aiApiKey!.isNotEmpty;
  double get proteinGoal => _proteinGoal;
  double get fatGoal => _fatGoal;
  double get carbGoal => _carbGoal;
  DateTime get currentDate => _currentDate;
  List<Product> get cart => _cart;
  List<String> get ingredients => _ingredients;
  List<ShoppingItem> get shoppingList => _shoppingList;
  List<String> get fridgeInventory => _fridgeInventory;
  List<Product> get userProducts => _userProducts;
  List<RecipeData> get foundRecipes => _foundRecipes;
  bool get isSearchingRecipes => _isSearchingRecipes;
  List<DrinkLog> get todaysDrinks => _todaysDrinks;

  String get _dateKey => '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}';

  // Get meals for current day
  List<Product> getMeals(MealType type) {
    final dayMeals = _meals[_dateKey];
    if (dayMeals == null) return [];
    return dayMeals[type.name] ?? [];
  }

  // Calculate totals for current day
  double get totalCalories => _calculateTotal((p) => p.actualCalories);
  double get totalProteins => _calculateTotal((p) => p.actualProteins);
  double get totalFats => _calculateTotal((p) => p.actualFats);
  double get totalCarbs => _calculateTotal((p) => p.actualCarbs);

  double _calculateTotal(double Function(Product) getter) {
    double total = 0;
    final dayMeals = _meals[_dateKey];
    if (dayMeals == null) return 0;
    for (var mealProducts in dayMeals.values) {
      for (var product in mealProducts) {
        total += getter(product);
      }
    }
    return total;
  }

  // Predefined product sets
  List<ProductSet> _productSets = [
    ProductSet(
      name: 'Бюджетный набор',
      description: 'До ~3000₽ на 7–10 дней. Простой и сбалансированный.',
      imagePath: 'assets/images/set_budget.png',
      products: [
        // Белки
        Product(name: 'Куриная тушенка', calories: 190, proteins: 18, fats: 12, carbs: 1, grams: 338, price: 250),
        Product(name: 'Яйца 30шт', calories: 155, proteins: 13, fats: 11, carbs: 1.1, grams: 1800, price: 250),
        Product(name: 'Творог 5%', calories: 121, proteins: 18, fats: 5, carbs: 3, grams: 1000, price: 350),
        // Углеводы
        Product(name: 'Гречка', calories: 313, proteins: 12.6, fats: 3.3, carbs: 62, grams: 1000, price: 120),
        Product(name: 'Рис', calories: 344, proteins: 6.7, fats: 0.7, carbs: 79, grams: 1000, price: 120),
        Product(name: 'Овсянка', calories: 352, proteins: 12.3, fats: 6.1, carbs: 61, grams: 1000, price: 150),
        Product(name: 'Макароны', calories: 350, proteins: 11, fats: 1.3, carbs: 72, grams: 1000, price: 100),
        // Овощи/фрукты
        Product(name: 'Морковь', calories: 35, proteins: 1.3, fats: 0.1, carbs: 6.9, grams: 1000, price: 60),
        Product(name: 'Лук', calories: 41, proteins: 1.4, fats: 0.2, carbs: 8.2, grams: 1000, price: 60),
        Product(name: 'Капуста белокочанная', calories: 27, proteins: 1.8, fats: 0.1, carbs: 4.7, grams: 2000, price: 100),
        Product(name: 'Яблоки', calories: 52, proteins: 0.3, fats: 0.2, carbs: 14, grams: 1000, price: 200),
        // Жиры
        Product(name: 'Подсолнечное масло', calories: 899, proteins: 0, fats: 99.9, carbs: 0, grams: 1000, price: 150),
        Product(name: 'Арахисовая паста', calories: 588, proteins: 25, fats: 50, carbs: 20, grams: 350, price: 200),
      ],
    ),
    ProductSet(
      name: 'Средний набор',
      description: 'До ~6000₽ на 10–14 дней. Разнообразное питание.',
      imagePath: 'assets/images/set_medium.png',
      products: [
        // Белки
        Product(name: 'Куриное филе', calories: 113, proteins: 23.6, fats: 1.9, carbs: 0, grams: 1500, price: 600),
        Product(name: 'Яйца 30шт', calories: 155, proteins: 13, fats: 11, carbs: 1.1, grams: 1800, price: 250),
        Product(name: 'Творог 5%', calories: 121, proteins: 18, fats: 5, carbs: 3, grams: 1000, price: 350),
        Product(name: 'Минтай/хек', calories: 72, proteins: 16, fats: 0.9, carbs: 0, grams: 1200, price: 500),
        // Углеводы
        Product(name: 'Гречка', calories: 313, proteins: 12.6, fats: 3.3, carbs: 62, grams: 1000, price: 120),
        Product(name: 'Рис', calories: 344, proteins: 6.7, fats: 0.7, carbs: 79, grams: 1000, price: 120),
        Product(name: 'Овсянка', calories: 352, proteins: 12.3, fats: 6.1, carbs: 61, grams: 1000, price: 150),
        Product(name: 'Булгур/киноа', calories: 342, proteins: 12, fats: 1.3, carbs: 63, grams: 500, price: 250),
        // Овощи/фрукты
        Product(name: 'Брокколи (заморозка)', calories: 28, proteins: 3, fats: 0.4, carbs: 5.2, grams: 1000, price: 300),
        Product(name: 'Замороженные овощи', calories: 40, proteins: 2, fats: 0.2, carbs: 8, grams: 1000, price: 200),
        Product(name: 'Помидоры свежие', calories: 18, proteins: 0.9, fats: 0.2, carbs: 3.9, grams: 500, price: 150),
        Product(name: 'Огурцы', calories: 15, proteins: 0.8, fats: 0.1, carbs: 2.8, grams: 500, price: 150),
        Product(name: 'Бананы', calories: 89, proteins: 1.1, fats: 0.3, carbs: 23, grams: 1000, price: 120),
        Product(name: 'Яблоки', calories: 52, proteins: 0.3, fats: 0.2, carbs: 14, grams: 1000, price: 200),
        // Жиры
        Product(name: 'Оливковое масло', calories: 884, proteins: 0, fats: 100, carbs: 0, grams: 500, price: 450),
        Product(name: 'Орехи (миндаль/грецкие)', calories: 654, proteins: 21, fats: 56, carbs: 13, grams: 300, price: 400),
      ],
    ),
    ProductSet(
      name: 'Для массонабора',
      description: 'Высокобелковый набор для роста мышц.',
      imagePath: 'assets/images/set_mass.png',
      products: [
        // Белки (основа)
        Product(name: 'Куриное филе', calories: 113, proteins: 23.6, fats: 1.9, carbs: 0, grams: 2000, price: 800),
        Product(name: 'Фарш индейки/курицы', calories: 143, proteins: 21, fats: 7, carbs: 0, grams: 1500, price: 600),
        Product(name: 'Яйца 40шт', calories: 155, proteins: 13, fats: 11, carbs: 1.1, grams: 2400, price: 340),
        Product(name: 'Творог 9%', calories: 159, proteins: 16.7, fats: 9, carbs: 2, grams: 1500, price: 600),
        Product(name: 'Сёмга/форель', calories: 153, proteins: 20, fats: 8, carbs: 0, grams: 1000, price: 1200),
        // Углеводы
        Product(name: 'Рис', calories: 344, proteins: 6.7, fats: 0.7, carbs: 79, grams: 1500, price: 180),
        Product(name: 'Овсянка', calories: 352, proteins: 12.3, fats: 6.1, carbs: 61, grams: 1500, price: 225),
        Product(name: 'Булгур/гречка', calories: 342, proteins: 12, fats: 1.3, carbs: 63, grams: 1500, price: 180),
        // Овощи/фрукты
        Product(name: 'Брокколи (заморозка)', calories: 28, proteins: 3, fats: 0.4, carbs: 5.2, grams: 1000, price: 300),
        Product(name: 'Морковь', calories: 35, proteins: 1.3, fats: 0.1, carbs: 6.9, grams: 1000, price: 60),
        Product(name: 'Бананы', calories: 89, proteins: 1.1, fats: 0.3, carbs: 23, grams: 1000, price: 120),
        // Жиры
        Product(name: 'Арахис/миндаль', calories: 567, proteins: 26, fats: 49, carbs: 16, grams: 500, price: 650),
        Product(name: 'Оливковое масло', calories: 884, proteins: 0, fats: 100, carbs: 0, grams: 500, price: 450),
      ],
    ),
    ProductSet(
      name: 'Для похудения',
      description: 'Контроль калорий + высокая насыщаемость.',
      imagePath: 'assets/images/set_weightloss.png',
      products: [
        // Белки
        Product(name: 'Куриное филе', calories: 113, proteins: 23.6, fats: 1.9, carbs: 0, grams: 1500, price: 600),
        Product(name: 'Яйца 30шт', calories: 155, proteins: 13, fats: 11, carbs: 1.1, grams: 1800, price: 250),
        Product(name: 'Творог 5%', calories: 121, proteins: 18, fats: 5, carbs: 3, grams: 1000, price: 350),
        Product(name: 'Хек/минтай', calories: 72, proteins: 16, fats: 0.9, carbs: 0, grams: 1000, price: 500),
        // Овощи
        Product(name: 'Брокколи (заморозка)', calories: 28, proteins: 3, fats: 0.4, carbs: 5.2, grams: 1000, price: 300),
        Product(name: 'Кабачки', calories: 24, proteins: 0.6, fats: 0.3, carbs: 4.6, grams: 1000, price: 120),
        Product(name: 'Огурцы', calories: 15, proteins: 0.8, fats: 0.1, carbs: 2.8, grams: 1000, price: 300),
        Product(name: 'Помидоры', calories: 18, proteins: 0.9, fats: 0.2, carbs: 3.9, grams: 1000, price: 300),
        Product(name: 'Салат/шпинат', calories: 23, proteins: 2.9, fats: 0.4, carbs: 2.2, grams: 500, price: 250),
        // Углеводы (медленные)
        Product(name: 'Гречка', calories: 313, proteins: 12.6, fats: 3.3, carbs: 62, grams: 1000, price: 120),
        Product(name: 'Овсянка', calories: 352, proteins: 12.3, fats: 6.1, carbs: 61, grams: 1000, price: 150),
        // Жиры
        Product(name: 'Оливковое масло', calories: 884, proteins: 0, fats: 100, carbs: 0, grams: 500, price: 450),
        Product(name: 'Семена льна/чиа', calories: 534, proteins: 18, fats: 42, carbs: 29, grams: 300, price: 350),
      ],
    ),
  ];

  List<ProductSet> get productSets => _productSets;

  void addProductToSet(ProductSet set, Product product) {
    if (_productSets.contains(set)) {
      set.products.add(product);
      notifyListeners();
    }
  }

  void addProductSet(ProductSet set) {
    _productSets.add(set);
    notifyListeners();
  }

  // Local product database for search
  static final List<Product> productDatabase = [
    // Мясо
    Product(name: 'Куриная грудка', calories: 165, proteins: 31, fats: 3.6, carbs: 0),
    Product(name: 'Говядина', calories: 250, proteins: 26, fats: 15, carbs: 0),
    Product(name: 'Свинина', calories: 242, proteins: 27, fats: 14, carbs: 0),
    Product(name: 'Индейка', calories: 189, proteins: 29, fats: 7, carbs: 0),
    Product(name: 'Лосось', calories: 208, proteins: 20, fats: 13, carbs: 0),
    Product(name: 'Тунец', calories: 132, proteins: 28, fats: 1.3, carbs: 0),
    // Молочные
    Product(name: 'Молоко 2.5%', calories: 52, proteins: 2.9, fats: 2.5, carbs: 4.8),
    Product(name: 'Творог 5%', calories: 121, proteins: 18, fats: 5, carbs: 3),
    Product(name: 'Йогурт натуральный', calories: 59, proteins: 10, fats: 0.7, carbs: 3.6),
    Product(name: 'Сыр твердый', calories: 402, proteins: 25, fats: 33, carbs: 1.3),
    Product(name: 'Кефир 1%', calories: 40, proteins: 3, fats: 1, carbs: 4),
    // Крупы
    Product(name: 'Рис белый', calories: 130, proteins: 2.7, fats: 0.3, carbs: 28),
    Product(name: 'Гречка', calories: 92, proteins: 3.4, fats: 0.6, carbs: 20),
    Product(name: 'Овсянка', calories: 68, proteins: 2.4, fats: 1.4, carbs: 12),
    Product(name: 'Макароны', calories: 131, proteins: 5, fats: 1.1, carbs: 25),
    // Овощи
    Product(name: 'Картофель', calories: 77, proteins: 2, fats: 0.1, carbs: 17),
    Product(name: 'Помидоры', calories: 18, proteins: 0.9, fats: 0.2, carbs: 3.9),
    Product(name: 'Огурцы', calories: 15, proteins: 0.65, fats: 0.1, carbs: 3.6),
    Product(name: 'Морковь', calories: 41, proteins: 0.9, fats: 0.1, carbs: 10),
    Product(name: 'Капуста', calories: 25, proteins: 1.3, fats: 0.1, carbs: 6),
    Product(name: 'Брокколи', calories: 34, proteins: 2.8, fats: 0.4, carbs: 7),
    // Фрукты
    Product(name: 'Яблоко', calories: 52, proteins: 0.3, fats: 0.2, carbs: 14),
    Product(name: 'Банан', calories: 89, proteins: 1.1, fats: 0.3, carbs: 23),
    Product(name: 'Апельсин', calories: 47, proteins: 0.9, fats: 0.1, carbs: 12),
    Product(name: 'Виноград', calories: 69, proteins: 0.7, fats: 0.2, carbs: 18),
    // Яйца и прочее
    Product(name: 'Яйцо куриное', calories: 155, proteins: 13, fats: 11, carbs: 1.1),
    Product(name: 'Хлеб белый', calories: 265, proteins: 9, fats: 3.2, carbs: 49),
    Product(name: 'Хлеб ржаной', calories: 174, proteins: 6.6, fats: 1.2, carbs: 33),
    Product(name: 'Авокадо', calories: 160, proteins: 2, fats: 15, carbs: 9),
    Product(name: 'Орехи грецкие', calories: 654, proteins: 15, fats: 65, carbs: 14),
    Product(name: 'Миндаль', calories: 579, proteins: 21, fats: 50, carbs: 22),
  ];

  NutritionProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _calorieGoal = prefs.getDouble('nutrition_calorie_goal') ?? 2200;
      _proteinGoal = prefs.getDouble('nutrition_protein_goal') ?? 160;
      _fatGoal = prefs.getDouble('nutrition_fat_goal') ?? 100;
      _carbGoal = prefs.getDouble('nutrition_carb_goal') ?? 50;

      final mealsJson = prefs.getString('nutrition_meals');
      if (mealsJson != null) {
        final decoded = jsonDecode(mealsJson) as Map<String, dynamic>;
        _meals = decoded.map((dateKey, dayMeals) {
          final dayMap = (dayMeals as Map<String, dynamic>).map((mealType, products) {
            final productList = (products as List).map((p) => Product.fromJson(p)).toList();
            return MapEntry(mealType, productList);
          });
          return MapEntry(dateKey, dayMap);
        });
      }

      final cartJson = prefs.getString('nutrition_cart');
      if (cartJson != null) {
        final decoded = jsonDecode(cartJson) as List;
        _cart = decoded.map((p) => Product.fromJson(p)).toList();
      }

      final ingredientsJson = prefs.getStringList('nutrition_ingredients');
      if (ingredientsJson != null) {
        _ingredients = ingredientsJson;
      }

      final shoppingListJson = prefs.getString('nutrition_shopping_list');
      if (shoppingListJson != null) {
        final decoded = jsonDecode(shoppingListJson) as List;
        _shoppingList = decoded.map((item) => ShoppingItem.fromJson(item)).toList();
      }

      final userProductsJson = prefs.getString('nutrition_user_products');
      if (userProductsJson != null) {
        final decoded = jsonDecode(userProductsJson) as List;
        _userProducts = decoded.map((p) => Product.fromJson(p)).toList();
      }

      final drinksJson = prefs.getString('nutrition_drinks_${_dateKey}');
      if (drinksJson != null) {
        final decoded = jsonDecode(drinksJson) as List;
        _todaysDrinks = decoded.map((d) => DrinkLog.fromJson(d)).toList();
        // Update total glasses based on logs (approximate 250ml per glass)
        _waterGlasses = (_todaysDrinks.fold(0, (sum, item) => sum + item.amountMl) / 250).round();
      } else {
        // Reset drinks if new day or no data
        _todaysDrinks = [];
        _waterGlasses = 0;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading nutrition data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setDouble('nutrition_calorie_goal', _calorieGoal);
      await prefs.setDouble('nutrition_protein_goal', _proteinGoal);
      await prefs.setDouble('nutrition_fat_goal', _fatGoal);
      await prefs.setDouble('nutrition_carb_goal', _carbGoal);

      final mealsMap = _meals.map((dateKey, dayMeals) {
        final dayMap = dayMeals.map((mealType, products) {
          return MapEntry(mealType, products.map((p) => p.toJson()).toList());
        });
        return MapEntry(dateKey, dayMap);
      });
      await prefs.setString('nutrition_meals', jsonEncode(mealsMap));

      await prefs.setString('nutrition_cart', jsonEncode(_cart.map((p) => p.toJson()).toList()));
      await prefs.setStringList('nutrition_ingredients', _ingredients);
      await prefs.setStringList('nutrition_ingredients', _ingredients);
      await prefs.setString('nutrition_shopping_list', jsonEncode(_shoppingList.map((item) => item.toJson()).toList()));
      await prefs.setString('nutrition_user_products', jsonEncode(_userProducts.map((p) => p.toJson()).toList()));
      await prefs.setString('nutrition_drinks_${_dateKey}', jsonEncode(_todaysDrinks.map((d) => d.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving nutrition data: $e');
    }
  }

  // Search products (Async with OpenFoodFacts)
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    
    // 1. Search local
    final localResults = productDatabase
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
        
    // 2. Search online (OpenFoodFacts)
    final onlineResults = await OpenFoodFactsService.searchProducts(query);

    // 3. Search user products
    final userResults = _userProducts
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    
    return [...userResults, ...localResults, ...onlineResults];
  }

  // Add product to meal
  void addToMeal(MealType type, Product product) {
    _meals.putIfAbsent(_dateKey, () => {});
    _meals[_dateKey]!.putIfAbsent(type.name, () => []);
    _meals[_dateKey]![type.name]!.add(product);
    _saveData();
    notifyListeners();
  }

  // Remove product from meal
  void removeFromMeal(MealType type, int index) {
    final dayMeals = _meals[_dateKey];
    if (dayMeals != null && dayMeals[type.name] != null) {
      dayMeals[type.name]!.removeAt(index);
      _saveData();
      notifyListeners();
    }
  }

  void removeProductFromMeal(MealType type, Product product) {
    final dayMeals = _meals[_dateKey];
    if (dayMeals != null && dayMeals[type.name] != null) {
      dayMeals[type.name]!.remove(product);
      _saveData();
      notifyListeners();
    }
  }

  // Update goals
  void setGoals({double? calories, double? proteins, double? fats, double? carbs}) {
    if (calories != null) _calorieGoal = calories;
    if (proteins != null) _proteinGoal = proteins;
    if (fats != null) _fatGoal = fats;
    if (carbs != null) _carbGoal = carbs;
    _saveData();
    notifyListeners();
  }

  // Cart operations
  void addToCart(Product product) {
    _cart.add(product);
    _saveData();
    notifyListeners();
  }

  void addSetToCart(ProductSet set) {
    _cart.addAll(set.products);
    _saveData();
    notifyListeners();
  }

  void addSetToShoppingList(ProductSet set) {
    for (var product in set.products) {
      final itemName = '${product.name} (${product.grams.toInt()}г)';
      // Check if item already exists to avoid duplicates
      final exists = _shoppingList.any((item) => item.name == itemName);
      if (!exists) {
        _shoppingList.add(ShoppingItem(name: itemName));
      }
    }
    _saveData();
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cart.removeAt(index);
    _saveData();
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _saveData();
    notifyListeners();
  }

  // Ingredients for recipe generator
  void addIngredient(String ingredient) {
    if (!_ingredients.contains(ingredient)) {
      _ingredients.add(ingredient);
      _saveData();
      notifyListeners();
    }
  }

  void removeIngredient(String ingredient) {
    _ingredients.remove(ingredient);
    _saveData();
    notifyListeners();
  }

  void clearIngredients() {
    _ingredients.clear();
    _saveData();
    notifyListeners();
  }

  // Date navigation
  void nextDay() {
    _currentDate = _currentDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void previousDay() {
    _currentDate = _currentDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void setDate(DateTime date) {
    _currentDate = date;
    _loadData(); // Reload data for the selected date
    notifyListeners();
  }

  String get formattedDate {
    const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    final now = DateTime.now();
    if (_currentDate.year == now.year && _currentDate.month == now.month && _currentDate.day == now.day) {
      return 'Сегодня';
    }
    return '${weekdays[_currentDate.weekday - 1]}, ${_currentDate.day} ${months[_currentDate.month - 1]}';
  }

  // Shopping list methods
  // Water Tracking
  int _waterGlasses = 0;
  final int _waterGoal = 8;
  int get waterGlasses => _waterGlasses;
  int get waterGoal => _waterGoal;
  
  // 1 glass = 250ml
  // 1 glass = 250ml
  int get waterMl => _todaysDrinks.fold(0, (sum, item) => sum + item.amountMl);
  int get waterGoalMl => _waterGoal * 250;

  void addDrink(DrinkType type, int amountMl) {
    _todaysDrinks.add(DrinkLog(type: type, time: DateTime.now(), amountMl: amountMl));
    _waterGlasses = (waterMl / 250).round();
    _saveData();
    notifyListeners();
    _checkWaterGoal();
  }

  void removeLastDrink() {
    if (_todaysDrinks.isNotEmpty) {
      _todaysDrinks.removeLast();
      _waterGlasses = (waterMl / 250).round();
      _saveData();
      notifyListeners();
    }
  }

  // Deprecated: keeping for compatibility if used elsewhere, but redirecting logic
  void addWater() => addDrink(DrinkType.water, 250);
  void removeWater() => removeLastDrink();
  
  // Reminders
  void _checkWaterGoal() {
    if (_waterGlasses >= _waterGoal) {
      // Cancel reminders for today if goal reached
      // In a real app we'd manage a specific timer or notification ID
    }
  }
  
  Future<void> scheduleWaterReminders() async {
     // Simple logic: Schedule notification every 3 hours from 9 AM to 9 PM
     // For this request: "in the course of the day reminders... reminders about drinking water and how much left"
     
     final service = NotificationService(); // Using the singleton
     // We define a set of reminder hours
     final hours = [10, 13, 16, 19, 21];
     final now = DateTime.now();
     
     for (var h in hours) {
       var scheduledDate = DateTime(now.year, now.month, now.day, h, 0);
       if (scheduledDate.isBefore(now)) {
         scheduledDate = scheduledDate.add(const Duration(days: 1));
       }
       
       // Unique ID based on hour
       await service.scheduleNotification(
         id: 1000 + h, 
         title: 'Время пить воду! 💧',
         body: 'Не забудьте выпить стакан воды. Ваша цель близка!',
         scheduledDate: scheduledDate,
       );
     }
  }

  void addToShoppingList(String itemName) {
    _shoppingList.add(ShoppingItem(name: itemName));
    _saveData();
    notifyListeners();
  }

  void removeFromShoppingList(int index) {
    if (index >= 0 && index < _shoppingList.length) {
      _shoppingList.removeAt(index);
      _saveData();
      notifyListeners();
    }
  }

  void toggleShoppingItem(int index) {
    if (index >= 0 && index < _shoppingList.length) {
      _shoppingList[index].isChecked = !_shoppingList[index].isChecked;
      _saveData();
      notifyListeners();
    }
  }

  void clearShoppingList() {
    _shoppingList.clear();
    _saveData();
    notifyListeners();
  }
  
  // Fridge Methods
  void addToFridge(String item) {
    _fridgeInventory.add(item);
    notifyListeners();
  }
  
  void removeFromFridge(String item) {
    _fridgeInventory.remove(item);
    notifyListeners();
  }
  
  Future<void> searchRecipesByFridge() async {
    if (_fridgeInventory.isEmpty) {
      _foundRecipes = [];
      notifyListeners();
      return;
    }

    _isSearchingRecipes = true;
    notifyListeners();

    try {
      // Fetch external API only
      final apiMatches = await _recipeService.findRecipesByIngredients(_fridgeInventory);
      
      _foundRecipes = [...apiMatches];
      
    } catch (e) {
      debugPrint('Error searching recipes: $e');
    } finally {
      _isSearchingRecipes = false;
      notifyListeners();
    }
  }

  // Save user product
  void saveUserProduct(Product product) {
    _userProducts.add(product);
    _saveData();
    notifyListeners();
  }

  // Legacy local suggestion (optional, keeping for backward compat if needed)
  ProductSet? suggestRecipeLegacy() {
    // Simple logic: Find a product set where we have at least 1 ingredient in fridge
    for (var set in _productSets) {
      for (var product in set.products) {
        if (_fridgeInventory.contains(product.name)) {
          return set;
        }
      }
    }
    return null;
  }
  // Save shopping list as a Product Set (Basket)
  void saveShoppingListToSet(String name) {
    if (_shoppingList.isEmpty) return;
    
    List<Product> products = [];
    for (var item in _shoppingList) {
      // Try to find in DB to get calories, otherwise dummy
      var found = productDatabase.firstWhere(
        (p) => p.name.toLowerCase() == item.name.toLowerCase(), 
        orElse: () => Product(name: item.name, calories: 0, proteins: 0, fats: 0, carbs: 0, grams: 1)
      );
      
       products.add(Product(
         name: found.name, 
         calories: found.calories,
         proteins: found.proteins,
         fats: found.fats,
         carbs: found.carbs,
         grams: found.grams 
       ));
    }
    
    _productSets.add(ProductSet(
      name: name,
      description: '${products.length} продуктов',
      imagePath: 'assets/images/tip_general.png', 
      products: products
    ));
    // Optionally clear list after save? User didn't specify. Let's keep it for now or clear.
    // Usually "Save" implies storing it. I'll clear it to signify "Moved to Basket".
    _shoppingList.clear();
    
    _saveData();
    notifyListeners();
  }
}
