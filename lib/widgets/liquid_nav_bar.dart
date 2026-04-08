import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

class LiquidNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LiquidNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<LiquidNavBar> createState() => _LiquidNavBarState();
}

class _LiquidNavBarState extends State<LiquidNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Position of the slider (0.0 to 4.0)
  // We use this to drive the UI. When animating, it matches controller.value.
  // When dragging, it tracks the finger.
  double _currentPosition = 0.0;
  
  bool _isDragging = false;

  double _lastValue = 0.0;
  double _velocity = 0.0;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentIndex.toDouble();
    _lastValue = _currentPosition;

    // Use unbounded to allow values 0 to N
    _controller = AnimationController.unbounded(
      vsync: this, 
      duration: const Duration(milliseconds: 600)
    );
    _controller.addListener(_updatePosition);
    _controller.value = _currentPosition;
  }

  void _updatePosition() {
    // Calculate instantaneous velocity for squash effect
    double delta = (_controller.value - _lastValue).abs();
    _velocity = delta; 
    _lastValue = _controller.value;

    if (!_isDragging) {
      setState(() {
        _currentPosition = _controller.value;
      });
    } else {
      // Even if dragging, we want to update velocity state for stretch
      // but _currentPosition is driven by gesture
    }
  }

  @override
  void didUpdateWidget(LiquidNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex && !_isDragging) {
      _animateTo(widget.currentIndex.toDouble());
    }
  }

  void _animateTo(double target) {
    final simulation = SpringSimulation(
      const SpringDescription(mass: 0.8, stiffness: 180, damping: 14),
      _currentPosition, // Start from current visual position
      target,
      0, // velocity (could track drag velocity for better physics)
    );

    _controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive width, max 340
            final double pillWidth = (constraints.maxWidth - 32).clamp(280.0, 340.0);
            final int itemCount = 5;
            final double itemWidth = pillWidth / itemCount; 

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: pillWidth,
              height: 76,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Ambilight Glow (Optimized with RepaintBoundary)
                  Positioned(
                    top: 15,
                    child: RepaintBoundary(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: pillWidth - 30,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                             BoxShadow(
                               color: _getInterpolatedColor(_currentPosition).withValues(alpha: 0.4),
                               blurRadius: 50,
                               offset: const Offset(0, 10)
                             ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Glass Base (Static)
                  RepaintBoundary(
                    child: _buildGlassLayer(pillWidth),
                  ),

                  // 3. Liquid Slider
                  _buildLiquidLayer(pillWidth, itemWidth),

                  // 4. Interactive Icons Layer
                  _buildGestureLayer(pillWidth, itemWidth),
                ],
              ),
            );
          }
        ));
  }

  Widget _buildLiquidLayer(double pillWidth, double itemWidth) {
      // Determine display position
      double displayPos = _currentPosition.clamp(0.0, 4.0);

      // Liquid Physics Logic
      // 1. Minimum width base
      double baseWidth = 55;
      
      // 2. Velocity stretch (Squash & Stretch principle)
      // When moving fast, it stretches wide and gets shorter
      double velocityStretch = (_velocity * 30).clamp(0.0, 40.0); // Amplified effect
      
      // 3. Dragging stretch (Elastic tension)
      double dragStretch = _isDragging ? 15.0 : 0.0;

      double totalWidth = baseWidth + velocityStretch + dragStretch;
      
      // Inverse height to maintain "volume" illusion (squash)
      // As width increases, height decreases slightly
      double heightSquash = (velocityStretch * 0.4).clamp(0.0, 15.0);
      double totalHeight = 55 - heightSquash;

      final double leftOffset = (displayPos * itemWidth) + (itemWidth - totalWidth) / 2;

      return Positioned(
        left: leftOffset,
        child: _LiquidDroplet(
          width: totalWidth,
          height: totalHeight,
          color: Colors.white.withValues(alpha: 0.15),
          glowColor: _getInterpolatedColor(_currentPosition),
        ),
      );
  }

  Widget _buildGestureLayer(double pillWidth, double itemWidth) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        // Stop animation if running
        _controller.stop();
        setState(() {
          _isDragging = true;
          HapticFeedback.lightImpact();
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          double deltaUnits = details.primaryDelta! / itemWidth;
          _currentPosition += deltaUnits;
          // Elastic bounds
          if (_currentPosition < -0.2) _currentPosition = -0.2;
          if (_currentPosition > 4.2) _currentPosition = 4.2;
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          _isDragging = false;
          int targetIndex = _currentPosition.round().clamp(0, 4);
          _animateTo(targetIndex.toDouble());
          widget.onTap(targetIndex);
          HapticFeedback.selectionClick();
        });
      },
      onTapUp: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPos = box.globalToLocal(details.globalPosition);
          // Center-based hit testing for accuracy
          double rawIndex = (localPos.dx / itemWidth);
          int index = rawIndex.floor().clamp(0, 4);
          
          _animateTo(index.toDouble());
           widget.onTap(index);
           HapticFeedback.selectionClick();
      },
      child: Container(
        color: Colors.transparent, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: itemWidth, child: _LiquidNavItem(icon: Icons.calendar_today_rounded, index: 0, currentPos: _currentPosition)),
            SizedBox(width: itemWidth, child: _LiquidNavItem(icon: Icons.home_rounded, index: 1, currentPos: _currentPosition)),
            SizedBox(width: itemWidth, child: _LiquidNavItem(icon: Icons.favorite_rounded, index: 2, currentPos: _currentPosition)),
            SizedBox(width: itemWidth, child: _LiquidNavItem(icon: Icons.account_balance_wallet_rounded, index: 3, currentPos: _currentPosition)),
            SizedBox(width: itemWidth, child: _LiquidNavItem(icon: Icons.bar_chart_rounded, index: 4, currentPos: _currentPosition)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassLayer(double width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161618).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Color _getInterpolatedColor(double position) {
      // Smoothly mix colors based on fractional position
      final colors = [
        Colors.orange,      // 0 Work
        Colors.blue,        // 1 Home
        Colors.pinkAccent,  // 2 Health
        Colors.teal,        // 3 Finance
        Colors.green        // 4 Nutrition
      ];
      
      int index1 = position.floor().clamp(0, 4);
      int index2 = (index1 + 1).clamp(0, 4);
      double t = (position - index1).clamp(0.0, 1.0);
      
      return Color.lerp(colors[index1], colors[index2], t)!;
  }
}

