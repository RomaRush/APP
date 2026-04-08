import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/story_entry.dart';
import 'story_view_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/finance_provider.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/nutrition_provider.dart';
import '../../widgets/story_days_widget.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/sleep_card.dart';
import '../../widgets/status_card.dart';
import '../../widgets/weather_widget.dart';
import '../../widgets/ai_assistant_button.dart';
import '../../widgets/tips_section.dart';
import '../../widgets/app_island.dart';
import '../../widgets/ai_chat_sheet.dart';
import 'article_screen.dart';
import 'story_view_screen.dart';
import '../../widgets/mental_health_card.dart';
import '../../core/providers/user_provider.dart';
import '../profile/profile_screen.dart';
import '../../core/providers/smart_life_provider.dart';
import '../../core/providers/notes_provider.dart';
import '../notes/notes_screen.dart';
import '../../widgets/smart_insight_card.dart';
import '../../core/providers/todo_provider.dart';
import '../todo/todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  
  List<StoryEntry> _stories = [];
  List<String> _blockOrder = ['balance', 'notes', 'sleep', 'status', 'weather', 'ai'];
  bool _isEditMode = false;
  
  // All available blocks with their display names
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
  };
  
  // Small blocks that can fit 2 per row
  static const Set<String> _smallBlocks = {'weather', 'status', 'ai', 'sleep'};

  @override
  void initState() {
    super.initState();
    _loadBlockOrder();
  }

  Future<void> _loadBlockOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('home_block_order');
    if (saved != null && saved.isNotEmpty) {
      // Migrate old combined block keys to new individual keys
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
      // Remove duplicates while preserving order
      migrated = migrated.toSet().toList();
      if (migrated.isNotEmpty) {
        setState(() => _blockOrder = migrated);
        _saveBlockOrder(); // Save migrated order
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Добавить блок', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (available.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Все блоки уже добавлены', style: TextStyle(color: Colors.white54)),
              )
            else
              ...available.map((id) => ListTile(
                leading: Icon(_getBlockIcon(id), color: Colors.white),
                title: Text(_allBlocks[id]!, style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                onTap: () {
                  setState(() => _blockOrder.add(id));
                  _saveBlockOrder();
                  Navigator.pop(ctx);
                },
              )),
          ],
        ),
      ),
    );
  }

  IconData _getBlockIcon(String id) {
    switch (id) {
      case 'balance': return Icons.account_balance_wallet;
      case 'notes': return Icons.edit_note;
      case 'todo': return Icons.checklist;
      case 'sleep': return Icons.bedtime;
      case 'status': return Icons.favorite;
      case 'weather': return Icons.cloud;
      case 'ai': return Icons.auto_awesome;
      case 'nutrition': return Icons.restaurant;
      case 'water': return Icons.water_drop;
      default: return Icons.widgets;
    }
  }

  Future<void> _addStoryPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Добавить историю',
              style: AppTheme.headlineStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Камера',
                  onTap: () {
                    Navigator.pop(context);
                    _pickStoryImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Галерея',
                  onTap: () {
                    Navigator.pop(context);
                    _pickStoryImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStoryImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        final jFile = File(photo.path);
        final entry = StoryEntry(file: jFile, timestamp: DateTime.now());
        setState(() {
          _stories.add(entry);
        });
        // Sync to UserProvider for Profile Screen
        if (mounted) {
          context.read<UserProvider>().addStoryEntry(entry);
        }
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
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openArticle(BuildContext context, TipCardData tip) {
    List<ArticleBlock> blocks = [];
    String headerImage = tip.imagePath;

    if (tip.title.toLowerCase().contains('завтрак')) {
      blocks = [
        ArticleBlock(
          type: ArticleContentType.text,
          content: 'Завтрак — это самый важный прием пищи, который запускает ваш метаболизм и заряжает энергией на первую половину дня. Пропуск завтрака может привести к упадку сил и перееданию вечером. Идеальный завтрак должен содержать сложные углеводы, белки и полезные жиры.',
        ),
        ArticleBlock(
          type: ArticleContentType.image,
          content: 'assets/images/tip_food.png',
        ),
        ArticleBlock(
          type: ArticleContentType.recipeStep,
          title: 'Идеальная овсянка',
          content: 'Возьмите 50 г овсяных хлопьев (не быстрого приготовления!) и залейте их 150 мл воды или растительного молока. Добавьте щепотку соли для раскрытия вкуса. Варите на медленном огне, постоянно помешивая, чтобы каша стала кремовой и нежной.',
        ),
        ArticleBlock(
          type: ArticleContentType.image,
          content: 'assets/images/recipe_oatmeal_1.png',
        ),
        ArticleBlock(
          type: ArticleContentType.text,
          content: 'Не бойтесь экспериментировать с топпингами. Это то, что делает кашу вкусной! Попробуйте добавить ложку меда, горсть орехов (грецкие или миндаль), семена чиа и свежие ягоды. Это добавит текстуру и витамины.',
        ),
        ArticleBlock(
          type: ArticleContentType.image,
          content: 'assets/images/recipe_oatmeal_2.png',
        ),
        ArticleBlock(
          type: ArticleContentType.text,
          content: 'Такой завтрак обеспечит вас чувством сытости на 4-5 часов и предотвратит резкие скачки сахара в крови. Приятного аппетита!',
        ),
      ];
    } else if (tip.title.toLowerCase().contains('спокойствие')) {
      blocks = [
        ArticleBlock(
          type: ArticleContentType.text,
          content: 'В современном мире мы постоянно подвергаемся стрессу. Уведомления, дедлайны, шум города — все это перегружает наш мозг. Найти спокойствие — это не роскошь, а необходимость для сохранения психического здоровья. Регулярные паузы помогают восстановить ресурс.',
        ),
        ArticleBlock(
          type: ArticleContentType.image,
          content: 'assets/images/tip_calm.png',
        ),
        ArticleBlock(
          type: ArticleContentType.recipeStep,
          title: 'Техника "Заземление"',
          content: 'Если вы чувствуете тревогу, попробуйте технику 5-4-3-2-1. Найдите 5 предметов глазами, 4 на ощупь, 3 звука, 2 запаха и 1 вкус. Это вернет вас в момент "здесь и сейчас".',
        ),
        ArticleBlock(
          type: ArticleContentType.image,
          content: 'assets/images/tip_meditation_pose.png',
        ),
        ArticleBlock(
          type: ArticleContentType.text,
          content: 'Медитация не требует сложных навыков. Просто сядьте удобно, закройте глаза и наблюдайте за дыханием. Если мысли приходят — отпускайте их, как облака на небе. Даже 5 минут практики в день меняют структуру мозга.',
        ),
        ArticleBlock(
          type: ArticleContentType.image,
          content: 'assets/images/tip_general.png',
        ),
        ArticleBlock(
          type: ArticleContentType.text,
          content: 'Также не забывайте про цифровой детокс. Отключайте телефон за час до сна, чтобы нервная система могла успокоиться перед отдыхом.',
        ),
      ];
    } else {
      blocks = [
        ArticleBlock(
          type: ArticleContentType.text,
          content: 'Чтение — это уникальный тренажер для мозга. Оно развивает эмпатию (способность понимать чувства других), улучшает память и концентрацию. В отличие от скроллинга ленты, чтение глубоко погружает в контекст и снижает уровень стресса уже через 6 минут.',
        ),
        ArticleBlock(
          type: ArticleContentType.image,
          content: 'assets/images/tip_read.png',
        ),
        ArticleBlock(
          type: ArticleContentType.recipeStep,
          title: 'Как читать больше?',
          content: 'Секрет прост: всегда носите с собой книгу (или читалку). Читайте в очередях, в транспорте или перед сном. Замените 20 минут соцсетей на 20 страниц книги.',
        ),
        ArticleBlock(
          type: ArticleContentType.image,
          content: 'assets/images/tip_library.png',
        ),
        ArticleBlock(
          type: ArticleContentType.text,
          content: 'Создайте дома уютный уголок для чтения. Хороший свет, мягкое кресло и тишина помогут вам быстрее погрузиться в историю. Не заставляйте себя дочитывать скучные книги — жизнь слишком коротка.',
        ),
        ArticleBlock(
          type: ArticleContentType.image,
          content: 'assets/images/tip_calm.png',
        ),
        ArticleBlock(
          type: ArticleContentType.text,
          content: 'Попробуйте чередовать жанры: художественная литература развивает воображение, а нон-фикшн дает новые знания. Главное — регулярность.',
        ),
      ];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(
          title: tip.title,
          headerImage: headerImage,
          blocks: blocks,
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня',
      'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'
    ];
    return '${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg_dark.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: ReorderableListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (BuildContext context, Widget? child) => Material(color: Colors.transparent, child: child),
                        child: child,
                      );
                    },
                    header: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Главная',
                                    style: AppTheme.headlineStyle.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getCurrentDate(),
                                    style: AppTheme.bodyStyle.copyWith(
                                      color: AppTheme.white.withValues(alpha: 0.85),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              // Avatar & Edit code...
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() => _isEditMode = !_isEditMode),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: _isEditMode ? AppTheme.white : Colors.transparent, shape: BoxShape.circle),
                                      child: Icon(Icons.edit, color: _isEditMode ? AppTheme.black : AppTheme.white, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Consumer<UserProvider>(
                                    builder: (context, user, _) {
                                      return GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                        ),
                                        child: Container(
                                          width: 50, height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: AppTheme.white.withValues(alpha: 0.5), width: 2),
                                            image: DecorationImage(
                                              image: user.avatarPath != null
                                                  ? FileImage(File(user.avatarPath!))
                                                  : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Smart Insights Section
                          Consumer<SmartLifeProvider>(
                            builder: (context, smartLife, _) {
                              final insights = smartLife.activeInsights;
                              // Morning Brief Check
                              final hour = DateTime.now().hour;
                              final showMorningBrief = hour < 12;
                              
                              if (insights.isEmpty && !showMorningBrief) return const SizedBox.shrink();
                              
                              return Column(
                                children: [
                                  if (showMorningBrief)
                                    Container(
                                       margin: const EdgeInsets.only(bottom: 16),
                                       padding: const EdgeInsets.all(16),
                                       decoration: BoxDecoration(
                                         gradient: LinearGradient(
                                           colors: [Colors.blue.shade900.withValues(alpha: 0.5), Colors.purple.shade900.withValues(alpha: 0.5)],
                                           begin: Alignment.topLeft,
                                           end: Alignment.bottomRight,
                                         ),
                                         borderRadius: BorderRadius.circular(20),
                                         border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                       ),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
                                                const SizedBox(width: 8),
                                                Text("Утренний брифинг", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              smartLife.dailyBudgetAdvice,
                                              style: const TextStyle(color: Colors.white, fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Заряд сил: ${smartLife.bodyBattery}%",
                                              style: TextStyle(
                                                color: smartLife.bodyBattery > 70 ? Colors.greenAccent : Colors.orangeAccent, 
                                                fontSize: 13, fontWeight: FontWeight.bold
                                              ),
                                            ),
                                         ],
                                       ),
                                    ),
                                  
                                  ...insights.map((i) => SmartInsightCard(insight: i)),
                                ],
                              );
                            },
                          ),
                          
                          StoryDaysWidget(
                            filledCount: _stories.length,
                            lastPhoto: _stories.isNotEmpty ? _stories.last.file : null,
                            onAddTap: _addStoryPhoto,
                            onAvatarTap: _openStoryViewer,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    children: _buildBlockChildren(),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final String item = _blockOrder.removeAt(oldIndex);
                        _blockOrder.insert(newIndex, item);
                      });
                      _saveBlockOrder();
                    },
                    footer: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 24),
                      padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: bottomPadding + 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.3), 
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)),
                      ),
                      child: TipsSection(
                        onTipTap: (tip) => _openArticle(context, tip),
                        tips: [
                          TipCardData(title: 'Чем завтракать?', imagePath: 'assets/images/tip_food.png', articleContent: ''),
                          TipCardData(title: 'как найти спокойствие?', imagePath: 'assets/images/tip_calm.png', articleContent: ''),
                          TipCardData(title: 'Что прочитать?', imagePath: 'assets/images/tip_read.png', articleContent: ''),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBlockChildren() {
    List<Widget> children = [];
    int i = 0;
    
    while (i < _blockOrder.length) {
      final blockId = _blockOrder[i];
      final isSmall = _smallBlocks.contains(blockId);
      final hasNextSmall = i + 1 < _blockOrder.length && _smallBlocks.contains(_blockOrder[i + 1]);
      
      if (isSmall && hasNextSmall) {
        // Two small blocks side by side - create a Row with both
        final nextBlockId = _blockOrder[i + 1];
        children.add(
          Padding(
            key: ValueKey('row_${blockId}_$nextBlockId'),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDraggableBlock(blockId, isHalfWidth: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDraggableBlock(nextBlockId, isHalfWidth: true),
                ),
              ],
            ),
          ),
        );
        i += 2;
      } else {
        // Single block (big or unpaired small)
        children.add(
          Padding(
            key: ValueKey(blockId),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: _buildDraggableBlock(blockId, isHalfWidth: false),
          ),
        );
        i += 1;
      }
    }
    
    // Add block button in edit mode
    if (_isEditMode) {
      children.add(
        Padding(
          key: const ValueKey('add_block'),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: GestureDetector(
            onTap: _showAddBlockDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline, color: Colors.white54),
                  SizedBox(width: 8),
                  Text('Добавить блок', style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return children;
  }
  
  Widget _buildDraggableBlock(String blockId, {required bool isHalfWidth}) {
    return Stack(
      children: [
        _buildBlock(blockId),
        if (_isEditMode) ...[
          Positioned.fill(child: Container(color: Colors.transparent)),
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _removeBlock(blockId),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.drag_indicator, color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBlock(String id) {
    switch (id) {
      case 'balance':
        return Consumer<FinanceProvider>(
          builder: (context, finance, _) => BalanceCard(balance: finance.balance),
        );
      case 'sleep':
        return Consumer<HealthProvider>(
          builder: (context, health, _) {
            return SleepCard(
              weeklyData: [6.5, 7.0, 6.8, 7.2, 5.5, 8.0, health.sleepHours], 
              todayHours: health.sleepHours,
            );
          }
        );
      case 'status':
        return Consumer<HealthProvider>(
          builder: (context, health, _) {
            return StatusCard(
              customText: health.mentalStatus.toLowerCase(),
              customColor: health.mentalColor,
            );
          }
        );
      case 'notes':
        return Consumer<NotesProvider>(
          builder: (context, notesProvider, _) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesScreen())),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_note, color: Colors.amber, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Заметки', style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              notesProvider.notes.isEmpty 
                                  ? 'Создать новую' 
                                  : '${notesProvider.notes.length} шт.', 
                              style: AppTheme.bodyStyle.copyWith(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.3), size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      case 'todo':
        return Consumer<TodoProvider>(
          builder: (context, todoProvider, _) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TodoScreen())),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.checklist, color: Colors.blueAccent, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Задачи', style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              todoProvider.pendingTodos == 0
                                  ? 'Все выполнено ✓'
                                  : '${todoProvider.pendingTodos} активных',
                              style: AppTheme.bodyStyle.copyWith(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (todoProvider.pendingTodos > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${todoProvider.pendingTodos}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          )
                        else
                          Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.3), size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      case 'weather':
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const WeatherWidget(),
            ),
          ),
        );
      case 'ai':
        return GestureDetector(
          onTap: () => _showAiChat(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.purple.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 10),
                    const Text('AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Спросить', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        );
      case 'nutrition':
        return Consumer<NutritionProvider>(
          builder: (context, nutrition, _) {
            final percent = (nutrition.totalCalories / nutrition.calorieGoal).clamp(0.0, 1.0);
            final remaining = (nutrition.calorieGoal - nutrition.totalCalories).toInt();
            return ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.local_fire_department, color: Colors.orange.shade300, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Калории', style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(
                                    remaining > 0 ? 'Осталось $remaining ккал' : 'Превышено на ${-remaining} ккал',
                                    style: TextStyle(color: remaining > 0 ? Colors.white54 : Colors.redAccent, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: percent > 1 ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${(percent * 100).toInt()}%',
                              style: TextStyle(
                                color: percent > 1 ? Colors.redAccent : Colors.greenAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percent.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: percent > 1 
                                      ? [Colors.red.shade400, Colors.red.shade600]
                                      : [Colors.orange.shade400, Colors.deepOrange.shade400],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Macros row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMacroItem('Б', nutrition.totalProteins.toInt(), nutrition.proteinGoal.toInt(), Colors.blue.shade300),
                          _buildMacroItem('Ж', nutrition.totalFats.toInt(), nutrition.fatGoal.toInt(), Colors.orange.shade300),
                          _buildMacroItem('У', nutrition.totalCarbs.toInt(), nutrition.carbGoal.toInt(), Colors.green.shade300),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      case 'water':
        return Consumer<NutritionProvider>(
          builder: (context, nutrition, _) {
            final waterPercent = nutrition.waterGlasses / nutrition.waterGoal;
            return ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(Colors.black.withValues(alpha: 0.35), Colors.blue.shade800.withValues(alpha: 0.5), waterPercent)!,
                        Color.lerp(Colors.black.withValues(alpha: 0.35), Colors.cyan.shade700.withValues(alpha: 0.4), waterPercent)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      // Water glass visualization
                      Container(
                        width: 50,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.lightBlueAccent.withValues(alpha: 0.5), width: 2),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FractionallySizedBox(
                                heightFactor: waterPercent.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.lightBlueAccent.withValues(alpha: 0.8), Colors.blue.withValues(alpha: 0.6)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              child: Text(
                                '${nutrition.waterGlasses}',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Водный баланс', style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '${nutrition.waterMl} / ${nutrition.waterGoalMl} мл',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            // Progress dots
                            Row(
                              children: List.generate(nutrition.waterGoal, (i) => Container(
                                margin: const EdgeInsets.only(right: 6),
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i < nutrition.waterGlasses 
                                      ? Colors.lightBlueAccent 
                                      : Colors.white.withValues(alpha: 0.2),
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => nutrition.addWater(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 22),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => nutrition.removeWater(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.remove, color: Colors.white54, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMacroItem(String label, int current, int goal, Color color) {
    final percent = (current / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Text('$current', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  void _showAiChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIChatSheet(),
    );
  }
}
