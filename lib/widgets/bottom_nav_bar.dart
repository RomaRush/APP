import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../core/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Futuristic pill width logic
    final double pillWidth = 340; 

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
        width: pillWidth,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Ambilight Glow (Soft outer aura)
            Positioned(
              top: 10,
              child: Container(
                width: pillWidth - 40,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.15), // Subtle blue ambiance
                      blurRadius: 50,
                      spreadRadius: -10,
                    ),
                  ],
                ),
              ),
            ),

            // 2. The Glass Pill Structure
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    // Deep semi-transparent dark fill
                    color: const Color(0xFF161618).withValues(alpha: 0.70), 
                    border: Border.all(
                      // Refractive light border (very subtle)
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 0.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top Horizon Glow (Refraction effect)
                      Positioned(
                        top: 0,
                        left: 20,
                        right: 20,
                        height: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.3),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      
                      // Icons Content
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SpringNavItem(
                            icon: Icons.calendar_today_rounded,
                            index: 0,
                            currentIndex: currentIndex,
                            onTap: () => onTap(0),
                          ),
                          _SpringNavItem(
                            icon: Icons.home_rounded,
                            index: 1,
                            currentIndex: currentIndex,
                            onTap: () => onTap(1),
                          ),
                          _SpringNavItem(
                            icon: Icons.favorite_rounded,
                            index: 2,
                            currentIndex: currentIndex,
                            onTap: () => onTap(2),
                          ),
                          _SpringNavItem(
                            icon: Icons.account_balance_wallet_rounded, 
                            index: 3,
                            currentIndex: currentIndex,
                            onTap: () => onTap(3),
                          ),
                          _SpringNavItem(
                            icon: Icons.bar_chart_rounded, 
                            index: 4,
                            currentIndex: currentIndex,
                            onTap: () => onTap(4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpringNavItem extends StatefulWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _SpringNavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_SpringNavItem> createState() => _SpringNavItemState();
}

class _SpringNavItemState extends State<_SpringNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  // Spring simulation for organic feel
  late SpringSimulation _springSimulation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Spring definition: mass=1, stiffness=180, damping=12
    const spring = SpringDescription(mass: 1, stiffness: 180, damping: 12);
    _springSimulation = SpringSimulation(spring, 0, 1, 0);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
  }

  @override
  void didUpdateWidget(_SpringNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex == widget.index && oldWidget.currentIndex != widget.index) {
      // Became active: subtle punch/pop effect
      _controller.forward(from: 0).then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.index == widget.currentIndex;
    
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 55,
        height: 72,
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Apply a small scale impulse when selected
            double scale = 1.0;
            if (_controller.isAnimating) {
              // Simple impulse curve: inactive -> active transition
              // We'll use a simple easeOutBack for simplicity in this constrained context unless using full simulation logic
              // Just reusing controller value for a quick pop: 1.0 -> 1.1 -> 1.0
              if (_controller.value < 0.5) {
                 scale = 1.0 + (_controller.value * 0.2);
              } else {
                 scale = 1.1 - ((_controller.value - 0.5) * 0.2);
              }
            }
            
            return Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: 46,
                height: 46,
                decoration: isActive
                    ? BoxDecoration(
                        color: const Color(0xFF007AFF), // iOS Blue
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF007AFF).withValues(alpha: 0.5),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                          // Inner light source highlight
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: -2,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                      )
                    : const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                child: Icon(
                  widget.icon,
                  color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.45),
                  size: 24,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
