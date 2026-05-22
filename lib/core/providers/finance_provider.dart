import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

// ── Transaction Categories ────────────────────────────────────────────────────

enum TransactionCategory {
  food,
  transport,
  entertainment,
  health,
  shopping,
  utilities,
  income,
  other,
}

extension TransactionCategoryExt on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.food: return 'Еда';
      case TransactionCategory.transport: return 'Транспорт';
      case TransactionCategory.entertainment: return 'Развлечения';
      case TransactionCategory.health: return 'Здоровье';
      case TransactionCategory.shopping: return 'Покупки';
      case TransactionCategory.utilities: return 'ЖКХ/Связь';
      case TransactionCategory.income: return 'Доход';
      case TransactionCategory.other: return 'Прочее';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food: return Icons.restaurant_rounded;
      case TransactionCategory.transport: return Icons.directions_car_rounded;
      case TransactionCategory.entertainment: return Icons.movie_rounded;
      case TransactionCategory.health: return Icons.favorite_rounded;
      case TransactionCategory.shopping: return Icons.shopping_bag_rounded;
      case TransactionCategory.utilities: return Icons.home_rounded;
      case TransactionCategory.income: return Icons.payments_rounded;
      case TransactionCategory.other: return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food: return const Color(0xFFFF7043);
      case TransactionCategory.transport: return const Color(0xFF42A5F5);
      case TransactionCategory.entertainment: return const Color(0xFFAB47BC);
      case TransactionCategory.health: return const Color(0xFFEF5350);
      case TransactionCategory.shopping: return const Color(0xFFFFCA28);
      case TransactionCategory.utilities: return const Color(0xFF26A69A);
      case TransactionCategory.income: return const Color(0xFF66BB6A);
      case TransactionCategory.other: return const Color(0xFF78909C);
    }
  }
}

// ── Transaction ───────────────────────────────────────────────────────────────

class Transaction {
  final String id;
  final String title;
  final int amount;
  final bool isExpense;
  final bool isCash;
  final DateTime date;
  final TransactionCategory category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    this.isCash = false,
    required this.date,
    this.category = TransactionCategory.other,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'isExpense': isExpense,
    'isCash': isCash,
    'date': date.toIso8601String(),
    'category': category.index,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    amount: json['amount'],
    isExpense: json['isExpense'],
    isCash: json['isCash'] ?? false,
    date: DateTime.parse(json['date']),
    category: TransactionCategory.values[json['category'] as int? ?? TransactionCategory.other.index],
  );
}


// ── Subscription ──────────────────────────────────────────────────────────────

class Subscription {
  final String id;
  final String name;
  final int amount;
  final DateTime? expiryDate;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'expiryDate': expiryDate?.toIso8601String(),
  };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'],
    name: json['name'],
    amount: json['amount'],
    expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
  );
}

// ── DiscountCard ──────────────────────────────────────────────────────────────

class DiscountCard {
  final String id;
  final String name;
  final String? imagePath;
  final String? codeData;
  final String? codeFormat;
  
  DiscountCard({
    required this.id,
    required this.name,
    this.imagePath,
    this.codeData,
    this.codeFormat,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imagePath': imagePath,
    'codeData': codeData,
    'codeFormat': codeFormat,
  };

  factory DiscountCard.fromJson(Map<String, dynamic> json) => DiscountCard(
    id: json['id'],
    name: json['name'],
    imagePath: json['imagePath'],
    codeData: json['codeData'],
    codeFormat: json['codeFormat'],
  );
}

// ── FinanceProvider ───────────────────────────────────────────────────────────

class FinanceProvider extends ChangeNotifier {
  int _balance = 0;
  int _cashBalance = 0;
  int _monthlyIncome = 0;
  int _monthlyExpenses = 0;
  int _monthlyBudget = 0; // 0 = not set
  int _lastResetMonth = -1;
  
