class IngredientDictionary {
  static const Map<String, String> map = {
    // Основные
    'курица': 'chicken',
    'куриное филе': 'chicken_breast',
    'куриная грудка': 'chicken_breast',
    'говядина': 'beef',
    'свинина': 'pork',
    'рыба': 'fish',
    'лосось': 'salmon',
    'тунец': 'tuna',
    'креветки': 'shrimp',
    'яйцо': 'egg',
    'яйца': 'eggs',
    'бекон': 'bacon',
    'ветчина': 'ham',
    'фарш': 'minced_meat',
    'колбаса': 'sausage',
    'индейка': 'turkey',
    
    // Овощи
    'помидор': 'tomato',
    'томат': 'tomato',
    'огурец': 'cucumber',
    'картофель': 'potato',
    'картошка': 'potato',
    'лук': 'onion',
    'чеснок': 'garlic',
    'морковь': 'carrot',
    'капуста': 'cabbage',
    'брокколи': 'broccoli',
    'перец': 'pepper',
    'баклажан': 'eggplant',
    'кабачок': 'zucchini',
    'грибы': 'mushroom',
    'шампиньоны': 'mushroom',
    'кукуруза': 'corn',
    'горошек': 'peas',
    'авокадо': 'avocado',
    'шпинат': 'spinach',
    'зелень': 'herbs',
    'салат': 'lettuce',
    
    // Фрукты
    'яблоко': 'apple',
    'банан': 'banana',
    'лимон': 'lemon',
    'апельсин': 'orange',
    'лайм': 'lime',
    'ягоды': 'berries',
    'клубника': 'strawberry',
    
    // Молочка
    'молоко': 'milk',
    'сыр': 'cheese',
    'масло': 'butter',
    'сметана': 'sour_cream',
    'творог': 'cottage_cheese',
    'сливки': 'cream',
    'йогурт': 'yogurt',
    'кефир': 'kefir',
    'пармезан': 'parmesan',
    'моцарелла': 'mozzarella',
    
    // Крупы и мучное
    'рис': 'rice',
    'макароны': 'pasta',
    'паста': 'pasta',
    'спагетти': 'spaghetti',
    'гречка': 'buckwheat',
    'овсянка': 'oats',
    'геркулес': 'oats',
    'хлеб': 'bread',
    'мука': 'flour',
    'тесто': 'dough',
    
    // Специи и прочее
    'сахар': 'sugar',
    'соль': 'salt',
    'перец черный': 'black_pepper',
    'мед': 'honey',
    'мёд': 'honey',
    'орехи': 'nuts',
    'шоколад': 'chocolate',
    'какао': 'cocoa',
    'вода': 'water',
    'лед': 'ice',
    'лёд': 'ice',
    'масло оливковое': 'olive_oil',
    'масло подсолнечное': 'vegetable_oil',
    'соевый соус': 'soy_sauce',
    'майонез': 'mayonnaise',
    'кетчуп': 'ketchup',
  };

  static String? translate(String input) {
    final normalized = input.toLowerCase().trim();
    // 1. Direct match
    if (map.containsKey(normalized)) return map[normalized];
    
    // 2. Contains match (e.g. "fresh tomato" -> "tomato")
    // Use longest key match to avoid partials (e.g. "pineapple" matching "apple")
    final sortedKeys = map.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    
    for (final key in sortedKeys) {
      if (normalized.contains(key)) {
        return map[key];
      }
    }
    
    // 3. Check if already English (basic check)
    if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(normalized)) {
      return normalized;
    }
    
    return null;
  }
}
