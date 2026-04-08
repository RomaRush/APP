import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class TipCardData {
  final String title;
  final String imagePath;
  final String articleContent;

  TipCardData({
    required this.title,
    required this.imagePath,
    required this.articleContent,
  });
}

class TipsSection extends StatelessWidget {
  final List<TipCardData> tips;
  final Function(TipCardData) onTipTap;

  const TipsSection({
    super.key,
    required this.tips,
    required this.onTipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Советы дня',
            style: AppTheme.titleStyle.copyWith(
              color: AppTheme.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final tip = tips[index];
              return _TipCardWidget(
                tip: tip,
                onTap: () => onTipTap(tip),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TipCardWidget extends StatelessWidget {
  final TipCardData tip;
  final VoidCallback onTap;

  const _TipCardWidget({
    required this.tip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.mediumGray,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.asset(
              tip.imagePath,
              fit: BoxFit.cover,
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            
            // Title
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                tip.title,
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
