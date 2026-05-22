import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../core/providers/user_provider.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Wallpaper
          Positioned.fill(
            child: Image.asset(
              context.watch<UserProvider>().wallpaperPath,
              fit: BoxFit.cover,
            ),
          ),

          // Cinematic gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x30000000),
                    Color(0x08000000),
                    Color(0x00000000),
                    Color(0xA0000000),
                    Color(0xE5080810),
                  ],
                  stops: [0.0, 0.15, 0.4, 0.72, 1.0],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.04),

                  // Logo row
                  Row(
                    children: [
                      // Logo glyph — glowing moon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.92),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.45),
                              blurRadius: 22,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ).animate()
                          .fadeIn(duration: 800.ms)
                          .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1)),

                      const SizedBox(width: 12),

                      Text(
                        AppStrings.appName,
                        style: AppTheme.logoStyle,
                      ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.15, end: 0),
                    ],
                  ),

                  const Spacer(),

                  // Main headline
                  Text(
                    AppStrings.welcomeTitle,
                    style: AppTheme.headlineStyle.copyWith(
                      fontSize: size.height * 0.042,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.12, end: 0),

                  const SizedBox(height: 12),

                  Text(
                    'Отслеживай здоровье, финансы и\nпривычки в одном месте',
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 15,
                      color: AppTheme.white70,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 450.ms),

                  SizedBox(height: size.height * 0.05),

                  // CTA Button
                  _GlassButton(
                    text: AppStrings.improveSelf,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const MainScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 450),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.1, end: 0),

                  SizedBox(height: bottom + 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _GlassButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: AppTheme.buttonTextStyle.copyWith(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: AppTheme.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
