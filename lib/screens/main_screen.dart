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
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Home is default (center)

  final List<Widget> _screens = [
    const WorkScreen(),
    const HomeScreen(),
    const HealthScreen(),
    const FinanceScreen(),
    const NutritionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Screen content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Floating navigation at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiquidNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
