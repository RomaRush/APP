import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ArticleContentType { text, image, recipeStep }

class ArticleBlock {
  final ArticleContentType type;
  final String content; // Text or Image path
  final String? title; // For steps or headers

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
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.darkGray,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                headerImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple Gradient
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.article, color: Colors.white54, size: 64),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.headlineStyle.copyWith(
                      color: AppTheme.black,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...blocks.map((block) => _buildBlock(block)),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(ArticleBlock block) {
    switch (block.type) {
      case ArticleContentType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            block.content,
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.darkGray,
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      case ArticleContentType.image:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              block.content,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                 return Container(
                   height: 200,
                   decoration: BoxDecoration(
                     color: Colors.grey[200],
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: const Center(
                     child: Icon(Icons.image_not_supported, color: Colors.grey),
                   ),
                 );
              },
            ),
          ),
        );
      case ArticleContentType.recipeStep:
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (block.title != null)
                Text(
                  block.title!,
                  style: AppTheme.headlineStyle.copyWith(
                    color: AppTheme.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (block.title != null) const SizedBox(height: 12),
              Text(
                block.content,
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.darkGray,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
    }
  }
}
