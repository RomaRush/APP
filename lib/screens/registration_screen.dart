import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/animated_bottom_sheet.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _passwordsMatch = true;
  bool _showPasswordError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    setState(() {
      if (confirmPassword.isNotEmpty) {
        _passwordsMatch = password == confirmPassword;
        _showPasswordError = !_passwordsMatch;
      } else {
        _showPasswordError = false;
      }
    });
  }

  void _onCreateAccount() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (password.isEmpty || confirmPassword.isEmpty) {
      return;
    }
    
    if (password != confirmPassword) {
      setState(() {
        _showPasswordError = true;
        _passwordsMatch = false;
      });
      return;
    }
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const EmailVerificationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.1),
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
                  height: 0.55,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.registration,
                            style: AppTheme.titleStyle,
                          ),
                          
                          const SizedBox(height: 28),
                          
                          // Email field
                          DayloTextField(
                            label: AppStrings.email,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          
                          const SizedBox(height: 18),
                          
                          // Password field
                          DayloTextField(
                            label: AppStrings.password,
                            controller: _passwordController,
                            obscureText: true,
                            onChanged: (_) => _validatePasswords(),
                          ),
                          
                          const SizedBox(height: 18),
                          
                          // Confirm password field with validation
                          DayloTextField(
                            label: AppStrings.confirmPassword,
                            controller: _confirmPasswordController,
                            obscureText: true,
                            onChanged: (_) => _validatePasswords(),
                            showError: _showPasswordError,
                            errorText: AppStrings.passwordsDoNotMatch,
                          ),
                          
                          const SizedBox(height: 28),
                          
                          // Create account button
                          DayloOutlinedButton(
                            text: AppStrings.createAccount,
                            onPressed: _onCreateAccount,
                          ),
                          
                          const SizedBox(height: 14),
                          
                          // Sign in button
                          DayloFilledButton(
                            text: AppStrings.signInToAccount,
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => 
                                    const LoginScreen(),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
