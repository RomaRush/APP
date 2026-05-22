import 'package:flutter_test/flutter_test.dart';
import 'package:daylo_app/core/providers/finance_provider.dart';
import 'package:daylo_app/core/providers/health_provider.dart';
import 'package:daylo_app/core/providers/nutrition_provider.dart';
import 'package:daylo_app/core/providers/work_provider.dart';
import 'package:daylo_app/core/providers/smart_life_provider.dart';

// Mocks
class MockHealthProvider extends HealthProvider {
  double _testSleep = 8.0;
  int _testSteps = 0;
  String _testMental = 'Нормально';

  @override
  double get sleepHours => _testSleep;
  @override
  int get steps => _testSteps;
  @override
  String get mentalStatus => _testMental;

  void setTestValues({double? sleep, int? steps, String? mental}) {
    if (sleep != null) _testSleep = sleep;
    if (steps != null) _testSteps = steps;
    if (mental != null) _testMental = mental;
    notifyListeners();
  }
}

class MockFinanceProvider extends FinanceProvider {
  int _testBalance = 0;

  @override
  int get balance => _testBalance;

  void setTestBalance(int bal) {
    _testBalance = bal;
    notifyListeners();
  }
}

class MockWorkProvider extends WorkProvider {
  Map<int, double> _testWorkedDays = {};

  @override
  Map<int, double> get workedDays => _testWorkedDays;

  void setTestWorkedHoursToday(double hours) {
    _testWorkedDays = {DateTime.now().day: hours};
    notifyListeners();
  }
}

class MockNutritionProvider extends NutritionProvider {
  int _testWater = 0;

  @override
  int get waterGlasses => _testWater;

  void setTestWater(int glasses) {
    _testWater = glasses;
    notifyListeners();
  }
}

void main() {
  group('SmartLifeProvider Tests', () {
    late SmartLifeProvider smartLife;
    late MockHealthProvider health;
    late MockFinanceProvider finance;
    late MockWorkProvider work;
    late MockNutritionProvider nutrition;

    setUp(() {
      health = MockHealthProvider();
      finance = MockFinanceProvider();
      work = MockWorkProvider();
      nutrition = MockNutritionProvider();
      
      smartLife = SmartLifeProvider(
        health: health,
        work: work,
        finance: finance,
        nutrition: nutrition,
      );
    });

    test('Body Battery Calculation - Ideal Day', () {
      health.setTestValues(sleep: 8, steps: 10000, mental: 'Отлично');
      nutrition.setTestWater(8);
      
      // Base 100 
      // Sleep 8h -> 0 penalty
      // Mental Excellent (not Bad/Normal) -> 0 penalty (Assuming default)
      // Steps 10000 -> +10
      // Water 8 -> 0 penalty
      // Result should be 100 (capped)
      
      // Wait, let's check implementation of mental
      // if (mentalStatus == 'Плохо') -30
      // else if ('Нормально') -10
      // So 'Отлично' is 0 penalty.
      
      expect(smartLife.bodyBattery, 100);
    });

    test('Body Battery Calculation - Bad Day', () {
      health.setTestValues(sleep: 4, steps: 2000, mental: 'Плохо');
      nutrition.setTestWater(0);
      
      // Base 100
      // Sleep 4h -> -40 (score 60)
      // Mental Bad -> -30 (score 30)
      // Steps 2000 -> +0
      // Water 0 -> -10 (score 20)
      
      expect(smartLife.bodyBattery, 20);
    });

    test('Daily Budget Advice - Low Budget', () {
      finance.setTestBalance(100); // very low for a month
      // Days left >= 1. 
      // 100 / 30 = ~3. 
      // Advice should safeguard.
      
      expect(smartLife.dailyBudgetAdvice, contains('Осторожнее с тратами'));
    });

    test('Insights Generation - Work Overload', () {
      work.setTestWorkedHoursToday(10); // > 9 hours
      
      final insights = smartLife.activeInsights;
      expect(insights.any((i) => i.title == 'Переработка'), true);
    });

    test('Insights Generation - Low Battery', () {
      health.setTestValues(sleep: 3, mental: 'Плохо'); // Very low battery
      
      final insights = smartLife.activeInsights;
      expect(insights.any((i) => i.title == 'Низкий заряд сил'), true);
    });
  });
}
