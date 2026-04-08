import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class Transaction {
  final String id;
  final String title;
  final int amount;
  final bool isExpense;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'isExpense': isExpense,
    'date': date.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    amount: json['amount'],
    isExpense: json['isExpense'],
    date: DateTime.parse(json['date']),
  );
}



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

class FinanceProvider extends ChangeNotifier {
  int _balance = 0; // Card Balance
  int _cashBalance = 0; // Cash Balance
  int _monthlyIncome = 0;
  int _monthlyExpenses = 0;
  
  List<Transaction> _transactions = [];
  List<Subscription> _subscriptions = [
    Subscription(id: '1', name: 'Яндекс', amount: 399, expiryDate: DateTime.now().add(const Duration(days: 5))), // Example
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
  List<Transaction> get transactions => _transactions;
  List<Subscription> get subscriptions => _subscriptions;
  List<DiscountCard> get discountCards => _discountCards;
  
  // Smart Finance
  double get dailySafeBudget {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysLeft = lastDay.day - now.day + 1;
    if (daysLeft == 0) return _balance.toDouble();
    return _balance / daysLeft;
  }
  
  bool isSubscriptionUseful(String name) {
    // Simple mock logic: if name contains "Pro" or "Premium", it's debatable.
    // If it's utilities "Internet", it's useful.
    final lower = name.toLowerCase();
    if (lower.contains('internet') || lower.contains('интернет') || lower.contains('жкх')) {
      return true;
    }
    return false; // Flag for review
  }
  
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _balance = prefs.getInt('finance_balance') ?? 0;
      _cashBalance = prefs.getInt('finance_cash_balance') ?? 0;
      _monthlyIncome = prefs.getInt('finance_monthly_income') ?? 0;
      _monthlyExpenses = prefs.getInt('finance_monthly_expenses') ?? 0;
      
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
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading finance data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('finance_balance', _balance);
      await prefs.setInt('finance_cash_balance', _cashBalance);
      await prefs.setInt('finance_monthly_income', _monthlyIncome);
      await prefs.setInt('finance_monthly_expenses', _monthlyExpenses);
      
      await prefs.setString('finance_transactions', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
      await prefs.setString('finance_subscriptions', jsonEncode(_subscriptions.map((s) => s.toJson()).toList()));
      await prefs.setString('finance_discount_cards', jsonEncode(_discountCards.map((d) => d.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving finance data: $e');
    }
  }

  void setCashBalance(int value) {
    _cashBalance = value;
    _saveData();
    notifyListeners();
  }

  void addTransaction(String title, int amount, bool isExpense, {bool isCash = false}) {
    _transactions.insert(0, Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      isExpense: isExpense,
      date: DateTime.now(),
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
    // Note: To cancel notification we need the ID used. 
    // We'll use hashCode of ID or similar consistent mapping in future improvements.
    _saveData();
    notifyListeners();
  }
  
  Future<void> _scheduleSubscriptionNotification(Subscription sub) async {
    if (sub.expiryDate == null) return;
    
    final notificationDate = sub.expiryDate!.subtract(const Duration(days: 1));
    if (notificationDate.isBefore(DateTime.now())) return;

    // Use hash of ID for notification ID (simple approach)
    final notifId = sub.id.hashCode; 
    
    final service = NotificationService();
    // Assuming service is initialized somewhere or we init it here loosely
    // Ideally init at app start.
    
    // Logic to schedule is needed in NotificationService. 
    // We already have 'zonedSchedule' in NotificationService.
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
}