  List<Transaction> _transactions = [];
  List<Subscription> _subscriptions = [
    Subscription(id: '1', name: 'Яндекс', amount: 399, expiryDate: DateTime.now().add(const Duration(days: 5))),
    Subscription(id: '2', name: 'Интернет', amount: 800, expiryDate: DateTime.now().add(const Duration(days: 15))),
    Subscription(id: '3', name: 'X5 клуб', amount: 139),
    Subscription(id: '4', name: 'Алиса про', amount: 299),
  ];
  
  List<DiscountCard> _discountCards = [
    DiscountCard(id: '1', name: 'Пятерочка'),
    DiscountCard(id: '2', name: 'Командор'),
  ];
  
  FinanceProvider() {
    _loadData();
  }

  int get balance => _balance;
  int get cashBalance => _cashBalance;
  int get monthlyIncome => _monthlyIncome;
  int get monthlyExpenses => _monthlyExpenses;
  int get monthlyBudget => _monthlyBudget;
  List<Transaction> get transactions => _transactions;
  List<Subscription> get subscriptions => _subscriptions;
  List<DiscountCard> get discountCards => _discountCards;

  // ── Budget progress ────────────────────────────────────────────────────────

  double get budgetProgress {
    if (_monthlyBudget <= 0) return 0;
    return (_monthlyExpenses / _monthlyBudget).clamp(0.0, 1.0);
  }

  bool get isBudgetOverrun => _monthlyBudget > 0 && _monthlyExpenses > _monthlyBudget;

  int get budgetRemaining => _monthlyBudget > 0 ? (_monthlyBudget - _monthlyExpenses) : 0;

  // ── Daily safe budget ──────────────────────────────────────────────────────
  
  double get dailySafeBudget {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysLeft = lastDay.day - now.day + 1;
    if (daysLeft == 0) return _balance.toDouble();
    return _balance / daysLeft;
  }

  // ── Category analytics ─────────────────────────────────────────────────────

  /// Returns total expenses per category for current month
  Map<TransactionCategory, int> get monthlyExpensesByCategory {
    final now = DateTime.now();
    final result = <TransactionCategory, int>{};
    for (final t in _transactions) {
      if (!t.isExpense) continue;
      if (t.date.month != now.month || t.date.year != now.year) continue;
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  // ── Load / Save ────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _balance = prefs.getInt('finance_balance') ?? 0;
      _cashBalance = prefs.getInt('finance_cash_balance') ?? 0;
      _monthlyIncome = prefs.getInt('finance_monthly_income') ?? 0;
      _monthlyExpenses = prefs.getInt('finance_monthly_expenses') ?? 0;
      _monthlyBudget = prefs.getInt('finance_monthly_budget') ?? 0;
      _lastResetMonth = prefs.getInt('finance_last_reset_month') ?? -1;
      
      final transactionsJson = prefs.getString('finance_transactions');
      if (transactionsJson != null) {
        final decoded = jsonDecode(transactionsJson) as List;
        _transactions = decoded.map((t) => Transaction.fromJson(t)).toList();
      }
      
      final subscriptionsJson = prefs.getString('finance_subscriptions');
      if (subscriptionsJson != null) {
        final decoded = jsonDecode(subscriptionsJson) as List;
        _subscriptions = decoded.map((s) => Subscription.fromJson(s)).toList();
      }

      final discountCardsJson = prefs.getString('finance_discount_cards');
      if (discountCardsJson != null) {
        final decoded = jsonDecode(discountCardsJson) as List;
        _discountCards = decoded.map((d) => DiscountCard.fromJson(d)).toList();
      }
      
      // Check for monthly reset
      _checkMonthlyReset();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading finance data: $e');
    }
  }

