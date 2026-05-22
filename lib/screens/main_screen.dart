import 'package:flutter/material.dart';
import '../widgets/liquid_nav_bar.dart';
import 'home/home_screen.dart';
import 'finance/finance_screen.dart';
import 'health/health_screen.dart';
import 'work/work_screen.dart';
import 'nutrition/nutrition_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Home is default (center)

  final List<ScrollController> _scrollControllers = List.generate(5, (_) => ScrollController());


  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Scroll to top immediately when switching to the tab
    if (_scrollControllers[index].hasClients) {
      _scrollControllers[index].jumpTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Screen content
          IndexedStack(
            index: _currentIndex,
            children: [
              PrimaryScrollController(controller: _scrollControllers[0], child: const WorkScreen()),
              PrimaryScrollController(controller: _scrollControllers[1], child: const HomeScreen()),
              PrimaryScrollController(controller: _scrollControllers[2], child: const HealthScreen()),
              PrimaryScrollController(controller: _scrollControllers[3], child: const FinanceScreen()),
              PrimaryScrollController(controller: _scrollControllers[4], child: const NutritionScreen()),
            ],
          ),
          // Floating navigation at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiquidNavBar(
              currentIndex: _currentIndex,
              onTap: switchTab,
            ),
          ),
        ],
      ),
    );
  }
}


