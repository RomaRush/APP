import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/story_entry.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/providers/user_provider.dart';

class StoryViewScreen extends StatefulWidget {
  final List<StoryEntry> stories;
  final int initialIndex;
  final String? userName;
  final String? userAvatar;

  const StoryViewScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.userName,
    this.userAvatar,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _autoAdvanceTimer;
  double _progress = 0.0;
  static const int _autoAdvanceDuration = 5;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _startAutoAdvanceTimer();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    setState(() => _progress = 0.0);

    _autoAdvanceTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.05 / _autoAdvanceDuration;
        if (_progress >= 1.0) {
          _progress = 0.0;
          _goToNextStory();
        }
      });
    });
  }

  void _goToNextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPreviousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _progress = 0.0);
      _startAutoAdvanceTimer();
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _startAutoAdvanceTimer();
  }

  void _onTapDown(TapDownDetails details, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    if (dx < width / 3) {
      _goToPreviousStory();
    } else if (dx > width * 2 / 3) {
      _goToNextStory();
    } else {
      if (_autoAdvanceTimer?.isActive ?? false) {
        _autoAdvanceTimer?.cancel();
      } else {
        _startAutoAdvanceTimer();
      }
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'сейчас';
    if (diff.inMinutes < 60) return '${diff.inMinutes}м';
    if (diff.inHours < 24) return '${diff.inHours}ч';
    return DateFormat('d MMM', 'ru').format(timestamp);
  }

  Future<void> _shareImage() async {
    _autoAdvanceTimer?.cancel();
    final file = widget.stories[_currentIndex].file;
    await Share.shareXFiles([XFile(file.path)], text: 'Моя история из DAYLO');
    _startAutoAdvanceTimer();
  }

  Future<void> _scanQRFromStory() async {
    _autoAdvanceTimer?.cancel();
    final file = widget.stories[_currentIndex].file;
    
    final scanner = MobileScannerController();
    try {
      final BarcodeCapture? capture = await scanner.analyzeImage(file.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        final code = capture.barcodes.first.rawValue;
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              title: const Text('QR-код найден', style: TextStyle(color: Colors.white)),
              content: SelectableText(code ?? 'Пусто', style: const TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть', style: TextStyle(color: AppTheme.accentBlue)),
                ),
                if (code != null && code.startsWith('http'))
                  TextButton(
                    onPressed: () {
                      // Logic to open URL or handle it
                      Navigator.pop(context);
                    },
                    child: const Text('Открыть', style: TextStyle(color: AppTheme.accentGreen)),
                  ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR-код не обнаружен на фото')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сканирования: $e')),
        );
      }
    } finally {
      scanner.dispose();
      _startAutoAdvanceTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Content
            PageView.builder(
              controller: _pageController,
              itemCount: widget.stories.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(widget.stories[index].file, fit: BoxFit.cover),
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black38, Colors.transparent, Colors.transparent, Colors.black45],
                            stops: [0.0, 0.2, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Progress bars
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(widget.stories.length, (index) {
                  double progress = 0.0;
                  if (index < _currentIndex) {
                    progress = 1.0;
                  } else if (index == _currentIndex) {
                    progress = _progress;
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 26, // Positioned right under progress bars
              left: 16,
              right: 8, // Less right padding for the close button
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      image: DecorationImage(
                        image: (widget.userAvatar != null && widget.userAvatar!.isNotEmpty)
                            ? (widget.userAvatar!.startsWith('assets/')
                                ? AssetImage(widget.userAvatar!) as ImageProvider
                                : FileImage(File(widget.userAvatar!)) as ImageProvider)
                            : (context.watch<UserProvider>().avatarPath != null
                                ? FileImage(File(context.read<UserProvider>().avatarPath!)) as ImageProvider
                                : const AssetImage('assets/images/user_avatar.png')),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.userName ?? context.read<UserProvider>().name,
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          shadows: [
                            const Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                      Text(
                        _getTimeAgo(widget.stories[_currentIndex].timestamp),
                        style: AppTheme.captionStyle.copyWith(
                          color: Colors.white70,
                          fontSize: 11,
                          shadows: [
                            const Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _scanQRFromStory,
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                  ),
                  IconButton(
                    onPressed: _shareImage,
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 26),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
