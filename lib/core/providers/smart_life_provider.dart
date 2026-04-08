import 'package:flutter/material.dart';
import 'finance_provider.dart';
import 'health_provider.dart';
import 'work_provider.dart';
import 'nutrition_provider.dart';

class SmartLifeProvider extends ChangeNotifier {
  final HealthProvider health;
  final WorkProvider work;
  final FinanceProvider finance;
  final NutritionProvider nutrition;

  SmartLifeProvider({
    required this.health,
    required this.work,
    required this.finance,
    required this.nutrition,
  });

  // --- Calculated Metrics ---

  /// Body Battery (0-100%)
  /// Based on sleep hours (Health), steps (Health), and food quality (Nutrition - placeholder concept)
  int get bodyBattery {
    double score = 100;
    
    // 1. Sleep impact (Target 8 hours)
    // If sleep is < 5 hours, significant penalty
    double sleep = health.sleepHours;
    if (sleep < 5) {
      score -= 40;
    } else if (sleep < 7) {
      score -= 20;
    } else if (sleep > 9) {
      score -= 5; // Oversleeping slight penalty
    }

    // 2. Mental State penalty
    if (health.mentalStatus == 'Плохо' || health.mentalStatus == 'Ужасно') {
      score -= 30;
    } else if (health.mentalStatus == 'Нормально') {
      score -= 10;
    }

    // 3. Activity Boost (Steps)
    // Up to +10 bonus for good activity
    if (health.steps > 8000) {
      score += 10;
    } else if (health.steps > 5000) {
      score += 5;
    }

    // 4. Hydration Check (Nutrition)
    // If water goal not met by evening, slight penalty (Simulated logic)
    // We don't have time-of-day check strictly here, but let's assume if water is very low, it drags down.
    if (nutrition.waterGlasses < 2) {
      score -= 10;
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
