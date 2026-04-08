import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoItem {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  int priority; // 0 = low, 1 = medium, 2 = high
  String category;

  TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = 1,
    this.category = 'Общее',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority,
    'category': category,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    isCompleted: json['isCompleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    priority: json['priority'] ?? 1,
    category: json['category'] ?? 'Общее',
  );
}

class TodoProvider extends ChangeNotifier {
  List<TodoItem> _todos = [];
  List<String> _categories = ['Общее', 'Работа', 'Личное', 'Покупки'];
  String _selectedCategory = 'Все';
  bool _showCompleted = true;

  List<TodoItem> get todos => _todos;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get showCompleted => _showCompleted;

  List<TodoItem> get filteredTodos {
    var filtered = _todos;
    
    if (_selectedCategory != 'Все') {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }
    
    if (!_showCompleted) {
      filtered = filtered.where((t) => !t.isCompleted).toList();
    }
    
    // Sort: incomplete first, then by priority (high to low), then by due date
    filtered.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    
    return filtered;
  }

  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((t) => t.isCompleted).length;
  int get pendingTodos => _todos.where((t) => !t.isCompleted).length;

  TodoProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final todosJson = prefs.getString('todo_items');
      if (todosJson != null) {
        final decoded = jsonDecode(todosJson) as List;
        _todos = decoded.map((item) => TodoItem.fromJson(item)).toList();
      }
      
      final categoriesJson = prefs.getString('todo_categories');
      if (categoriesJson != null) {
        _categories = List<String>.from(jsonDecode(categoriesJson));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading todo data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('todo_items', jsonEncode(_todos.map((t) => t.toJson()).toList()));
      await prefs.setString('todo_categories', jsonEncode(_categories));
    } catch (e) {
      debugPrint('Error saving todo data: $e');
    }
  }

  void addTodo(String title, {String? description, DateTime? dueDate, int priority = 1, String category = 'Общее'}) {
    final todo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      category: category,
    );
    _todos.add(todo);
    _saveData();
    notifyListeners();
  }

  void updateTodo(String id, {String? title, String? description, DateTime? dueDate, int? priority, String? category}) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      if (title != null) _todos[index].title = title;
      if (description != null) _todos[index].description = description;
      if (dueDate != null) _todos[index].dueDate = dueDate;
      if (priority != null) _todos[index].priority = priority;
      if (category != null) _todos[index].category = category;
      _saveData();
      notifyListeners();
    }
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      _saveData();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      _saveData();
      notifyListeners();
    }
  }

  void deleteCategory(String category) {
    if (category != 'Общее') {
      _categories.remove(category);
      // Move todos from deleted category to 'Общее'
      for (var todo in _todos.where((t) => t.category == category)) {
        todo.category = 'Общее';
      }
      if (_selectedCategory == category) {
        _selectedCategory = 'Все';
      }
      _saveData();
      notifyListeners();
    }
  }

  void clearCompleted() {
    _todos.removeWhere((t) => t.isCompleted);
    _saveData();
    notifyListeners();
  }
}
