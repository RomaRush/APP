import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority,
    'category': category,
  };

  factory TodoItem.fromMap(Map<String, dynamic> map) => TodoItem(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    isCompleted: map['isCompleted'] == 1,
    createdAt: DateTime.parse(map['createdAt']),
    dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    priority: map['priority'] ?? 1,
    category: map['category'] ?? 'Общее',
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
      final db = await DatabaseHelper().database;
      
      // Load categories
      final List<Map<String, dynamic>> cats = await db.query('todo_categories');
      if (cats.isNotEmpty) {
        _categories = cats.map((c) => c['name'] as String).toList();
      } else {
        // Initialize default categories in DB if empty
        for (var cat in _categories) {
          await db.insert('todo_categories', {'name': cat}, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }

      // Load todos
      final List<Map<String, dynamic>> maps = await db.query('todos');
      _todos = maps.map((item) => TodoItem.fromMap(item)).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading todo data from SQLite: $e');
    }
  }

  Future<void> addTodo(String title, {String? description, DateTime? dueDate, int priority = 1, String category = 'Общее'}) async {
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
    notifyListeners(); // Обновляем UI мгновенно, не дожидаясь базы

    try {
      final db = await DatabaseHelper().database;
      await db.insert('todos', todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Error saving todo: $e');
    }
  }

  Future<void> updateTodo(String id, {String? title, String? description, DateTime? dueDate, int? priority, String? category}) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      if (title != null) _todos[index].title = title;
      if (description != null) _todos[index].description = description;
      if (dueDate != null) _todos[index].dueDate = dueDate;
      if (priority != null) _todos[index].priority = priority;
      if (category != null) _todos[index].category = category;
      notifyListeners();

      try {
        final db = await DatabaseHelper().database;
        await db.update('todos', _todos[index].toMap(), where: 'id = ?', whereArgs: [id]);
      } catch (e) {
        debugPrint('Error updating todo: $e');
      }
    }
  }

  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      notifyListeners();

      try {
        final db = await DatabaseHelper().database;
        await db.update('todos', {'isCompleted': _todos[index].isCompleted ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
      } catch (e) {
        debugPrint('Error toggling todo: $e');
      }
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();

    try {
      final db = await DatabaseHelper().database;
      await db.delete('todos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();

      try {
        final db = await DatabaseHelper().database;
        await db.insert('todo_categories', {'name': category}, conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (e) {
        debugPrint('Error inserting category: $e');
      }
    }
  }

  Future<void> deleteCategory(String category) async {
    if (category != 'Общее') {
      _categories.remove(category);
      
      for (var todo in _todos.where((t) => t.category == category)) {
        todo.category = 'Общее';
      }
      if (_selectedCategory == category) {
        _selectedCategory = 'Все';
      }
      notifyListeners();

      try {
        final db = await DatabaseHelper().database;
        await db.delete('todo_categories', where: 'name = ?', whereArgs: [category]);
        await db.update('todos', {'category': 'Общее'}, where: 'category = ?', whereArgs: [category]);
      } catch (e) {
        debugPrint('Error deleting category: $e');
      }
    }
  }

  Future<void> clearCompleted() async {
    _todos.removeWhere((t) => t.isCompleted);
    notifyListeners();

    try {
      final db = await DatabaseHelper().database;
      await db.delete('todos', where: 'isCompleted = ?', whereArgs: [1]);
    } catch (e) {
      debugPrint('Error clearing completed todos: $e');
    }
  }
}
