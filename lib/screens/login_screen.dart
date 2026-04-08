import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/animated_bottom_sheet.dart';
import 'registration_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
          
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.04),
                
                // Logo
                Text(
                  AppStrings.appName,
                  style: AppTheme.logoStyle,
                ).animate().fadeIn(duration: 600.ms),
                
                SizedBox(height: screenHeight * 0.015),
                
                // Moon
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
                ).animate().fadeIn(duration: 800.ms),
                
                const Spacer(),
                
                // Bottom Sheet
                AnimatedBottomSheet(
                  height: 0.38,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.signIn,
                          style: AppTheme.titleStyle,
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Gmail button
                        DayloOutlinedButton(
                          text: AppStrings.gmail,
                          onPressed: () {
                            // TODO: Implement Gmail sign in
                          },
                        ),
                        
                        const SizedBox(height: 14),
                        
                        // Apple button
                        DayloOutlinedButton(
                          text: AppStrings.apple,
                          onPressed: () {
                            // TODO: Implement Apple sign in
                          },
                        ),
                        
                        const SizedBox(height: 22),
                        
                        // Create account button
                        DayloFilledButton(
                          text: AppStrings.createAccount,
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => 
                                  const RegistrationScreen(),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
