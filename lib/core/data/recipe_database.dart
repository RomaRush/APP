/// Extended recipe database with 30+ recipes
class RecipeDatabase {
  static final List<RecipeData> recipes = [
    // === ЗАВТРАКИ ===
    RecipeData(
      name: 'Овсянка с фруктами и мёдом',
      category: 'breakfast',
      ingredients: ['Овсянка — 80г', 'Молоко — 200мл', 'Банан — 100г', 'Мёд — 15г', 'Орехи — 20г'],
      steps: ['Залейте овсянку молоком', 'Варите 5 минут', 'Добавьте нарезанный банан', 'Полейте мёдом и посыпьте орехами'],
      calories: 420, proteins: 12, fats: 14, carbs: 62, cookTime: 10,
      videoThumbnail: 'assets/images/recipes/oatmeal_cover.png',
      videoUrl: 'assets/images/recipes/oatmeal_cooking.mp4', 
    ),
    RecipeData(
      name: 'Омлет с овощами',
      category: 'breakfast',
      ingredients: ['Яйца — 3 шт (150г)', 'Молоко — 50мл', 'Помидоры — 80г', 'Перец — 50г', 'Сыр — 30г'],
      steps: ['Взбейте яйца с молоком', 'Нарежьте овощи', 'Обжарьте овощи 2 мин', 'Залейте яйцами, готовьте 5 мин', 'Посыпьте сыром'],
      calories: 380, proteins: 28, fats: 26, carbs: 8, cookTime: 12,
      videoThumbnail: 'assets/images/recipes/omelet_cover.png',
      videoUrl: 'assets/images/recipes/omelet_cooking.mp4',
    ),
    RecipeData(
      name: 'Творожная запеканка',
      category: 'breakfast',
      ingredients: ['Творог 5% — 400г', 'Яйца — 2 шт', 'Сахар — 50г', 'Манка — 40г', 'Изюм — 30г'],
      steps: ['Смешайте творог с яйцами и сахаром', 'Добавьте манку, дайте постоять 15 мин', 'Добавьте изюм', 'Запекайте 35 мин при 180°'],
      calories: 280, proteins: 18, fats: 10, carbs: 30, cookTime: 50,
      videoThumbnail: 'assets/images/recipes/casserole_cover.png',
      videoUrl: 'assets/images/recipes/casserole_cooking.mp4',
    ),
    RecipeData(
      name: 'Сырники со сметаной',
      category: 'breakfast',
      ingredients: ['Творог — 300г', 'Яйцо — 1 шт', 'Мука — 40г', 'Сахар — 30г', 'Сметана — 50г'],
      steps: ['Смешайте творог с яйцом и сахаром', 'Добавьте муку', 'Сформируйте сырники', 'Обжарьте с двух сторон', 'Подавайте со сметаной'],
      calories: 340, proteins: 16, fats: 12, carbs: 28, cookTime: 25,
      videoThumbnail: 'assets/images/recipes/syrniki_cover.png',
      videoUrl: 'assets/images/recipes/syrniki_cooking.mp4',
    ),
    
    // === МЯСНЫЕ БЛЮДА ===
    RecipeData(
      name: 'Куриная грудка с овощами',
      category: 'meat',
      ingredients: ['Куриная грудка — 300г', 'Брокколи — 150г', 'Морковь — 100г', 'Соевый соус — 30мл', 'Чеснок — 10г'],
      steps: ['Нарежьте курицу кубиками', 'Обжарьте курицу 5 мин', 'Добавьте овощи', 'Влейте соевый соус', 'Тушите 10 мин'],
      calories: 320, proteins: 45, fats: 8, carbs: 15, cookTime: 20,
      videoThumbnail: 'assets/images/recipes/chicken_breast_cover.png',
    ),
    RecipeData(
      name: 'Котлеты домашние',
      category: 'meat',
      ingredients: ['Фарш говяжий — 400г', 'Лук — 100г', 'Хлеб — 50г', 'Яйцо — 1 шт', 'Молоко — 50мл'],
      steps: ['Замочите хлеб в молоке', 'Смешайте фарш с луком и яйцом', 'Добавьте хлеб и специи', 'Сформируйте котлеты', 'Обжарьте 7 мин с каждой стороны'],
      calories: 280, proteins: 22, fats: 18, carbs: 8, cookTime: 25,
      videoThumbnail: 'assets/images/recipes/cutlets_cover.png',
    ),
    RecipeData(
      name: 'Стейк из говядины',
      category: 'meat',
      ingredients: ['Говядина (стейк) — 250г', 'Оливковое масло — 15мл', 'Розмарин — 5г', 'Чеснок — 10г', 'Соль, перец'],
      steps: ['Достаньте мясо за час до готовки', 'Натрите специями', 'Разогрейте сковороду', 'Обжарьте 3-4 мин с каждой стороны', 'Дайте отдохнуть 5 мин'],
      calories: 420, proteins: 52, fats: 24, carbs: 0, cookTime: 15,
      videoThumbnail: 'assets/images/recipes/beef_steak_cover.png',
    ),
    RecipeData(
      name: 'Куриные крылышки BBQ',
      category: 'meat',
      ingredients: ['Крылышки — 500г', 'Соус BBQ — 100г', 'Мёд — 30г', 'Чеснок — 15г', 'Соевый соус — 30мл'],
      steps: ['Смешайте соус с мёдом и чесноком', 'Замаринуйте крылышки на 2 часа', 'Запекайте 40 мин при 200°', 'Переверните в середине готовки'],
      calories: 310, proteins: 28, fats: 18, carbs: 12, cookTime: 45,
      videoThumbnail: 'assets/images/recipes/bbq_wings_cover.png',
    ),
    RecipeData(
      name: 'Шашлык из свинины',
      category: 'meat',
      ingredients: ['Свинина (шея) — 500г', 'Лук — 200г', 'Лимон — 50г', 'Специи для шашлыка — 10г'],
      steps: ['Нарежьте мясо кубиками 4см', 'Добавьте лук кольцами', 'Полейте лимонным соком', 'Маринуйте 4-6 часов', 'Жарьте на углях 15-20 мин'],
      calories: 350, proteins: 26, fats: 26, carbs: 3, cookTime: 25,
      videoThumbnail: 'assets/images/recipes/pork_kebab_cover.png',
    ),
    
    // === САЛАТЫ ===
    RecipeData(
      name: 'Греческий салат',
      category: 'salad',
      ingredients: ['Огурцы — 150г', 'Помидоры — 150г', 'Перец — 100г', 'Фета — 100г', 'Оливки — 50г', 'Оливковое масло — 30мл'],
      steps: ['Нарежьте овощи кубиками', 'Добавьте оливки', 'Выложите кубики феты', 'Заправьте маслом', 'Посолите и поперчите'],
      calories: 320, proteins: 12, fats: 26, carbs: 12, cookTime: 10,
      videoThumbnail: 'assets/images/recipes/greek_salad_cover.png',
    ),
    RecipeData(
      name: 'Цезарь с курицей',
      category: 'salad',
      ingredients: ['Куриная грудка — 200г', 'Салат романо — 150г', 'Пармезан — 50г', 'Сухарики — 50г', 'Соус Цезарь — 50г'],
      steps: ['Обжарьте курицу, нарежьте', 'Порвите листья салата', 'Добавьте сухарики', 'Заправьте соусом', 'Посыпьте пармезаном'],
      calories: 420, proteins: 38, fats: 24, carbs: 15, cookTime: 20,
      videoThumbnail: 'assets/images/recipes/caesar_salad_cover.png',
    ),
    RecipeData(
      name: 'Оливье',
      category: 'salad',
      ingredients: ['Картофель — 200г', 'Морковь — 100г', 'Яйца — 3 шт', 'Колбаса — 150г', 'Горошек — 100г', 'Майонез — 100г'],
      steps: ['Отварите овощи и яйца', 'Нарежьте всё кубиками', 'Добавьте горошек', 'Заправьте майонезом', 'Перемешайте'],
      calories: 280, proteins: 10, fats: 20, carbs: 16, cookTime: 40,
      videoThumbnail: 'assets/images/recipes/olivier_salad_cover.png',
    ),
    RecipeData(
      name: 'Винегрет',
      category: 'salad',
      ingredients: ['Свекла — 150г', 'Картофель — 150г', 'Морковь — 100г', 'Огурцы соленые — 100г', 'Горошек — 80г', 'Масло — 30мл'],
      steps: ['Отварите овощи', 'Нарежьте кубиками', 'Добавьте горошек', 'Заправьте маслом', 'Перемешайте'],
      calories: 130, proteins: 3, fats: 5, carbs: 18, cookTime: 50,
    ),
    
    // === СУПЫ ===
    RecipeData(
      name: 'Борщ',
      category: 'soup',
      ingredients: ['Говядина — 300г', 'Свекла — 200г', 'Капуста — 200г', 'Картофель — 200г', 'Морковь — 100г', 'Лук — 100г', 'Томатная паста — 30г'],
      steps: ['Сварите бульон 1.5 часа', 'Добавьте картофель', 'Обжарьте свеклу и морковь', 'Добавьте зажарку и капусту', 'Варите 15 мин', 'Подавайте со сметаной'],
      calories: 85, proteins: 5, fats: 3, carbs: 10, cookTime: 120,
    ),
    RecipeData(
      name: 'Куриный суп с лапшой',
      category: 'soup',
      ingredients: ['Курица — 400г', 'Лапша — 100г', 'Морковь — 100г', 'Лук — 80г', 'Зелень — 20г'],
      steps: ['Сварите бульон 40 мин', 'Достаньте курицу, нарежьте', 'Добавьте морковь и лук', 'За 7 мин до готовности добавьте лапшу', 'Верните курицу, добавьте зелень'],
      calories: 75, proteins: 8, fats: 2.5, carbs: 6, cookTime: 50,
    ),
    RecipeData(
      name: 'Грибной крем-суп',
      category: 'soup',
      ingredients: ['Шампиньоны — 400г', 'Картофель — 200г', 'Сливки 20% — 200мл', 'Лук — 100г', 'Чеснок — 10г'],
      steps: ['Обжарьте лук и грибы', 'Добавьте картофель и воду', 'Варите 20 мин', 'Измельчите блендером', 'Добавьте сливки, прогрейте'],
      calories: 95, proteins: 4, fats: 6, carbs: 8, cookTime: 35,
    ),
    RecipeData(
      name: 'Солянка мясная',
      category: 'soup',
      ingredients: ['Говядина — 200г', 'Колбаса — 100г', 'Огурцы соленые — 100г', 'Лук — 100г', 'Оливки — 50г', 'Томатная паста — 40г'],
      steps: ['Сварите мясной бульон', 'Нарежьте мясо и колбасу', 'Обжарьте лук с огурцами', 'Добавьте всё в бульон', 'Добавьте оливки и лимон'],
      calories: 120, proteins: 10, fats: 7, carbs: 5, cookTime: 90,
    ),
    
    // === ГАРНИРЫ ===
    RecipeData(
      name: 'Картофельное пюре',
      category: 'garnish',
      ingredients: ['Картофель — 500г', 'Молоко — 150мл', 'Масло сливочное — 50г', 'Соль — по вкусу'],
      steps: ['Отварите картофель 25 мин', 'Слейте воду', 'Добавьте горячее молоко и масло', 'Разомните до пышности'],
      calories: 130, proteins: 2.5, fats: 5, carbs: 18, cookTime: 30,
    ),
    RecipeData(
      name: 'Рис с овощами',
      category: 'garnish',
      ingredients: ['Рис — 200г', 'Морковь — 100г', 'Горошек — 80г', 'Кукуруза — 80г', 'Соевый соус — 20мл'],
      steps: ['Отварите рис', 'Обжарьте морковь', 'Добавьте рис и овощи', 'Полейте соевым соусом', 'Прогрейте 3 мин'],
      calories: 145, proteins: 4, fats: 1.5, carbs: 30, cookTime: 25,
    ),
    RecipeData(
      name: 'Гречка рассыпчатая',
      category: 'garnish',
      ingredients: ['Гречка — 200г', 'Вода — 400мл', 'Масло сливочное — 30г', 'Соль — по вкусу'],
      steps: ['Промойте гречку', 'Залейте кипятком', 'Варите 15 мин', 'Добавьте масло', 'Дайте постоять 10 мин'],
      calories: 110, proteins: 4, fats: 3, carbs: 20, cookTime: 25,
    ),
    
    // === РЫБА ===
    RecipeData(
      name: 'Запечённый лосось',
      category: 'fish',
      ingredients: ['Лосось (филе) — 300г', 'Лимон — 50г', 'Чеснок — 10г', 'Укроп — 15г', 'Оливковое масло — 20мл'],
      steps: ['Натрите рыбу чесноком', 'Полейте лимоном и маслом', 'Посыпьте укропом', 'Запекайте 20 мин при 180°'],
      calories: 280, proteins: 32, fats: 16, carbs: 2, cookTime: 25,
    ),
    RecipeData(
      name: 'Рыбные котлеты',
      category: 'fish',
      ingredients: ['Минтай — 500г', 'Лук — 100г', 'Хлеб — 80г', 'Яйцо — 1 шт', 'Молоко — 100мл'],
      steps: ['Пропустите рыбу через мясорубку', 'Замочите хлеб в молоке', 'Смешайте с луком и яйцом', 'Сформируйте котлеты', 'Обжарьте по 5 мин с каждой стороны'],
      calories: 150, proteins: 18, fats: 5, carbs: 8, cookTime: 30,
    ),
    RecipeData(
      name: 'Креветки в чесночном соусе',
      category: 'fish',
      ingredients: ['Креветки — 300г', 'Чеснок — 20г', 'Сливочное масло — 50г', 'Белое вино — 50мл', 'Петрушка — 15г'],
      steps: ['Очистите креветки', 'Растопите масло с чесноком', 'Добавьте креветки', 'Влейте вино', 'Готовьте 5 мин, посыпьте зеленью'],
      calories: 220, proteins: 25, fats: 12, carbs: 3, cookTime: 15,
    ),
    
    // === ДЕСЕРТЫ ===
    RecipeData(
      name: 'Панкейки',
      category: 'dessert',
      ingredients: ['Мука — 150г', 'Молоко — 200мл', 'Яйцо — 2 шт', 'Сахар — 30г', 'Разрыхлитель — 5г'],
      steps: ['Смешайте сухие ингредиенты', 'Добавьте яйца и молоко', 'Взбейте до однородности', 'Жарьте на среднем огне', 'Подавайте с мёдом или ягодами'],
      videoThumbnail: 'assets/images/recipes/pancakes_thumb.png',
      // videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', // Example URL
      stepImages: [
        'assets/images/recipes/pancakes_step_1.png', 
        'assets/images/recipes/pancakes_step_1.png', // Reusing for step 2 (add eggs) as generic mixing
        'assets/images/recipes/pancakes_step_1.png', // Reusing for mixing
        'assets/images/recipes/pancakes_step_2.png', // Cooking
        'assets/images/recipes/pancakes_step_3.png'  // Serving
      ],
      calories: 220, proteins: 7, fats: 6, carbs: 35, cookTime: 20,
    ),
    RecipeData(
      name: 'Чизкейк без выпечки',
      category: 'dessert',
      ingredients: ['Творожный сыр — 400г', 'Сливки 33% — 200мл', 'Печенье — 200г', 'Масло — 100г', 'Сахар — 100г'],
      steps: ['Измельчите печенье с маслом', 'Выложите на дно формы', 'Взбейте сыр со сливками и сахаром', 'Выложите на основу', 'Охлаждайте 4 часа'],
      calories: 380, proteins: 8, fats: 28, carbs: 26, cookTime: 30,
    ),
    RecipeData(
      name: 'Шоколадный мусс',
      category: 'dessert',
      ingredients: ['Шоколад темный — 200г', 'Сливки 33% — 300мл', 'Яйца — 2 шт', 'Сахар — 50г'],
      steps: ['Растопите шоколад', 'Взбейте сливки', 'Взбейте белки с сахаром', 'Соедините всё аккуратно', 'Охлаждайте 2 часа'],
      calories: 350, proteins: 6, fats: 25, carbs: 28, cookTime: 20,
    ),
    
    // === ЗАКУСКИ ===
    RecipeData(
      name: 'Брускетта с томатами',
      category: 'snack',
      ingredients: ['Багет — 200г', 'Помидоры — 200г', 'Базилик — 20г', 'Чеснок — 10г', 'Оливковое масло — 30мл'],
      steps: ['Нарежьте багет', 'Подсушите в духовке', 'Натрите чесноком', 'Выложите нарезанные томаты', 'Полейте маслом, добавьте базилик'],
      calories: 180, proteins: 5, fats: 8, carbs: 22, cookTime: 15,
    ),
    RecipeData(
      name: 'Фаршированные яйца',
      category: 'snack',
      ingredients: ['Яйца — 6 шт', 'Майонез — 50г', 'Горчица — 10г', 'Зелень — 15г'],
      steps: ['Сварите яйца вкрутую', 'Разрежьте пополам', 'Выньте желтки', 'Смешайте желтки с майонезом и горчицей', 'Наполните белки начинкой'],
      calories: 150, proteins: 10, fats: 12, carbs: 1, cookTime: 20,
    ),
  ];
  
