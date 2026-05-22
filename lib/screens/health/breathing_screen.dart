import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/user_provider.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _pulseAnimation;
  
  String _instruction = "Приготовьтесь";
  String _phase = "ready"; // ready, inhale, hold, exhale
  bool _isPlaying = false;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOutSine,
    );
  }

  void _startBreathing() {
    setState(() {
      _isPlaying = true;
      _phase = "inhale";
      _instruction = "Вдох";
    });
    _runBreathingCycle();
  }

  void _stopBreathing() {
    _phaseTimer?.cancel();
    _breathingController.stop();
    _breathingController.animateTo(0, duration: 1.seconds, curve: Curves.easeOut);
    if (_isPlaying && mounted) {
      context.read<UserProvider>().completeDailyTask('breathing');
    }
    setState(() {
      _isPlaying = false;
      _phase = "ready";
      _instruction = "Приготовьтесь";
    });
  }

  void _runBreathingCycle() {
    if (!mounted || !_isPlaying) return;

    // Phase: INHALE
    setState(() {
      _phase = "inhale";
      _instruction = "Вдох";
    });
    _breathingController.duration = const Duration(seconds: 4);
    _breathingController.forward();

    _phaseTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted || !_isPlaying) return;
      
      // Phase: HOLD
      setState(() {
        _phase = "hold";
        _instruction = "Задержите";
      });
      
      _phaseTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted || !_isPlaying) return;
        
        // Phase: EXHALE
        setState(() {
          _phase = "exhale";
          _instruction = "Выдох";
        });
        _breathingController.duration = const Duration(seconds: 4);
        _breathingController.reverse();
        
        _phaseTimer = Timer(const Duration(seconds: 4), () {
          if (!mounted || !_isPlaying) return;
          
          // Phase: HOLD (bottom)
          setState(() {
            _phase = "hold_bottom";
            _instruction = "Задержите";
          });
          
          _phaseTimer = Timer(const Duration(seconds: 2), _runBreathingCycle);
        });
      });
    });
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned.fill(
            child: AnimatedContainer(
              duration: 2.seconds,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    _getPhaseColor().withValues(alpha: 0.15),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      ),
                      Text(
                        'Дыхание',
                        style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(width: 48), // Spacer for centering title
                    ],
                  ),
                ),

                const Spacer(),

                // Animated Circle
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final size = 200 + (_pulseAnimation.value * 120);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow layers
                          _buildGlowLayer(size * 1.4, 0.1, _getPhaseColor()),
                          _buildGlowLayer(size * 1.2, 0.2, _getPhaseColor()),
                          
                          // Main breathing circle
                          Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getPhaseColor().withValues(alpha: 0.8),
                                  _getPhaseColor().withValues(alpha: 0.4),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getPhaseColor().withValues(alpha: 0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _instruction,
                                style: AppTheme.titleStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    const Shadow(color: Colors.black45, blurRadius: 10),
                                  ],
                                ),
                              ).animate(target: _isPlaying ? 1 : 0).fadeIn(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Spacer(),

                // Subtitle
                Text(
                  _isPlaying ? "Следите за кругом" : "Успокойте свой разум",
                  style: AppTheme.bodyStyle.copyWith(color: AppTheme.white38),
                ).animate(target: _isPlaying ? 1 : 0).fadeIn(),

                const SizedBox(height: 40),

                // Control Button
                GestureDetector(
                  onTap: _isPlaying ? _stopBreathing : _startBreathing,
                  child: AnimatedContainer(
                    duration: 400.ms,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                    decoration: BoxDecoration(
                      color: _isPlaying ? Colors.transparent : Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      boxShadow: _isPlaying 
                        ? [] 
                        : [BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Text(
                      _isPlaying ? 'Закончить' : 'Начать',
                      style: AppTheme.titleStyle.copyWith(
                        color: _isPlaying ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowLayer(double size, double opacity, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut);
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case "inhale": return AppTheme.accentBlue;
      case "hold": return Colors.cyanAccent;
      case "exhale": return Colors.tealAccent;
      case "hold_bottom": return AppTheme.accentIndigo;
      default: return AppTheme.accentBlue;
    }
  }
}
