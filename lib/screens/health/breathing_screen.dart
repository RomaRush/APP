import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  String _instruction = "Вдох...";
  Timer? _timer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/images/recipes/0131.mov');
    
    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.setVolume(0); // Mute video
      setState(() => _isVideoInitialized = true);
    } catch (e) {
      debugPrint('Video initialization error: $e');
    }
  }

  void _startBreathing() {
    if (!_isVideoInitialized) return;
    
    setState(() => _isPlaying = true);
    _videoController.play();
    _runInhale();
  }

  void _stopBreathing() {
    _timer?.cancel();
    _videoController.pause();
    _videoController.seekTo(Duration.zero);
    setState(() {
      _isPlaying = false;
      _instruction = "Вдох...";
    });
  }

  void _runInhale() {
    if (!mounted || !_isPlaying) return;
    setState(() => _instruction = "Вдох...");
    _timer = Timer(const Duration(seconds: 4), _runHold);
  }

  void _runHold() {
    if (!mounted || !_isPlaying) return;
    setState(() => _instruction = "Задержите");
    _timer = Timer(const Duration(seconds: 2), _runExhale);
  }

  void _runExhale() {
    if (!mounted || !_isPlaying) return;
    setState(() => _instruction = "Выдох...");
    _timer = Timer(const Duration(seconds: 4), _runInhale);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Дыхание', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Video container
            Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _isVideoInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          // Video
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController.value.size.width,
                                height: _videoController.value.size.height,
                                child: VideoPlayer(_videoController),
                              ),
                            ),
                          ),
                          // Instruction text overlay
                          if (_isPlaying)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _instruction,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.cyan),
                      ),
              ),
            ),
            const Spacer(),
            
            // Control button
            GestureDetector(
              onTap: _isPlaying ? _stopBreathing : _startBreathing,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isPlaying 
                        ? [Colors.red.shade400, Colors.red.shade700]
                        : [Colors.cyan.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: (_isPlaying ? Colors.red : Colors.cyan).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  _isPlaying ? 'Остановить' : 'Начать',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Text(
              _isPlaying ? "Дышите глубоко" : "Нажмите для начала",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
