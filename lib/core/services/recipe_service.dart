
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import '../data/recipe_database.dart';
import '../data/ingredient_dictionary.dart';

abstract class RecipeService {
  Future<List<RecipeData>> findRecipesByIngredients(List<String> ingredients);
}

class TheMealDBService implements RecipeService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  final GoogleTranslator _translator = GoogleTranslator();

  @override
  Future<List<RecipeData>> findRecipesByIngredients(List<String> rawIngredients) async {
    if (rawIngredients.isEmpty) return [];

    // 1. Translate Ingredients
    final englishIngredients = <String>{};
    for (final raw in rawIngredients) {
      final translated = IngredientDictionary.translate(raw);
      if (translated != null) {
        englishIngredients.add(translated);
      }
    }

    if (englishIngredients.isEmpty) {
      print('RecipeService: Could not translate any ingredients: $rawIngredients');
      return [];
    }
    
    print('RecipeService: Searching for: $englishIngredients');

    // 2. Search Strategy
    List<RecipeData> results = [];
    
    // Combined search
    if (englishIngredients.length > 1) {
       final combinedQuery = englishIngredients.join(',');
       results = await _fetchRecipes(combinedQuery);
    }
    
    // Fallback search
    if (results.isEmpty) {
      for (final ingredient in englishIngredients) {
        final individualResults = await _fetchRecipes(ingredient);
        results.addAll(individualResults);
      }
    }
    
    // Deduplicate
    final uniqueIds = <String>{};
    final uniqueResults = <RecipeData>[];
    for (final r in results) {
      if (uniqueIds.add(r.name)) {
        uniqueResults.add(r);
      }
    }
    
    // 3. Translate Results to Russian (Limit to top 3 for performance)
    final topResults = uniqueResults.take(3).toList();
    final translatedResults = <RecipeData>[];
    
    for (final recipe in topResults) {
      final translated = await _translateRecipe(recipe);
      translatedResults.add(translated);
    }
    
    return translatedResults;
  }
  
  Future<RecipeData> _translateRecipe(RecipeData recipe) async {
    try {
      // Translate Name
      final nameTranslation = await _translator.translate(recipe.name, to: 'ru');
      
      // Translate Ingredients (Batch if possible, but line by line is safer for formatting)
      final translatedIngredients = <String>[];
      for (final ing in recipe.ingredients) {
         final tr = await _translator.translate(ing, to: 'ru');
         translatedIngredients.add(tr.text);
      }
      
      // Translate Steps
      final translatedSteps = <String>[];
      for (final step in recipe.steps) {
         final tr = await _translator.translate(step, to: 'ru');
         translatedSteps.add(tr.text);
      }
      
      return RecipeData(
        name: nameTranslation.text,
        category: recipe.category,
        ingredients: translatedIngredients,
        steps: translatedSteps,
        videoThumbnail: recipe.videoThumbnail,
        videoUrl: recipe.videoUrl,
        stepImages: recipe.stepImages,
        calories: recipe.calories,
        proteins: recipe.proteins,
        fats: recipe.fats,
        carbs: recipe.carbs,
        cookTime: recipe.cookTime,
      );
    } catch (e) {
      print('Translation error: $e');
      return recipe; // Return original if translation fails
    }
  }
  
  Future<List<RecipeData>> _fetchRecipes(String query) async {
    final url = Uri.parse('$_baseUrl/filter.php?i=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null) {
             final List meals = data['meals'];
             final List<RecipeData> recipes = [];
             // Only fetch top 5 to keep search fast, translation will limit further
             for (var i = 0; i < meals.length && i < 5; i++) {
               final detail = await _getMealDetails(meals[i]['idMeal']);
               if (detail != null) recipes.add(detail);
             }
             return recipes;
        }
      }
    } catch (e) {
      print('Error fetching recipes for query "$query": $e');
    }
    return [];
  }
  
  Future<RecipeData?> _getMealDetails(String id) async {
    final url = Uri.parse('$_baseUrl/lookup.php?i=$id');
     try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            final meal = data['meals'][0];
            return _mapToRecipeData(meal);
          }
        }
     } catch (e) {
       print('Error fetching meal details: $e');
     }
     return null;
  }
  
  RecipeData _mapToRecipeData(Map<String, dynamic> json) {
    // Extract ingredients
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add('$ingredient ${measure ?? ""}');
      }
    }
    
    // Parse steps
    final instructions = json['strInstructions'].toString();
    // Split by newlines, filter empty
    final steps = instructions
        .split(RegExp(r'\r\n|\n|\r'))
        .where((s) => s.trim().length > 5) // Filter out tiny lines
        .toList();
    
    return RecipeData(
      name: json['strMeal'], 
      category: json['strCategory']?.toLowerCase() ?? 'custom',
      ingredients: ingredients,
      steps: steps.isNotEmpty ? steps : ['Follow instructions on video or website.'],
      videoThumbnail: json['strMealThumb'], // Use meal thumb as video thumb too
      videoUrl: json['strYoutube'], 
      stepImages: [],
      // Random/Default macros
      calories: 300 + (ingredients.length * 20).toDouble(), 
      proteins: 15,
      fats: 10,
      carbs: 30,
      cookTime: 30,
    );
  }
}
