import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StoryDaysWidget extends StatelessWidget {
  final int filledCount;
  final File? lastPhoto;
  final VoidCallback? onAddTap;
  final VoidCallback? onAvatarTap;

  const StoryDaysWidget({
    super.key,
    this.filledCount = 0,
    this.lastPhoto,
    this.onAddTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    const totalSegments = 12;
    // Highlight green if all segments valid (though typically filledCount <= 12)
    final bool isComplete = filledCount >= totalSegments;
    final Color progressColor = isComplete 
        ? const Color(0xFF4CAF50) 
        : AppTheme.white;

    return Row(
      children: [
        // Avatar with segmented progress
        SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Segmented Progress Ring
              CustomPaint(
                size: const Size(58, 58),
                painter: _SegmentedRingPainter(
                  segmentCount: totalSegments,
                  filledCount: filledCount,
                  color: progressColor,
                  backgroundColor: AppTheme.white.withValues(alpha: 0.2),
                ),
              ),
              
              // Avatar Circle
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.darkGray,
                    border: Border.all(color: AppTheme.white, width: 2),
                    image: lastPhoto != null
                        ? DecorationImage(
                            image: FileImage(lastPhoto!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/images/user_avatar.png'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              
              // Plus Button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.white,
                      border: Border.all(color: AppTheme.lightGray, width: 1.5),
                    ),
                    child: const Icon(Icons.add, size: 16, color: AppTheme.black),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Label
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Сторидей',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (filledCount > 0 && filledCount < 12)
              Text(
                '${12 - filledCount} осталось',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SegmentedRingPainter extends CustomPainter {
  final int segmentCount;
  final int filledCount;
  final Color color;
  final Color backgroundColor;

  _SegmentedRingPainter({
    required this.segmentCount,
    required this.filledCount,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;
    const strokeWidth = 2.5;
    const gapAngle = 0.1; // Space between segments in radians

    final segmentAngle = (2 * 3.14159 - (segmentCount * gapAngle)) / segmentCount;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from top (-90 degrees)
    double currentAngle = -3.14159 / 2;

    for (int i = 0; i < segmentCount; i++) {
      paint.color = i < filledCount ? color : backgroundColor;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        segmentAngle,
        false,
        paint,
      );
      
      currentAngle += segmentAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedRingPainter oldDelegate) {
    return oldDelegate.filledCount != filledCount ||
           oldDelegate.color != color;
  }
}
