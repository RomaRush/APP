import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/nutrition_provider.dart';

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/cgi/search.pl';

  static Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      // API request for simplified search
      final url = Uri.parse('$_baseUrl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page=1&page_size=20');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List products = data['products'] ?? [];
        
        return products.where((p) => p['product_name'] != null).map((json) {
           final nutriments = json['nutriments'] ?? {};
           
           double _parse(dynamic value) {
             if (value is num) return value.toDouble();
             if (value is String) return double.tryParse(value) ?? 0.0;
             return 0.0;
           }

           // Extract nutrients safely
           double calories = _parse(nutriments['energy-kcal_100g']) == 0.0 
               ? _parse(nutriments['energy-kcal_value']) 
               : _parse(nutriments['energy-kcal_100g']);
               
           double proteins = _parse(nutriments['proteins_100g']) == 0.0
               ? _parse(nutriments['proteins_value'])
               : _parse(nutriments['proteins_100g']);
               
           double fats = _parse(nutriments['fat_100g']) == 0.0
               ? _parse(nutriments['fat_value'])
               : _parse(nutriments['fat_100g']);
               
           double carbs = _parse(nutriments['carbohydrates_100g']) == 0.0
               ? _parse(nutriments['carbohydrates_value'])
               : _parse(nutriments['carbohydrates_100g']);

           return Product(
             name: json['product_name'] ?? 'Unknown',
             calories: calories,
             proteins: proteins,
             fats: fats,
             carbs: carbs,
             grams: 100, // Default to 100g
           );
        }).toList();
      }
      return [];
    } catch (e) {
      // Fail silently and return empty list (UI will show local results)
      print('OpenFoodFacts Error: $e');
      return [];
    }
  }
}
