import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

enum ArticleContentType { text, image, recipeStep }

class ArticleBlock {
  final ArticleContentType type;
  final String content; 
  final String? title; 

  ArticleBlock({
    required this.type,
    required this.content,
    this.title,
  });
}

class ArticleScreen extends StatelessWidget {
  final String title;
  final String headerImage;
  final List<ArticleBlock> blocks;

  const ArticleScreen({
    super.key,
    required this.title,
    required this.headerImage,
    required this.blocks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryDark,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    headerImage,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryDark,
                        ],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.headlineStyle.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  ...blocks.asMap().entries.map((entry) => _buildBlock(entry.value, entry.key)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(ArticleBlock block, int index) {
    Widget content;
    switch (block.type) {
      case ArticleContentType.text:
        content = Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            block.content,
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.white70,
              fontSize: 16,
              height: 1.7,
            ),
          ),
        );
        break;
      case ArticleContentType.image:
        content = Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              block.content,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        );
        break;
      case ArticleContentType.recipeStep:
        content = Container(
          margin: const EdgeInsets.only(bottom: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.white05,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.white08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (block.title != null)
                Text(
                  block.title!,
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
              if (block.title != null) const SizedBox(height: 12),
              Text(
                block.content,
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.white70,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
        break;
    }
    
    return content.animate().fadeIn(duration: 600.ms, delay: (index * 100).ms).slideY(begin: 0.05, end: 0);
  }
}
