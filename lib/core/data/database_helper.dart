import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  static Database? _database;
  
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "daylo_db.db");
    
    // При изменении структуры (добавлении новых таблиц) можно менять version и дописывать onUpgrade
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Здесь мы создаем полную структуру базы данных входной и выходной информации
  Future<void> _onCreate(Database db, int version) async {
    // ---- 1. APP PREFERENCES (Глобальные настройки и метрики пользователя) ----
    await db.execute('''
      CREATE TABLE app_prefs (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // ---- 2. FINANCE (Вход: транзакции, подписки, карты. Выход: баланс, расходы, доходы) ----
    await db.execute('''
      CREATE TABLE finance_transactions (
        id TEXT PRIMARY KEY,
        title TEXT,
        amount INTEGER,
        isExpense INTEGER, -- 0 (доход) или 1 (расход)
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE finance_subscriptions (
        id TEXT PRIMARY KEY,
        name TEXT,
        amount INTEGER,
        expiryDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE finance_discount_cards (
        id TEXT PRIMARY KEY,
        name TEXT,
        imagePath TEXT,
        codeData TEXT,
        codeFormat TEXT
      )
    ''');

    // ---- 3. TASKS (Вход: задачи, дедлайны. Выход: статус завершения, статистика) ----
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        isCompleted INTEGER, -- 0 (в процессе) или 1 (завершено)
        createdAt TEXT,
        dueDate TEXT,
        priority INTEGER,
        category TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE todo_categories (
        name TEXT PRIMARY KEY
      )
    ''');

    // ---- 4. NOTES (Вход: текст, списки в заметках. Выход: структурированные записи) ----
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        reminderDateTime TEXT,
        todoItemsJson TEXT -- Сохранение чек-листов внутри заметки (в JSON)
      )
    ''');

    // ---- 5. WORK (Вход: переключатели дней, таймер Pomodoro. Выход: часы, зарплата, заработок за сессию) ----
    await db.execute('''
      CREATE TABLE work_days (
        dateKey TEXT PRIMARY KEY, -- формат 'YYYY-MM-DD'
        hours REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE work_comments (
        dateKey TEXT PRIMARY KEY,
        comment TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE work_weekend_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan TEXT
      )
    ''');

    // ---- 6. HEALTH & LIFESTYLE (Вход: трекинг настроения, сон, вода. Выход: Body Battery, статистика) ----
    await db.execute('''
      CREATE TABLE health_mood_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status TEXT,
        color INTEGER,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE health_sleep_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        hours REAL,
        start TEXT,
        end TEXT
      )
    ''');
    
    // Трекер воды
    await db.execute('''
      CREATE TABLE drink_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER,
        time TEXT,
        amountMl INTEGER
      )
    ''');

    // ---- 7. NUTRITION (Вход: список покупок, холодильник, съеденное. Выход: остаток калорий/БЖУ) ----
    await db.execute('''
      CREATE TABLE nutrition_meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateKey TEXT, -- 'YYYY-MM-DD'
        mealType TEXT, -- 'breakfast', 'lunch', 'dinner', 'snack'
        productJson TEXT -- Сериализованный объект Product
      )
    ''');

    await db.execute('''
      CREATE TABLE nutrition_cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productJson TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE shopping_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        isChecked INTEGER -- 0 или 1
      )
    ''');

    await db.execute('''
      CREATE TABLE nutrition_user_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productJson TEXT
      )
    ''');
  }
}
