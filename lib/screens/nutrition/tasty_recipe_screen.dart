import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/data/recipe_database.dart';
import '../../core/providers/nutrition_provider.dart';
import 'package:provider/provider.dart';

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
    
    // Initialize video if present
    if (widget.recipe.videoUrl != null) {
      if (widget.recipe.videoUrl!.startsWith('assets/') || widget.recipe.videoUrl!.startsWith('/')) {
        // Local Asset
        _videoController = VideoPlayerController.asset(widget.recipe.videoUrl!)
          ..initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController!.setLooping(true);
            _videoController!.setVolume(0);
            _videoController!.play();
          });
      } else {
        // Network URL
        // Simple check: play only if it looks like a file or is safe.
        // YouTube URLs from TheMealDB cannot be played by VideoPlayerController directly.
        // We will skip initialization for YouTube URLs and just show thumbnail + link button
        if (widget.recipe.videoUrl!.contains('youtube.com') || widget.recipe.videoUrl!.contains('youtu.be')) {
             print('Skipping native video player for YouTube URL: ${widget.recipe.videoUrl}');
             // Do not initialize _videoController
        } else {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.recipe.videoUrl!))
            ..initialize().then((_) {
              setState(() {
                _isVideoInitialized = true;
              });
              _videoController!.setLooping(true);
              _videoController!.setVolume(0);
              _videoController!.play();
            }).catchError((e) {
               print('Error initializing video: $e');
            });
        }
      }
    }
    
    // Set system overlay style for immersive feel
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
      backgroundColor: Colors.black, // Dark background for media focus
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Video Header
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.6, // Tall header for video
                pinned: true,
                stretch: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video or Thumbnail
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
                        widget.recipe.videoThumbnail!.startsWith('http')
                        ? Image.network(
                            widget.recipe.videoThumbnail!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            widget.recipe.videoThumbnail!,
                            fit: BoxFit.cover,
                          )
                      else
                         // Fallback gradient if no media
                         Container(
                           decoration: const BoxDecoration(
                             gradient: LinearGradient(
                               colors: [Color(0xFF1B3D2F), Colors.black],
                               begin: Alignment.topCenter,
                               end: Alignment.bottomCenter,
                             ),
                           ),
                         ),
                         
                      // Gradient Overlay for text readability
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

              // 2. Recipe Content (overlapping sliver)
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20), // Pull up to overlap video
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B3D2F), // Dark green theme
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      
                      // Title & Time sections
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.recipe.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
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
                      
                      // Nutrients Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildNutrient('Белки', widget.recipe.proteins, Colors.redAccent),
                              _buildNutrient('Жиры', widget.recipe.fats, Colors.amber),
                              _buildNutrient('Углеводы', widget.recipe.carbs, Colors.blueAccent),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Ingredients List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ингредиенты',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
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
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                                      ),
                                      child: const Icon(Icons.check, size: 14, color: Color(0xFF4CAF50)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        widget.recipe.ingredients[index],
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
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
                      
                      // Steps List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Text(
                          'Приготовление',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: widget.recipe.steps.length,
                        itemBuilder: (context, index) {
                          // Check if we have an image for this step
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
                                      style: const TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.recipe.steps[index],
                                  style: const TextStyle(
                                    color: Colors.white,
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
                                ]
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 100), // Bottom padding for sticky button
                    ],
                  ),
                ),
              ),
            ),
            ],
          ),
          
          // Sticky "Start Cooking" Button
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
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
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
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
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
