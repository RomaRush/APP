import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../core/providers/user_provider.dart';
import 'main_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
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
                    Color(0x40000000),
                    Color(0x10000000),
                    Color(0xFF080810),
                  ],
                  stops: [0.0, 0.3, 0.8],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ).animate().fadeIn(duration: 400.ms),
                  
                  SizedBox(height: size.height * 0.03),
                  
                  Text(
                    AppStrings.registration,
                    style: AppTheme.headlineStyle.copyWith(fontSize: 32),
                  ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Создайте аккаунт, чтобы начать',
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.white54),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                  
                  const SizedBox(height: 40),
                  
                  // Form
                  _RegisterField(
                    controller: _emailController,
                    label: AppStrings.email,
                    icon: Icons.email_outlined,
                  ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(begin: -0.05, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  _RegisterField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.05, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  _RegisterField(
                    controller: _confirmController,
                    label: AppStrings.confirmPassword,
                    icon: Icons.lock_reset_rounded,
                    obscure: true,
                  ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideX(begin: -0.05, end: 0),
                  
                  const Spacer(),
                  
                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.white,
                        foregroundColor: AppTheme.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryDark))
                          : Text(AppStrings.createAccount, style: AppTheme.buttonTextStyle),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2, end: 0),
                  
                  SizedBox(height: bottom + 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  const _RegisterField({required this.controller, required this.label, required this.icon, this.obscure = false});

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
