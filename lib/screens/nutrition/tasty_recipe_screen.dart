import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/data/recipe_database.dart';
import '../../core/theme/app_theme.dart';

class TastyRecipeScreen extends StatefulWidget {
  final RecipeData recipe;

  const TastyRecipeScreen({super.key, required this.recipe});

  @override
  State<TastyRecipeScreen> createState() => _TastyRecipeScreenState();
}

class _TastyRecipeScreenState extends State<TastyRecipeScreen> {
  VideoPlayerController? _videoController;
  late ScrollController _scrollController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    if (widget.recipe.videoUrl != null) {
      if (widget.recipe.videoUrl!.startsWith('assets/') || widget.recipe.videoUrl!.startsWith('/')) {
        _videoController = VideoPlayerController.asset(widget.recipe.videoUrl!)
          ..initialize().then((_) {
            setState(() => _isVideoInitialized = true);
            _videoController!.setLooping(true);
            _videoController!.setVolume(0);
            _videoController!.play();
          });
      } else {
        if (widget.recipe.videoUrl!.contains('youtube.com') || widget.recipe.videoUrl!.contains('youtu.be')) {
          debugPrint('Skipping native video player for YouTube URL: ${widget.recipe.videoUrl}');
        } else {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.recipe.videoUrl!))
            ..initialize().then((_) {
              setState(() => _isVideoInitialized = true);
              _videoController!.setLooping(true);
              _videoController!.setVolume(0);
              _videoController!.play();
            }).catchError((e) {
              debugPrint('Error initializing video: $e');
            });
        }
      }
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.6,
                pinned: true,
                stretch: true,
                backgroundColor: AppTheme.primaryDark,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.recipe.videoUrl != null && _isVideoInitialized)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      else if (widget.recipe.videoThumbnail != null)
                        Hero(
                          tag: 'recipe_${widget.recipe.name}',
                          child: widget.recipe.videoThumbnail!.startsWith('http')
                              ? Image.network(widget.recipe.videoThumbnail!, fit: BoxFit.cover)
                              : Image.asset(widget.recipe.videoThumbnail!, fit: BoxFit.cover),
                        )
                      else
                        Hero(
                          tag: 'recipe_${widget.recipe.name}',
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1E1E30), AppTheme.primaryDark],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, color: Colors.white),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppTheme.white38,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.recipe.name,
                                style: AppTheme.headlineStyle.copyWith(fontSize: 32, height: 1.1),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildInfoChip(Icons.schedule, '${widget.recipe.cookTime} мин'),
                                  const SizedBox(width: 12),
                                  _buildInfoChip(Icons.local_fire_department, '${widget.recipe.calories.toInt()} ккал'),
                                  const SizedBox(width: 12),
                                  _buildInfoChip(Icons.restaurant, _getDifficulty(widget.recipe.cookTime)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.white08,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.white12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildNutrient('Белки', widget.recipe.proteins, AppTheme.errorRed),
                                _buildNutrient('Жиры', widget.recipe.fats, AppTheme.accentGold),
                                _buildNutrient('Углеводы', widget.recipe.carbs, AppTheme.accentBlue),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ингредиенты', style: AppTheme.headlineStyle.copyWith(fontSize: 22)),
                              const SizedBox(height: 16),
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: widget.recipe.ingredients.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGreen.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppTheme.accentGreen, width: 1.5),
                                        ),
                                        child: const Icon(Icons.check, size: 14, color: AppTheme.accentGreen),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          widget.recipe.ingredients[index],
                                          style: AppTheme.bodyStyle.copyWith(color: AppTheme.white, fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text('Приготовление', style: AppTheme.headlineStyle.copyWith(fontSize: 22)),
                        ),

                        const SizedBox(height: 16),

                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: widget.recipe.steps.length,
                          itemBuilder: (context, index) {
                            final hasImage = widget.recipe.stepImages.length > index;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Шаг ${index + 1}',
                                        style: AppTheme.captionStyle.copyWith(
                                          color: AppTheme.accentGreen,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.recipe.steps[index],
                                    style: AppTheme.bodyStyle.copyWith(
                                      color: AppTheme.white,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                  if (hasImage) ...[
                                    const SizedBox(height: 16),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        widget.recipe.stepImages[index],
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGreen.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Начать готовить',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.white08,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrient(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          '${value.toInt()}г',
          style: AppTheme.headlineStyle.copyWith(fontSize: 20, color: AppTheme.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _getDifficulty(int minutes) {
    if (minutes <= 20) return 'Легко';
    if (minutes <= 45) return 'Средне';
    return 'Сложно';
  }
}
