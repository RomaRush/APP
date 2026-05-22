import 'package:flutter/material.dart';
import 'finance_provider.dart';
import 'health_provider.dart';
import 'work_provider.dart';
import 'nutrition_provider.dart';

class SmartLifeProvider extends ChangeNotifier {
  HealthProvider health;
  WorkProvider work;
  FinanceProvider finance;
  NutritionProvider nutrition;

  SmartLifeProvider({
    required this.health,
    required this.work,
    required this.finance,
    required this.nutrition,
  });

  void update({
    HealthProvider? health,
    WorkProvider? work,
    FinanceProvider? finance,
    NutritionProvider? nutrition,
  }) {
    if (health != null) this.health = health;
    if (work != null) this.work = work;
    if (finance != null) this.finance = finance;
    if (nutrition != null) this.nutrition = nutrition;
    notifyListeners();
  }

  // --- Calculated Metrics ---

  /// Body Battery (0-100%)
  /// Based on sleep hours (Health), steps (Health), and food quality (Nutrition - placeholder concept)
  int get bodyBattery {
    double score = 60; // Neutral baseline — not 100, avoids artificially high starting point

    // 1. Sleep impact (Target 8 hours)
    double sleep = health.sleepHours;
    if (sleep >= 8) {
      score += 30;
    } else if (sleep >= 6) {
      score += 15;
    } else if (sleep >= 5) {
      score += 5;
    } else if (sleep > 0) {
      score -= 20; // only penalize if sleep was actually tracked and is very short
    }

    // 2. Mental State
    if (health.mentalStatus == 'Отлично' || health.mentalStatus == 'Хорошо') {
      score += 10;
    } else if (health.mentalStatus == 'Плохо' || health.mentalStatus == 'Ужасно') {
      score -= 20;
    }

    // 3. Activity Boost (Steps) — only positive contribution
    if (health.steps > 8000) {
      score += 15;
    } else if (health.steps > 5000) {
      score += 8;
    } else if (health.steps > 2000) {
      score += 3;
    }
    // steps == 0 → no penalty, just no bonus

    // 4. Hydration
    if (nutrition.waterGlasses >= nutrition.waterGoal) {
      score += 5;
    } else if (nutrition.waterGlasses < 2 && nutrition.waterGlasses > 0) {
      score -= 5; // only penalize if actively tracked and very low
    }

    return score.clamp(0, 100).round();
  }

  /// Daily Safe Budget Advice
  /// Returns a string advising on spending based on daily limit logic.
  String get dailyBudgetAdvice {
    // Simple logic: (Income - Expenses) / Days Remaining
    // Getting raw data from FinanceProvider
    // Note: FinanceProvider currently tracks total balance. 
    // We will assume a monthly budget approach for this calculation or use current balance as "available for month".
    
    int balance = finance.balance;
    if (balance <= 0) {
      return "Бюджет исчерпан. Режим строгой экономии.";
    }

    // Days remaining in month
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysLeft = lastDay.day - now.day + 1;

    final dailySafe = balance / daysLeft;

    if (dailySafe < 500) {
      return "Лимит на сегодня: ${dailySafe.toStringAsFixed(0)}₽. Осторожнее с тратами.";
    } else if (dailySafe > 3000) {
      return "Лимит на сегодня: ${dailySafe.toStringAsFixed(0)}₽. Можно побаловать себя.";
    } else {
      return "Твой бюджет на день: ${dailySafe.toStringAsFixed(0)}₽.";
    }
  }

  // --- Smart Insights & Synergies ---

  List<SmartInsight> get activeInsights {
    final List<SmartInsight> insights = [];

    // 1. Health -> Work Synergy
    // If Body Battery is low, suggest easier work mode
    if (bodyBattery < 40) {
      insights.add(SmartInsight(
        title: "Низкий заряд сил",
        description: "Твоя батарейка ${bodyBattery}%. Рекомендуем переключить работу в 'Лайт режим'.",
        type: InsightType.warning,
        actionLabel: "Включить Лайт",
        onAction: () {
          // Future: Call work.setLightMode()
        },
      ));
    }

    // 2. Finance -> Nutrition Synergy
    // If budget is tight (< 500/day safe), suggest saving on food
    if (finance.balance > 0) { // check to avoid div by zero or negative logic issues above
       final now = DateTime.now();
       final lastDay = DateTime(now.year, now.month + 1, 0);
       final daysLeft = lastDay.day - now.day + 1;
       if ((finance.balance / daysLeft) < 500) {
          insights.add(SmartInsight(
            title: "Экономия бюджета",
            description: "Лимит на день низкий. Посмотри рецепты из категории 'Экономно'.",
            type: InsightType.tip,
            actionLabel: "Рецепты",
            onAction: () {},
          ));
       }
    }

    // 3. Work -> Health Synergy
    // If worked > 9 hours today (checking WorkProvider)
    double todayWorkHours = work.workedDays[DateTime.now().day] ?? 0;
    if (todayWorkHours > 9) {
      insights.add(SmartInsight(
        title: "Переработка",
        description: "Ты работаешь уже ${todayWorkHours}ч. Риск выгорания!",
        type: InsightType.danger,
        actionLabel: "Отдохнуть",
        onAction: () {},
      ));
    }

    return insights;
  }
}

enum InsightType { tip, warning, danger }

class SmartInsight {
  final String title;
  final String description;
  final InsightType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  SmartInsight({
    required this.title,
    required this.description,
    required this.type,
    this.actionLabel,
    this.onAction,
  });
}