  static List<RecipeData> getByCategory(String category) {
    return recipes.where((r) => r.category == category).toList();
  }
  
  static List<RecipeData> search(String query) {
    final lower = query.toLowerCase();
    return recipes.where((r) => 
      r.name.toLowerCase().contains(lower) ||
      r.ingredients.any((i) => i.toLowerCase().contains(lower))
    ).toList();
  }
  
  static RecipeData? findByIngredients(List<String> userIngredients) {
    if (userIngredients.isEmpty) return null;
    
    final lowerIngredients = userIngredients.map((i) => i.toLowerCase()).toList();
    RecipeData? best;
    int bestScore = 0;
    
    for (final recipe in recipes) {
      int score = 0;
      for (final recipeIng in recipe.ingredients) {
        final lower = recipeIng.toLowerCase();
        for (final userIng in lowerIngredients) {
          if (lower.contains(userIng) || userIng.contains(lower.split(' — ')[0])) {
            score++;
            break;
          }
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = recipe;
      }
    }
    
    if (best != null) return best;

    // Fallback: Generate "Creative" recipe
    final title = userIngredients.take(3).map((s) => s.trim()).join(' + ');
    return RecipeData(
      name: 'Шеф-микс: $title',
      category: 'custom',
      ingredients: userIngredients,
      steps: [
        'Подготовьте все ингредиенты: ${userIngredients.join(", ")}.',
        'Нарежьте овощи и мясо (если есть) небольшими кусочками.',
        'Разогрейте сковороду с маслом.',
        'Обжарьте основные ингредиенты до золотистой корочки.',
        'Добавьте специи по вкусу и тушите до готовности.',
        'Подавайте горячим. Приятного аппетита!'
      ],
      calories: 350, // Approximation
      proteins: 15,
      fats: 15,
      carbs: 30,
      cookTime: 20,
    );
  }
}

class RecipeData {
  final String name;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  final String? videoUrl;
  final String? videoThumbnail;
  final List<String> stepImages; // Must match steps length or be empty
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final int cookTime;
  
  const RecipeData({
    required this.name,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.videoUrl,
    this.videoThumbnail,
    this.stepImages = const [],
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.cookTime,
  });
}
