import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../widgets/custom_button.dart';
// import 'auth/login_screen.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient overlay for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.04),
                  
                  // Logo
                  Text(
                    AppStrings.appName,
                    style: AppTheme.logoStyle,
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3, end: 0),
                  
                  SizedBox(height: screenHeight * 0.015),
                  
                  // Moon glow effect
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.95),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.4),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 1000.ms, delay: 300.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  
                  const Spacer(),
                  
                  // Welcome text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.welcomeTitle,
                      style: AppTheme.headlineStyle.copyWith(
                        fontSize: screenHeight * 0.038,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideX(begin: -0.2, end: 0),
                  ),
                  
                  SizedBox(height: screenHeight * 0.04),
                  
                  // Button
                  DayloLightButton(
                    text: AppStrings.improveSelf,
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => 
                            const MainScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: bottomPadding + 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
