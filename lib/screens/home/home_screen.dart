import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/note.dart';
import '../../core/models/story_entry.dart';
import 'story_view_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/finance_provider.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/nutrition_provider.dart';
import '../../widgets/ai_chat_sheet.dart';
import '../../widgets/minimal_card.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/smart_life_provider.dart';
import '../profile/profile_screen.dart';
import '../../core/providers/notes_provider.dart';
import '../notes/notes_screen.dart';
import '../../core/providers/todo_provider.dart';
import '../todo/todo_screen.dart';
import '../finance/finance_screen.dart';
import '../health/health_screen.dart';
import '../health/mental_health_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../main_screen.dart';
import '../../core/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  List<StoryEntry> _stories = [];
  List<String> _blockOrder = ['checklist', 'balance', 'notes', 'todo', 'sleep', 'status', 'weather', 'ai'];
  bool _isEditing = false;
  bool _showMorningBriefing = true;

  static const Map<String, String> _allBlocks = {
    'balance': 'Баланс',
    'notes': 'Заметки',
    'todo': 'Задачи',
    'sleep': 'Сон',
    'status': 'Ваше состояние',
    'weather': 'Погода',
    'ai': 'AI Ассистент',
    'nutrition': 'Калории дня',
    'water': 'Водный баланс',
    'checklist': 'Ежедневные цели',
    'quick_actions': 'Быстрые действия',
  };

  @override
  void initState() {
    super.initState();
    _loadBlockOrder();
  }

  Future<void> _loadBlockOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('home_block_order');
    if (saved != null && saved.isNotEmpty) {
      List<String> migrated = [];
      for (final key in saved) {
        if (key == 'weather_ai') {
          migrated.addAll(['weather', 'ai']);
        } else if (key == 'sleep_status') {
          migrated.addAll(['sleep', 'status']);
        } else if (_allBlocks.containsKey(key)) {
          migrated.add(key);
        }
      }
      migrated = migrated.toSet().toList();
      if (!migrated.contains('todo')) {
        migrated.insert(2, 'todo');
      }
      if (migrated.isNotEmpty) {
        setState(() => _blockOrder = migrated);
      }
    }
    // Check if morning briefing was dismissed today
    final dismissedDate = prefs.getString('morning_briefing_dismissed_date');
    if (dismissedDate != null) {
      final dismissed = DateTime.tryParse(dismissedDate);
      final today = DateTime.now();
      if (dismissed != null &&
          dismissed.year == today.year &&
          dismissed.month == today.month &&
          dismissed.day == today.day) {
        setState(() => _showMorningBriefing = false);
      } else {
        // New day — show again
        setState(() => _showMorningBriefing = true);
      }
    }
  }

  Future<void> _saveBlockOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('home_block_order', _blockOrder);
  }

  void _removeBlock(String id) {
    setState(() => _blockOrder.remove(id));
    _saveBlockOrder();
  }

  void _showAddBlockDialog() {
    final available = _allBlocks.keys.where((id) => !_blockOrder.contains(id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF13131F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: AppTheme.white12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Добавить блок', style: AppTheme.titleStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            if (available.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('Все блоки уже добавлены', style: AppTheme.captionStyle)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: available.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.white05),
                  itemBuilder: (context, index) {
                    final id = available[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CardIconPill(icon: _getBlockIcon(id), color: _getBlockColor(id)),
                      title: Text(_allBlocks[id]!, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
                      trailing: const Icon(Icons.add_rounded, color: AppTheme.white38),
                      onTap: () {
                        setState(() => _blockOrder.add(id));
                        _saveBlockOrder();
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBlockActions(String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF13131F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: AppTheme.white12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                CardIconPill(icon: _getBlockIcon(id), color: _getBlockColor(id)),
                const SizedBox(width: 12),
                Text(_allBlocks[id]!, style: AppTheme.titleStyle.copyWith(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_rounded, color: AppTheme.errorRed, size: 20),
              ),
              title: Text('Удалить блок', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
              subtitle: Text('Убрать "${_allBlocks[id]!}" с главного экрана', style: AppTheme.captionStyle),
              onTap: () {
                Navigator.pop(ctx);
                _removeBlock(id);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBlockIcon(String id) {
    switch (id) {
      case 'balance': return Icons.account_balance_wallet_rounded;
      case 'notes': return Icons.edit_note_rounded;
      case 'todo': return Icons.checklist_rounded;
      case 'sleep': return Icons.bedtime_rounded;
      case 'status': return Icons.favorite_rounded;
      case 'weather': return Icons.cloud_rounded;
      case 'ai': return Icons.auto_awesome_rounded;
      case 'nutrition': return Icons.restaurant_rounded;
      case 'water': return Icons.water_drop_rounded;
      case 'quick_actions': return Icons.bolt_rounded;
      default: return Icons.widgets_rounded;
    }
  }

  Color _getBlockColor(String id) {
    switch (id) {
      case 'balance': return AppTheme.accentGreen;
      case 'notes': return AppTheme.accentGold;
      case 'todo': return AppTheme.accentBlue;
      case 'sleep': return AppTheme.accentIndigo;
      case 'status': return AppTheme.accentPink;
      case 'weather': return AppTheme.accentBlue;
      case 'ai': return AppTheme.accentPurple;
      case 'nutrition': return AppTheme.accentPink;
      case 'water': return AppTheme.accentBlue;
      case 'quick_actions': return AppTheme.accentGold;
      default: return AppTheme.accentIndigo;
    }
  }

  Future<void> _addStoryPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF13131F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: AppTheme.white12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Добавить историю', style: AppTheme.titleStyle),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickStoryImage(ImageSource.camera);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.white08,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.white12),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: AppTheme.white, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text('Камера', style: AppTheme.captionStyle.copyWith(color: AppTheme.white70)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickStoryImage(ImageSource.gallery);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.white08,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.white12),
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: AppTheme.white, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text('Галерея', style: AppTheme.captionStyle.copyWith(color: AppTheme.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStoryImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        final jFile = File(photo.path);
        final entry = StoryEntry(file: jFile, timestamp: DateTime.now());
        setState(() => _stories.add(entry));
        if (mounted) context.read<UserProvider>().addStoryEntry(entry);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _openStoryViewer() {
    if (_stories.isEmpty) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => StoryViewScreen(stories: _stories),
        opaque: false,
        transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Wallpaper ──
          Positioned.fill(
            child: Consumer<UserProvider>(
              builder: (_, user, __) => Image.asset(
                user.wallpaperPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppTheme.primaryDark),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Главная',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      )),
                                  Text(
                                    DateFormat('d MMMM', 'ru').format(DateTime.now()),
                                    style: AppTheme.captionStyle.copyWith(color: AppTheme.white54),
                                  ),
                                ],
                              ),
                            ),
                            if (_isEditing)
                              GestureDetector(
                                onTap: () => setState(() => _isEditing = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentIndigo,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('Готово', style: AppTheme.buttonTextStyleWhite.copyWith(fontSize: 14)),
                                ),
                              )
                            else ...[
                              GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.edit, color: Colors.white70, size: 22),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
                                child: Consumer<UserProvider>(
                                  builder: (_, user, __) => Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppTheme.white12, width: 2),
                                      image: user.avatarPath != null
                                          ? DecorationImage(
                                              image: FileImage(File(user.avatarPath!)),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: user.avatarPath == null
                                        ? const Icon(Icons.person, color: AppTheme.white54, size: 22)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Утренний брифинг ──
                        if (_showMorningBriefing)
                          Consumer<SmartLifeProvider>(
                            builder: (_, smart, __) => Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF5C4B9E), Color(0xFF7B5EA7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('☀️', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Text('Утренний брифинг',
                                          style: AppTheme.titleStyle
                                              .copyWith(fontSize: 16, color: Colors.white)),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () async {
                                          setState(() => _showMorningBriefing = false);
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.setString(
                                            'morning_briefing_dismissed_date',
                                            DateTime.now().toIso8601String(),
                                          );
                                        },
                                        child: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(smart.dailyBudgetAdvice,
                                      style: AppTheme.bodyStyle
                                          .copyWith(color: Colors.white70, fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Заряд сил: ${smart.bodyBattery}%',
                                    style: AppTheme.bodyStyle.copyWith(
                                      color: const Color(0xFF4CFFB0),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (ctx) => Container(
                                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF13131F),
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Container(
                                                  width: 36, height: 4,
                                                  margin: const EdgeInsets.only(bottom: 24),
                                                  decoration: BoxDecoration(color: AppTheme.white12, borderRadius: BorderRadius.circular(2)),
                                                ),
                                              ),
                                              Text('Как высчитывается заряд сил', style: AppTheme.titleStyle.copyWith(fontSize: 20)),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Ваш "Заряд сил" рассчитывается на основе качества и продолжительности сна, вашей активности за предыдущий день и текущего эмоционального состояния.',
                                                style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70, height: 1.5),
                                              ),
                                              const SizedBox(height: 24),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppTheme.accentIndigo,
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  onPressed: () => Navigator.pop(ctx),
                                                  child: Text('Понятно', style: AppTheme.buttonTextStyleWhite),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '(как оно высчитывается)',
                                      style: AppTheme.captionStyle.copyWith(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 400.ms),
                          ),
                        if (_showMorningBriefing) const SizedBox(height: 16),
                        // ── Сторидей (Instagram style) ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context).get('story_days'), style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: const Color(0xFF13131F),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    title: Text('Сторидей', style: AppTheme.titleStyle),
                                    content: Text('Один кружочек — это один час вашего активного дня. Заполняйте 12 историй ежедневно, чтобы запечатлеть самые важные моменты и не упустить ни одной детали вашего дня в DAYLO!', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Понятно', style: AppTheme.titleStyle.copyWith(color: AppTheme.accentGold))),
                                    ],
                                  ),
                                );
                              },
                              child: const Icon(Icons.info_outline_rounded, color: AppTheme.white38, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 105,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            children: [
                              // Add Story
                              GestureDetector(
                                onTap: _addStoryPhoto,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Consumer<UserProvider>(
                                            builder: (_, user, __) => Container(
                                              width: 70, height: 70,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme.white08,
                                                border: Border.all(color: AppTheme.white12, width: 1),
                                                image: user.avatarPath != null
                                                    ? DecorationImage(
                                                        image: FileImage(File(user.avatarPath!)),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: user.avatarPath == null
                                                  ? const Icon(Icons.person, color: AppTheme.white54, size: 32)
                                                  : null,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0, right: 0,
                                            child: Container(
                                              width: 24, height: 24,
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentBlue,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppTheme.primaryDark, width: 3),
                                              ),
                                              child: const Icon(Icons.add, size: 16, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text('Ваша история', style: AppTheme.captionStyle.copyWith(fontSize: 11, color: AppTheme.white)),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Consolidated Story Circle (Shows last story)
                              if (_stories.isNotEmpty)
                                GestureDetector(
                                  onTap: _openStoryViewer,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Segmented Ring
                                            SizedBox(
                                              width: 78,
                                              height: 78,
                                              child: CustomPaint(
                                                painter: _SegmentedRingPainter(
                                                  totalSegments: 12,
                                                  activeSegments: _stories.length,
                                                ),
                                              ),
                                            ),
                                            // Last Story Preview
                                            Container(
                                              width: 66,
                                              height: 66,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppTheme.primaryDark, width: 2),
                                                image: DecorationImage(
                                                  image: FileImage(_stories.last.file),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          DateFormat('HH:mm').format(_stories.last.timestamp),
                                          style: AppTheme.captionStyle.copyWith(fontSize: 11, color: AppTheme.white54),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 20),

                        // ── Label ──
                        Text('Блоки',
                            style: AppTheme.titleStyle
                                .copyWith(fontSize: 15, color: AppTheme.white54)),
                        const SizedBox(height: 12),

                        // ── Reorderable Blocks ──
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: _blockOrder.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex--;
                              final item = _blockOrder.removeAt(oldIndex);
                              _blockOrder.insert(newIndex, item);
                            });
                            _saveBlockOrder();
                          },
                          proxyDecorator: (child, index, animation) => Material(
                            color: Colors.transparent,
                            elevation: 4,
                            shadowColor: AppTheme.accentIndigo.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(24),
                            child: child,
                          ),
                          itemBuilder: (context, index) {
                            final id = _blockOrder[index];
                            final block = _buildBlockItem(id);
                            
                            Widget content;
                            if (_isEditing) {
                              content = Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ReorderableDragStartListener(
                                      index: index,
                                      child: AbsorbPointer(
                                        child: block
                                            .animate(
                                              onPlay: (c) => c.repeat(reverse: true),
                                              // Add random delay to each block for "chaotic" iOS feel
                                              delay: (index * 50).ms, 
                                            )
                                            .rotate(begin: -0.015, end: 0.015, duration: 120.ms, curve: Curves.easeInOutSine)
                                            .moveX(begin: -0.5, end: 0.5, duration: 100.ms, curve: Curves.easeInOutSine)
                                            .moveY(begin: -0.5, end: 0.5, duration: 110.ms, curve: Curves.easeInOutSine),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _removeBlock(id),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorRed.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded,
                                            color: AppTheme.errorRed, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              content = GestureDetector(
                                onLongPress: () {
                                  // Haptic feedback for editing mode
                                  setState(() => _isEditing = true);
                                },
                                child: block,
                              );
                            }

                            return Padding(
                              key: ValueKey('block_$id'),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: content,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Transparent layer to catch taps on empty space when editing
          if (_isEditing)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isEditing = false),
                behavior: HitTestBehavior.translucent,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showAddBlockDialog,
        backgroundColor: AppTheme.white08,
        child: const Icon(Icons.add, color: AppTheme.white),
      ),
    );
  }


  void _showQuickTransaction(BuildContext context, bool isExpense) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isCash = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13131F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, 
          left: 24, 
          right: 24, 
          top: 24
        ),
        child: StatefulBuilder(
          builder: (context, setModal) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isExpense ? 'Новый расход' : 'Новый доход', style: AppTheme.headlineStyle.copyWith(fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: AppTheme.bodyStyle,
                decoration: InputDecoration(
                  hintText: 'Название (Кофе, Зарплата...)',
                  hintStyle: AppTheme.captionStyle,
                  filled: true,
                  fillColor: AppTheme.white08,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: AppTheme.bodyStyle,
                decoration: InputDecoration(
                  hintText: 'Сумма (₽)',
                  hintStyle: AppTheme.captionStyle,
                  filled: true,
                  fillColor: AppTheme.white08,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.money_rounded, color: AppTheme.white54, size: 20),
                  const SizedBox(width: 12),
                  Text('Наличные', style: AppTheme.bodyStyle),
                  const Spacer(),
                  Switch(
                    value: isCash,
                    onChanged: (val) => setModal(() => isCash = val),
                    activeColor: AppTheme.accentGreen,
                    activeTrackColor: AppTheme.accentGreen.withValues(alpha: 0.2),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text) ?? 0;
                    if (titleCtrl.text.isNotEmpty && amt > 0) {
                      context.read<FinanceProvider>().addTransaction(titleCtrl.text, amt.toInt(), isExpense, isCash: isCash);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpense ? AppTheme.errorRed : AppTheme.accentGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Добавить', style: AppTheme.titleStyle.copyWith(color: AppTheme.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickNote(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13131F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, 
          left: 24, 
          right: 24, 
          top: 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Быстрая заметка', style: AppTheme.headlineStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              style: AppTheme.bodyStyle,
              decoration: InputDecoration(
                hintText: 'Заголовок',
                hintStyle: AppTheme.captionStyle,
                filled: true,
                fillColor: AppTheme.white08,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              style: AppTheme.bodyStyle,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Текст заметки',
                hintStyle: AppTheme.captionStyle,
                filled: true,
                fillColor: AppTheme.white08,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty || contentCtrl.text.isNotEmpty) {
                    context.read<NotesProvider>().addNote(
                      Note(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleCtrl.text.isEmpty ? 'Без названия' : titleCtrl.text,
                        content: contentCtrl.text,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Сохранить', style: AppTheme.titleStyle.copyWith(color: AppTheme.primaryDark)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickMood(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13131F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Как вы себя чувствуете?', style: AppTheme.headlineStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _moodBtn(ctx, 'Отлично', Colors.green),
                _moodBtn(ctx, 'Нормально', Colors.blue),
                _moodBtn(ctx, 'Устал', Colors.orange),
                _moodBtn(ctx, 'Плохо', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodBtn(BuildContext context, String title, Color color) {
    return GestureDetector(
      onTap: () {
        context.read<HealthProvider>().updateMentalHealth(title, color);
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mood, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  void _showQuickSleep(BuildContext context) {
    final hoursCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13131F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, 
          left: 24, 
          right: 24, 
          top: 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сколько вы спали?', style: AppTheme.headlineStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            TextField(
              controller: hoursCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTheme.bodyStyle,
              decoration: InputDecoration(
                hintText: 'Часы (например, 7.5)',
                hintStyle: AppTheme.captionStyle,
                filled: true,
                fillColor: AppTheme.white08,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final h = double.tryParse(hoursCtrl.text.replaceAll(',', '.')) ?? 0;
                  if (h > 0) {
                    final now = DateTime.now();
                    context.read<HealthProvider>().setSleepTimes(now.subtract(Duration(minutes: (h * 60).toInt())), now);
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentIndigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Сохранить', style: AppTheme.titleStyle.copyWith(color: AppTheme.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockItem(String id) {
    switch (id) {
      case 'checklist':
        return _buildChecklistBlock();
      case 'balance':
        return MinimalCard(
          onTap: () => context.findAncestorStateOfType<MainScreenState>()?.switchTab(3),
          child: Consumer<FinanceProvider>(
            builder: (context, finance, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: AppTheme.accentGreen, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('Баланс', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_upward_rounded,
                              color: AppTheme.accentGreen, size: 13),
                          const SizedBox(width: 3),
                          Text('Плюс',
                              style: AppTheme.captionStyle.copyWith(
                                  color: AppTheme.accentGreen,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${finance.balance} ₽',
                        style: AppTheme.headlineStyle.copyWith(
                            fontSize: 38, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text('доступно',
                          style: AppTheme.captionStyle.copyWith(
                              letterSpacing: 1.5, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      case 'sleep':
        return MinimalCard(
          onTap: () => context.findAncestorStateOfType<MainScreenState>()?.switchTab(2),
          child: Consumer<HealthProvider>(
              builder: (context, health, _) => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppTheme.accentIndigo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.bedtime_rounded, color: AppTheme.accentIndigo, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Сон', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                      Text('${health.sleepHours.toStringAsFixed(1)} ч сегодня', style: AppTheme.captionStyle),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.white38),
                ],
              ),
            ),
        );
      case 'status':
        return MinimalCard(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MentalHealthScreen())),
          child: Consumer<HealthProvider>(
              builder: (context, health, _) => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: health.mentalColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(Icons.favorite_rounded, color: health.mentalColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Настроение', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                      Text(health.mentalStatus, style: AppTheme.captionStyle),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.white38),
                ],
              ),
            ),
        );
      case 'notes':
        return MinimalCard(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesScreen())),
          child: Consumer<NotesProvider>(
              builder: (context, notes, _) => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: AppTheme.accentGold, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Заметки', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                      Text('${notes.notes.length} записей', style: AppTheme.captionStyle),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.white38),
                ],
              ),
            ),
        );
      case 'todo':
        return MinimalCard(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TodoScreen())),
          child: Consumer<TodoProvider>(
              builder: (context, todo, _) => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.checklist_rounded, color: AppTheme.accentBlue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Задачи', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                      Text('${todo.todos.where((t) => !t.isCompleted).length} активных', style: AppTheme.captionStyle),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.white38),
                ],
              ),
            ),
        );
      case 'weather':
        return Consumer<WeatherService>(
          builder: (context, weather, _) => MinimalCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    weather.condition.contains(' ') ? weather.condition.split(' ').last : '🌤️',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Погода', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                    weather.isLoading
                        ? Text('Загрузка...', style: AppTheme.captionStyle)
                        : Text(
                            weather.temperature != null
                                ? '${weather.condition.split(' ').first} · ${weather.temperature!.round()}°C'
                                : 'Нет данных',
                            style: AppTheme.captionStyle,
                          ),
                  ],
                ),
                const Spacer(),
                if (weather.temperature != null && !weather.isLoading)
                  Text(
                    '${weather.temperature!.round()}°',
                    style: AppTheme.titleStyle.copyWith(
                      color: AppTheme.accentBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        );
      case 'ai':
        return MinimalCard(
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => const AIChatSheet(),
          ),
          gradient: LinearGradient(
            colors: [
              AppTheme.accentPurple.withValues(alpha: 0.15),
              AppTheme.accentIndigo.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.2)),
          child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentPurple, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Ассистент', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                    Text('Нажмите, чтобы открыть чат', style: AppTheme.captionStyle),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.white38),
              ],
            ),
        );
      case 'nutrition':
        return MinimalCard(
          onTap: () => context.findAncestorStateOfType<MainScreenState>()?.switchTab(4),
          child: Consumer<NutritionProvider>(
              builder: (context, nutrition, _) => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.restaurant_rounded, color: AppTheme.accentPink, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Калории дня', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                      Text('${nutrition.totalCalories.toInt()} / ${nutrition.calorieGoal.toInt()} ккал', style: AppTheme.captionStyle),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.white38),
                ],
              ),
            ),
        );
      case 'water':
        return Consumer<NutritionProvider>(
          builder: (context, nutrition, _) {
            final progress = (nutrition.waterGlasses / nutrition.waterGoal).clamp(0.0, 1.0);
            final waterColor = Color.lerp(
              AppTheme.white08, 
              AppTheme.accentBlue.withValues(alpha: 0.25), 
              progress
            );
            
            return MinimalCard(
              color: waterColor,
              onTap: () => context.findAncestorStateOfType<MainScreenState>()?.switchTab(4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: AppTheme.accentBlue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Водный баланс', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                        Text('${nutrition.waterGlasses} / ${nutrition.waterGoal} стаканов', style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          nutrition.removeLastDrink();
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.white08,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.remove_rounded, color: AppTheme.white54, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          nutrition.addDrink(DrinkType.water, 250);
                          context.read<UserProvider>().completeDailyTask('water');
                          HapticFeedback.mediumImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_rounded, color: AppTheme.accentBlue, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      case 'quick_actions':
        return MinimalCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: AppTheme.accentGold, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text('Быстрые действия', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _QuickActionBtn(
                      label: 'Расход',
                      icon: Icons.money_off_rounded,
                      color: AppTheme.errorRed,
                      onTap: () => _showQuickTransaction(context, true),
                    ),
                    _QuickActionBtn(
                      label: 'Доход',
                      icon: Icons.attach_money_rounded,
                      color: AppTheme.accentGreen,
                      onTap: () => _showQuickTransaction(context, false),
                    ),
                    _QuickActionBtn(
                      label: 'Заметка',
                      icon: Icons.edit_note_rounded,
                      color: AppTheme.accentGold,
                      onTap: () => _showQuickNote(context),
                    ),
                    _QuickActionBtn(
                      label: 'Настроение',
                      icon: Icons.emoji_emotions_rounded,
                      color: AppTheme.accentPurple,
                      onTap: () => _showQuickMood(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
  Widget _buildChecklistBlock() {
    return Consumer<UserProvider>(
      builder: (context, user, _) {
        final tasks = user.dailyTasks;
        return MinimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ежедневные цели', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                  Text('${tasks.values.where((v) => v).length} / ${tasks.length}', 
                    style: AppTheme.captionStyle.copyWith(color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              _buildChecklistItem('Заметка', tasks['note']!, Icons.edit_note_rounded, AppTheme.accentGold),
              _buildChecklistItem('Калории', tasks['calories']!, Icons.restaurant_rounded, AppTheme.accentPink),
              _buildChecklistItem('Вода', tasks['water']!, Icons.water_drop_rounded, AppTheme.accentBlue),
              _buildChecklistItem('Настроение', tasks['mood']!, Icons.emoji_emotions_rounded, AppTheme.accentPurple),
              _buildChecklistItem('Дыхание', tasks['breathing']!, Icons.air_rounded, AppTheme.accentGreen),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChecklistItem(String title, bool isDone, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDone ? color.withValues(alpha: 0.2) : AppTheme.white05,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isDone ? color : AppTheme.white38, size: 16),
          ),
          const SizedBox(width: 12),
          Text(title, style: AppTheme.bodyStyle.copyWith(
            color: isDone ? AppTheme.white : AppTheme.white54,
            decoration: isDone ? TextDecoration.lineThrough : null,
          )),
          const Spacer(),
          if (isDone)
            const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 18)
          else
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.white12, width: 2),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentedRingPainter extends CustomPainter {
  final int totalSegments;
  final int activeSegments;

  _SegmentedRingPainter({
    required this.totalSegments,
    required this.activeSegments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 2.5;
    const spacing = 0.12; // gap between segments in radians

    final segmentAngle = (2 * 3.1415926535 - (spacing * totalSegments)) / totalSegments;

    for (int i = 0; i < totalSegments; i++) {
      Color color;
      if (activeSegments >= totalSegments) {
        color = const Color(0xFF4CFFB0); // Green if goal met
      } else if (i < activeSegments) {
        color = Colors.white; // White for active
      } else {
        color = Colors.white.withValues(alpha: 0.15); // Gray for inactive
      }

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Start from top (-90 degrees)
      final startAngle = i * (segmentAngle + spacing) - (3.1415926535 / 2) + (spacing / 2);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        segmentAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.bodyStyle.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
