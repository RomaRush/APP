import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../core/providers/user_provider.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Пожалуйста, заполните все поля';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<UserProvider>().login(email, password);
      // Rebuild in AuthWrapper will auto navigate to MainScreen
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      resizeToAvoidBottomInset: false,
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
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.08),

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

                        // Login Form Title
                        Text(
                          AppStrings.signIn,
                          style: AppTheme.headlineStyle.copyWith(fontSize: 32),
                        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 8),

                        Text(
                          'Войдите в свой онлайн-аккаунт',
                          style: AppTheme.bodyStyle.copyWith(color: AppTheme.white54),
                        ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

                        const SizedBox(height: 36),

                        // Inputs
                        _LoginField(
                          controller: _emailController,
                          label: 'Email / Логин',
                          icon: Icons.email_outlined,
                        ).animate().fadeIn(duration: 600.ms, delay: 350.ms).slideX(begin: -0.05, end: 0),

                        const SizedBox(height: 16),

                        _LoginField(
                          controller: _passwordController,
                          label: 'Пароль',
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.05, end: 0),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
                          ).animate().fadeIn(),
                        ],

                        const SizedBox(height: 32),

                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.white,
                              foregroundColor: AppTheme.primaryDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryDark),
                                  )
                                : const Text('Войти', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 450.ms).slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 24),

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
                        ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

                        SizedBox(height: bottom + 40),
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

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  const _LoginField({required this.controller, required this.label, required this.icon, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.white08,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.white12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.white38, size: 20),
              labelText: label,
              labelStyle: AppTheme.captionStyle.copyWith(color: AppTheme.white38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
