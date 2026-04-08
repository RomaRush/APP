/// Extended product database with 100+ real products
/// All nutritional values are per 100g
class ProductDatabase {
  static final List<ProductData> products = [
    // === МЯСО И ПТИЦА ===
    ProductData('Куриная грудка', 165, 31, 3.6, 0, 'meat'),
    ProductData('Куриное бедро', 211, 21, 13, 0, 'meat'),
    ProductData('Говядина (вырезка)', 218, 26, 12, 0, 'meat'),
    ProductData('Говяжий фарш', 254, 17, 20, 0, 'meat'),
    ProductData('Свинина постная', 242, 27, 14, 0, 'meat'),
    ProductData('Свиная шейка', 343, 15, 31, 0, 'meat'),
    ProductData('Индейка грудка', 157, 30, 3, 0, 'meat'),
    ProductData('Индейка бедро', 187, 20, 11, 0, 'meat'),
    ProductData('Баранина', 294, 24, 21, 0, 'meat'),
    ProductData('Утка', 337, 19, 28, 0, 'meat'),
    ProductData('Кролик', 156, 21, 8, 0, 'meat'),
    ProductData('Печень говяжья', 127, 20, 3.7, 4, 'meat'),
    ProductData('Сосиски', 277, 11, 24, 2, 'meat'),
    ProductData('Колбаса докторская', 257, 12, 22, 2, 'meat'),
    ProductData('Бекон', 541, 37, 42, 1, 'meat'),
    
    // === РЫБА И МОРЕПРОДУКТЫ ===
    ProductData('Лосось', 208, 20, 13, 0, 'fish'),
    ProductData('Семга', 219, 21, 15, 0, 'fish'),
    ProductData('Тунец', 132, 28, 1.3, 0, 'fish'),
    ProductData('Треска', 82, 18, 0.7, 0, 'fish'),
    ProductData('Минтай', 72, 16, 0.9, 0, 'fish'),
    ProductData('Скумбрия', 262, 18, 21, 0, 'fish'),
    ProductData('Сельдь', 217, 19, 15, 0, 'fish'),
    ProductData('Форель', 141, 20, 6.6, 0, 'fish'),
    ProductData('Креветки', 99, 21, 1.7, 0, 'fish'),
    ProductData('Кальмар', 92, 18, 1.4, 2, 'fish'),
    ProductData('Мидии', 86, 12, 2, 4, 'fish'),
    ProductData('Краб', 97, 19, 1.5, 0, 'fish'),
    ProductData('Икра красная', 252, 32, 15, 0, 'fish'),
    
    // === МОЛОЧНЫЕ ПРОДУКТЫ ===
    ProductData('Молоко 2.5%', 52, 2.9, 2.5, 4.8, 'dairy'),
    ProductData('Молоко 3.2%', 60, 2.9, 3.2, 4.7, 'dairy'),
    ProductData('Молоко обезжиренное', 34, 3.4, 0.1, 5, 'dairy'),
    ProductData('Творог 0%', 71, 18, 0.1, 3.3, 'dairy'),
    ProductData('Творог 5%', 121, 18, 5, 3, 'dairy'),
    ProductData('Творог 9%', 159, 16, 9, 3, 'dairy'),
    ProductData('Сметана 15%', 162, 2.6, 15, 3, 'dairy'),
    ProductData('Сметана 20%', 206, 2.5, 20, 3.4, 'dairy'),
    ProductData('Кефир 1%', 40, 3, 1, 4, 'dairy'),
    ProductData('Кефир 2.5%', 51, 2.9, 2.5, 4, 'dairy'),
    ProductData('Йогурт натуральный', 59, 10, 0.7, 3.6, 'dairy'),
    ProductData('Йогурт греческий', 97, 9, 5, 3.1, 'dairy'),
    ProductData('Сыр Российский', 363, 23, 29, 0, 'dairy'),
    ProductData('Сыр Маасдам', 350, 26, 27, 0, 'dairy'),
    ProductData('Сыр Моцарелла', 280, 22, 22, 0, 'dairy'),
    ProductData('Сыр Пармезан', 392, 36, 26, 3, 'dairy'),
    ProductData('Сыр Бри', 334, 21, 28, 0.5, 'dairy'),
    ProductData('Сыр Фета', 264, 14, 21, 4, 'dairy'),
    ProductData('Масло сливочное', 748, 0.5, 82, 0.8, 'dairy'),
    
    // === ЯЙЦА ===
    ProductData('Яйцо куриное', 155, 13, 11, 1.1, 'eggs'),
    ProductData('Яйцо перепелиное', 168, 12, 13, 0.6, 'eggs'),
    ProductData('Белок яичный', 48, 11, 0, 0.7, 'eggs'),
    ProductData('Желток яичный', 352, 16, 31, 1, 'eggs'),
    
    // === КРУПЫ И ЗЛАКИ ===
    ProductData('Рис белый', 130, 2.7, 0.3, 28, 'grains'),
    ProductData('Рис бурый', 111, 2.6, 0.9, 23, 'grains'),
    ProductData('Гречка', 92, 3.4, 0.6, 20, 'grains'),
    ProductData('Овсянка', 68, 2.4, 1.4, 12, 'grains'),
    ProductData('Перловка', 109, 3.1, 0.4, 22, 'grains'),
    ProductData('Пшено', 90, 3, 0.7, 17, 'grains'),
    ProductData('Кускус', 112, 3.8, 0.2, 23, 'grains'),
    ProductData('Булгур', 83, 3.1, 0.2, 18, 'grains'),
    ProductData('Киноа', 120, 4.4, 1.9, 21, 'grains'),
    ProductData('Макароны', 131, 5, 1.1, 25, 'grains'),
    ProductData('Спагетти', 131, 5.5, 1.1, 26, 'grains'),
    
    // === ХЛЕБ И ВЫПЕЧКА ===
    ProductData('Хлеб белый', 265, 9, 3.2, 49, 'bread'),
    ProductData('Хлеб ржаной', 174, 6.6, 1.2, 33, 'bread'),
    ProductData('Хлеб цельнозерновой', 247, 13, 3.4, 41, 'bread'),
    ProductData('Батон', 262, 7.5, 2.9, 51, 'bread'),
    ProductData('Лаваш', 275, 9.1, 1.2, 56, 'bread'),
    ProductData('Лепешка', 326, 8, 6.1, 60, 'bread'),
    ProductData('Круассан', 406, 8.2, 21, 46, 'bread'),
    
    // === ОВОЩИ ===
    ProductData('Картофель', 77, 2, 0.1, 17, 'vegetables'),
    ProductData('Помидоры', 18, 0.9, 0.2, 3.9, 'vegetables'),
    ProductData('Огурцы', 15, 0.65, 0.1, 3.6, 'vegetables'),
    ProductData('Морковь', 41, 0.9, 0.1, 10, 'vegetables'),
    ProductData('Капуста белокочанная', 25, 1.3, 0.1, 6, 'vegetables'),
    ProductData('Капуста цветная', 30, 2.5, 0.3, 5, 'vegetables'),
    ProductData('Брокколи', 34, 2.8, 0.4, 7, 'vegetables'),
    ProductData('Кабачок', 24, 0.6, 0.3, 4.6, 'vegetables'),
    ProductData('Баклажан', 25, 1.2, 0.1, 5.7, 'vegetables'),
    ProductData('Перец болгарский', 27, 1.3, 0.1, 5.3, 'vegetables'),
    ProductData('Лук репчатый', 40, 1.1, 0.1, 9, 'vegetables'),
    ProductData('Чеснок', 149, 6.5, 0.5, 30, 'vegetables'),
    ProductData('Свекла', 43, 1.6, 0.1, 9, 'vegetables'),
    ProductData('Редиска', 19, 1.2, 0.1, 3.4, 'vegetables'),
    ProductData('Шпинат', 23, 2.9, 0.4, 3.6, 'vegetables'),
    ProductData('Салат айсберг', 14, 0.9, 0.1, 2, 'vegetables'),
    ProductData('Руккола', 25, 2.6, 0.7, 3.7, 'vegetables'),
    ProductData('Сельдерей', 13, 0.9, 0.1, 2.1, 'vegetables'),
    ProductData('Горошек зеленый', 73, 5.4, 0.4, 12, 'vegetables'),
    ProductData('Кукуруза', 86, 3.3, 1.2, 19, 'vegetables'),
    ProductData('Фасоль стручковая', 31, 1.8, 0.1, 7, 'vegetables'),
    ProductData('Грибы шампиньоны', 22, 4.3, 0.1, 0.1, 'vegetables'),
    ProductData('Грибы вешенки', 43, 3.3, 0.4, 6.1, 'vegetables'),
    
    // === ФРУКТЫ ===
    ProductData('Яблоко', 52, 0.3, 0.2, 14, 'fruits'),
    ProductData('Банан', 89, 1.1, 0.3, 23, 'fruits'),
    ProductData('Апельсин', 47, 0.9, 0.1, 12, 'fruits'),
    ProductData('Мандарин', 53, 0.8, 0.2, 12, 'fruits'),
    ProductData('Грейпфрут', 42, 0.8, 0.1, 11, 'fruits'),
    ProductData('Лимон', 29, 1.1, 0.3, 9, 'fruits'),
    ProductData('Виноград', 69, 0.7, 0.2, 18, 'fruits'),
    ProductData('Груша', 42, 0.4, 0.1, 11, 'fruits'),
    ProductData('Персик', 39, 0.9, 0.1, 10, 'fruits'),
    ProductData('Абрикос', 48, 0.9, 0.1, 11, 'fruits'),
    ProductData('Слива', 49, 0.8, 0.3, 12, 'fruits'),
    ProductData('Киви', 61, 1.1, 0.5, 15, 'fruits'),
    ProductData('Манго', 60, 0.8, 0.4, 15, 'fruits'),
    ProductData('Ананас', 50, 0.5, 0.1, 13, 'fruits'),
    ProductData('Арбуз', 27, 0.6, 0.1, 6, 'fruits'),
    ProductData('Дыня', 35, 0.6, 0.3, 8, 'fruits'),
    ProductData('Клубника', 33, 0.8, 0.4, 8, 'fruits'),
    ProductData('Малина', 46, 0.8, 0.5, 12, 'fruits'),
    ProductData('Черника', 44, 0.7, 0.3, 11, 'fruits'),
    ProductData('Вишня', 50, 0.8, 0.2, 12, 'fruits'),
    ProductData('Авокадо', 160, 2, 15, 9, 'fruits'),
    
    // === ОРЕХИ И СЕМЕНА ===
    ProductData('Грецкий орех', 654, 15, 65, 14, 'nuts'),
    ProductData('Миндаль', 579, 21, 50, 22, 'nuts'),
    ProductData('Фундук', 628, 15, 61, 17, 'nuts'),
    ProductData('Кешью', 553, 18, 44, 30, 'nuts'),
    ProductData('Фисташки', 560, 20, 45, 28, 'nuts'),
    ProductData('Арахис', 567, 26, 49, 16, 'nuts'),
    ProductData('Семечки подсолнечника', 584, 21, 53, 20, 'nuts'),
    ProductData('Семена тыквы', 559, 30, 49, 11, 'nuts'),
    ProductData('Семена чиа', 486, 17, 31, 42, 'nuts'),
    ProductData('Семена льна', 534, 18, 42, 29, 'nuts'),
    ProductData('Кокос', 354, 3.3, 33, 15, 'nuts'),
    
    // === БОБОВЫЕ ===
    ProductData('Фасоль красная', 127, 8.7, 0.5, 22, 'legumes'),
    ProductData('Фасоль белая', 102, 7, 0.5, 18, 'legumes'),
    ProductData('Чечевица', 116, 9, 0.4, 20, 'legumes'),
    ProductData('Нут', 164, 8.9, 2.6, 27, 'legumes'),
    ProductData('Горох', 81, 5.4, 0.4, 14, 'legumes'),
    ProductData('Соя', 147, 13, 6.8, 11, 'legumes'),
    ProductData('Тофу', 76, 8, 4.8, 2, 'legumes'),
    
    // === СЛАДОСТИ И СНЕКИ ===
    ProductData('Шоколад молочный', 535, 7.6, 30, 59, 'sweets'),
    ProductData('Шоколад темный 70%', 546, 6.1, 41, 45, 'sweets'),
    ProductData('Мед', 304, 0.3, 0, 82, 'sweets'),
    ProductData('Печенье овсяное', 437, 6.5, 18, 65, 'sweets'),
    ProductData('Мороженое пломбир', 227, 3.7, 15, 20, 'sweets'),
    ProductData('Зефир', 326, 0.8, 0.1, 80, 'sweets'),
    ProductData('Чипсы картофельные', 536, 7, 35, 50, 'sweets'),
    
    // === НАПИТКИ ===
    ProductData('Кофе черный', 2, 0.1, 0, 0.3, 'drinks'),
    ProductData('Чай черный', 1, 0, 0, 0.3, 'drinks'),
    ProductData('Какао порошок', 374, 24, 17, 31, 'drinks'),
    ProductData('Сок апельсиновый', 45, 0.7, 0.2, 10, 'drinks'),
    ProductData('Сок яблочный', 46, 0.1, 0.1, 11, 'drinks'),
    ProductData('Кола', 42, 0, 0, 11, 'drinks'),
    ProductData('Энергетик', 45, 0, 0, 11, 'drinks'),
    
    // === СОУСЫ И МАСЛА ===
    ProductData('Оливковое масло', 884, 0, 100, 0, 'oils'),
    ProductData('Подсолнечное масло', 899, 0, 100, 0, 'oils'),
    ProductData('Кокосовое масло', 862, 0, 100, 0, 'oils'),
    ProductData('Майонез', 680, 0.3, 75, 2.6, 'oils'),
    ProductData('Кетчуп', 112, 1.8, 0.2, 26, 'oils'),
    ProductData('Соевый соус', 53, 6, 0, 6, 'oils'),
    ProductData('Горчица', 66, 4, 3, 6, 'oils'),
  ];
  
  static List<ProductData> search(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return products
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
  
  static List<ProductData> getByCategory(String category) {
    return products.where((p) => p.category == category).toList();
  }
}

class ProductData {
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final String category;
  
  const ProductData(this.name, this.calories, this.proteins, this.fats, this.carbs, this.category);
}
