import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../core/providers/user_provider.dart';
import 'registration_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Positioned.fill(
            child: Consumer<UserProvider>(
              builder: (context, user, _) => Image.asset(user.wallpaperPath, fit: BoxFit.cover),
            ),
          ),
          
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x50000000),
                    Color(0x10000000),
                    Color(0xFF080810),
                  ],
                  stops: [0.0, 0.4, 0.85],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                
                // Logo & Moon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.white54, blurRadius: 20, spreadRadius: 2)],
                      ),
                    ).animate().scale(duration: 800.ms),
                    const SizedBox(width: 12),
                    Text(AppStrings.appName, style: AppTheme.logoStyle),
                  ],
                ).animate().fadeIn(duration: 600.ms),
                
                const Spacer(),
                
                // Login Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.signIn,
                        style: AppTheme.headlineStyle.copyWith(fontSize: 32),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Добро пожаловать обратно',
                        style: AppTheme.bodyStyle.copyWith(color: AppTheme.white54),
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                      
                      const SizedBox(height: 48),
                      
                      // Social Buttons
                      _SocialButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: AppStrings.gmail,
                        onPressed: () => _navigateToMain(context),
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.1, end: 0),
                      
                      const SizedBox(height: 16),
                      
                      _SocialButton(
                        icon: Icons.apple_rounded,
                        label: AppStrings.apple,
                        onPressed: () => _navigateToMain(context),
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 32),
                      
                      // Registration Link
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const RegistrationScreen(),
                              transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Нет аккаунта? ', style: AppTheme.captionStyle.copyWith(fontSize: 14)),
                              TextSpan(
                                text: AppStrings.createAccount,
                                style: AppTheme.captionStyle.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                      
                      SizedBox(height: bottom + 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMain(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.white08,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.white12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTheme.titleStyle.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
