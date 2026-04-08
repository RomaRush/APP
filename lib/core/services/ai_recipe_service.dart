import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/recipe_database.dart';
import 'recipe_service.dart';

class AiRecipeService implements RecipeService {
  final String _apiKey; // Initialized from config or UI
  late final GenerativeModel _model;

  AiRecipeService(this._apiKey) {
    _model = GenerativeModel(
      model: 'gemini-pro', 
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      )
    );
  }

  @override
  Future<List<RecipeData>> findRecipesByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) return [];

    final prompt = '''
Ты — кулинарный поисковый помощник для приложения.

Задача:
По списку ингредиентов пользователя найди РЕАЛЬНЫЙ рецепт из интернета,
который максимально соответствует этим ингредиентам.

Правила:
1. Основные ингредиенты должны совпадать с запросом пользователя.
2. Разрешено добавлять базовые ингредиенты:
   соль, перец, масло, вода, специи.
3. Используй популярные и общеизвестные рецепты.
4. Если найдено несколько рецептов — выбери самый подходящий.
5. Верни краткую информацию, без лишнего текста.
6. Отвечай СТРОГО в формате JSON.

Формат ответа:
{
  "query": "${ingredients.join(', ')}",
  "recipe": {
    "title": "<название рецепта>",
    "ingredients": ["<список ингредиентов>"],
    "short_description": "<1–2 предложения о блюде>",
    "steps": ["<шаг 1>", "<шаг 2>", ...],
    "source": "<название сайта или 'популярный кулинарный рецепт'>"
  }
}
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      var text = response.text;
      
      if (text == null) {
        print('AI Recipe Error: Response text is null');
        return [];
      }
      
      // Clean up markdown code blocks if present
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      print('AI Recipe Raw Response: $text'); // Debug log

      // Parse JSON
      final json = jsonDecode(text);
      final recipeJson = json['recipe'];
      
      return [RecipeData(
        name: recipeJson['title'],
        category: 'AI Chef',
        ingredients: List<String>.from(recipeJson['ingredients']),
        steps: recipeJson['steps'] != null 
             ? List<String>.from(recipeJson['steps']) 
             : ['Инструкция не найдена, следуйте общим правилам.'],
        videoThumbnail: null, // AI text doesn't give images usually, use placeholder
        videoUrl: null,
        stepImages: [],
        calories: 300, // Placeholder or AI could estimate
        proteins: 10,
        fats: 10,
        carbs: 40,
        cookTime: 30, // Placeholder
      )];
      
    } catch (e) {
      print('AI Recipe Error: $e');
      return [];
    }
  }
}