  void _checkMonthlyReset() {
    final now = DateTime.now();
    final currentMonth = now.year * 12 + now.month;
    if (_lastResetMonth != currentMonth && _lastResetMonth != -1) {
      // New month — reset monthly counters
      _monthlyIncome = 0;
      _monthlyExpenses = 0;
      _lastResetMonth = currentMonth;
    } else if (_lastResetMonth == -1) {
      _lastResetMonth = currentMonth;
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('finance_balance', _balance);
      await prefs.setInt('finance_cash_balance', _cashBalance);
      await prefs.setInt('finance_monthly_income', _monthlyIncome);
      await prefs.setInt('finance_monthly_expenses', _monthlyExpenses);
      await prefs.setInt('finance_monthly_budget', _monthlyBudget);
      await prefs.setInt('finance_last_reset_month', _lastResetMonth);
      
      await prefs.setString('finance_transactions', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
      await prefs.setString('finance_subscriptions', jsonEncode(_subscriptions.map((s) => s.toJson()).toList()));
      await prefs.setString('finance_discount_cards', jsonEncode(_discountCards.map((d) => d.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving finance data: $e');
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void setCashBalance(int value) {
    _cashBalance = value;
    _saveData();
    notifyListeners();
  }

  void setMonthlyBudget(int value) {
    _monthlyBudget = value;
    _saveData();
    notifyListeners();
  }

  void addTransaction(
    String title,
    int amount,
    bool isExpense, {
    bool isCash = false,
    TransactionCategory category = TransactionCategory.other,
  }) {
    _transactions.insert(0, Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      isExpense: isExpense,
      isCash: isCash,
      date: DateTime.now(),
      category: isExpense ? category : TransactionCategory.income,
    ));

    if (isExpense) {
      if (isCash) {
        _cashBalance -= amount;
      } else {
        _balance -= amount;
      }
      _monthlyExpenses += amount;
    } else {
      if (isCash) {
        _cashBalance += amount;
      } else {
        _balance += amount;
      }
      _monthlyIncome += amount;
    }
    
    _saveData();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    final t = _transactions.firstWhere((t) => t.id == id, orElse: () => throw Exception('not found'));
    if (t.isExpense) {
      if (t.isCash) {
        _cashBalance += t.amount;
      } else {
        _balance += t.amount;
      }
      _monthlyExpenses = (_monthlyExpenses - t.amount).clamp(0, double.maxFinite.toInt());
    } else {
      if (t.isCash) {
        _cashBalance -= t.amount;
      } else {
        _balance -= t.amount;
      }
      _monthlyIncome = (_monthlyIncome - t.amount).clamp(0, double.maxFinite.toInt());
    }
    _transactions.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  void addSubscription(String name, int amount, {DateTime? expiryDate}) {
    final newSub = Subscription(
      id: DateTime.now().toString(),
      name: name,
      amount: amount,
      expiryDate: expiryDate,
    );
    _subscriptions.add(newSub);
    
    if (expiryDate != null) {
      _scheduleSubscriptionNotification(newSub);
    }
    
    _saveData();
    notifyListeners();
  }

  void removeSubscription(String id) {
    _subscriptions.removeWhere((element) => element.id == id);
    _saveData();
    notifyListeners();
  }
  
  Future<void> _scheduleSubscriptionNotification(Subscription sub) async {
    if (sub.expiryDate == null) return;
    
    final notificationDate = sub.expiryDate!.subtract(const Duration(days: 1));
    if (notificationDate.isBefore(DateTime.now())) return;

    final notifId = sub.id.hashCode;
    final service = NotificationService();
    
    await service.scheduleNotification(
      id: notifId,
      title: 'Напоминание о подписке',
      body: 'Завтра спишется ${sub.amount}₽ за подписку ${sub.name}',
      scheduledDate: notificationDate,
    );
  }
  
  void addDiscountCard(String name, {String? imagePath, String? codeData, String? codeFormat}) {
    _discountCards.add(DiscountCard(
      id: DateTime.now().toString(),
      name: name,
      imagePath: imagePath,
      codeData: codeData,
      codeFormat: codeFormat,
    ));
    _saveData();
    notifyListeners();
  }
  
  void removeDiscountCard(String id) {
    _discountCards.removeWhere((element) => element.id == id);
    _saveData();
    notifyListeners();
  }

  bool isSubscriptionUseful(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('internet') || lower.contains('интернет') || lower.contains('жкх')) {
      return true;
    }
    return false;
  }
}