class _LiquidNavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final double currentPos;

  const _LiquidNavItem({required this.icon, required this.index, required this.currentPos});

  @override
  Widget build(BuildContext context) {
    double dist = (currentPos - index).abs();
    double activeFactor = (1.0 - dist).clamp(0.0, 1.0);
    
    // Non-linear interaction curve
    activeFactor = Curves.easeOut.transform(activeFactor);

    Color iconColor = Color.lerp(
        Colors.white.withValues(alpha: 0.4), 
        Colors.white, 
        activeFactor
    )!;
    
    double scale = 1.0 + (0.2 * activeFactor);

    return SizedBox(
      width: 60, // Fixed touch target width approx
      height: 76,
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: Icon(icon, color: iconColor, size: 24),
        ),
      ),
    );
  }
}

class _LiquidDroplet extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Color glowColor;

  const _LiquidDroplet({required this.width, required this.height, required this.color, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // The liquid "droplet" shape - we use a rounded rect with variable width
        // For a true metaball effect we'd need custom painter, but a soft rounded capsule works for "iOS 26" clean style
        borderRadius: BorderRadius.circular(30),
        color: color,
        boxShadow: [
          // Inner glow
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(-2, -2)
          ),
          // Colored ambient glow
          BoxShadow(
             color: glowColor.withValues(alpha: 0.4),
             blurRadius: 20,
             spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5
        )
      ),
      child: Center(
        child: Container(
          width: 4, 
          height: 4, 
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle
          )
        ), // Center dot highlight
      ),
    );
  }
}
