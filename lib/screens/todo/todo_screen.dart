import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/todo_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/premium_dialog.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showAddTodoSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate;
    int selectedPriority = 1;
    String selectedCategory = 'Общее';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final categories = Provider.of<TodoProvider>(context, listen: false).categories;
          
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Новая задача',
                    style: AppTheme.headlineStyle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Название задачи',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Описание (опционально)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Priority
                  Text('Приоритет', style: AppTheme.bodyStyle.copyWith(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityChip('Низкий', 0, selectedPriority, Colors.green, (v) {
                        setModalState(() => selectedPriority = v);
                      }),
                      const SizedBox(width: 8),
                      _buildPriorityChip('Средний', 1, selectedPriority, Colors.orange, (v) {
                        setModalState(() => selectedPriority = v);
                      }),
                      const SizedBox(width: 8),
                      _buildPriorityChip('Высокий', 2, selectedPriority, Colors.red, (v) {
                        setModalState(() => selectedPriority = v);
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Category
                  Text('Категория', style: AppTheme.bodyStyle.copyWith(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) => GestureDetector(
                      onTap: () => setModalState(() => selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedCategory == cat 
                            ? Colors.amber.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: selectedCategory == cat 
                            ? Border.all(color: Colors.amber, width: 1)
                            : null,
                        ),
                        child: Text(cat, style: TextStyle(
                          color: selectedCategory == cat ? Colors.amber : Colors.white70, 
                          fontSize: 13,
                        )),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Due Date
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(primary: Colors.amber),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setModalState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.amber.withValues(alpha: 0.8), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null 
                              ? DateFormat('dd MMMM yyyy', 'ru').format(selectedDate!)
                              : 'Добавить дедлайн',
                            style: TextStyle(color: selectedDate != null ? Colors.white : Colors.white54),
                          ),
                          if (selectedDate != null) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setModalState(() => selectedDate = null),
                              child: const Icon(Icons.close, color: Colors.white38, size: 18),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          Provider.of<TodoProvider>(context, listen: false).addTodo(
                            titleController.text,
                            description: descController.text.isNotEmpty ? descController.text : null,
                            dueDate: selectedDate,
                            priority: selectedPriority,
                            category: selectedCategory,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Добавить', style: AppTheme.titleStyle.copyWith(color: Colors.black, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityChip(String label, int value, int selected, Color color, Function(int) onTap) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? color : Colors.white54, fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background - same as notes
          Positioned.fill(
            child: Consumer<UserProvider>(
              builder: (context, user, _) {
                return Image.asset(
                  user.wallpaperPath,
                  fit: BoxFit.cover,
                );
              }
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header - same style as notes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Consumer<TodoProvider>(
                    builder: (context, todo, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Задачи',
                                    style: AppTheme.headlineStyle.copyWith(fontSize: 28),
                                  ),
                                  Text(
                                    '${todo.completedTodos}/${todo.totalTodos} выполнено',
                                    style: AppTheme.bodyStyle.copyWith(color: Colors.white54, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  todo.showCompleted ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white54,
                                ),
                                onPressed: () => todo.toggleShowCompleted(),
                              ),
                              if (todo.completedTodos > 0)
                                IconButton(
                                  icon: const Icon(Icons.delete_sweep, color: Colors.white54),
                                  onPressed: () => _showClearDialog(context, todo),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                // Progress Bar
                Consumer<TodoProvider>(
                  builder: (context, todo, _) {
                    final progress = todo.totalTodos > 0 ? todo.completedTodos / todo.totalTodos : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Stack(
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          AnimatedContainer(
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                            height: 6,
                            width: (MediaQuery.of(context).size.width - 40) * progress,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Category Filter
                Consumer<TodoProvider>(
                  builder: (context, todo, _) {
                    return SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _buildCategoryChip('Все', todo),
                          ...todo.categories.map((cat) => _buildCategoryChip(cat, todo)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Todo List
                Expanded(
                  child: Consumer<TodoProvider>(
                    builder: (context, todo, _) {
                      if (todo.filteredTodos.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 80, color: Colors.white.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              Text(
                                todo.totalTodos == 0 
                                  ? 'Нет задач'
                                  : 'Все выполнено! 🎉',
                                style: AppTheme.bodyStyle.copyWith(color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
                        physics: const BouncingScrollPhysics(),
                        itemCount: todo.filteredTodos.length,
                        itemBuilder: (context, index) {
                          final item = todo.filteredTodos[index];
                          return _buildTodoCard(item, todo)
                              .animate()
                              .fadeIn(duration: 350.ms, delay: (index * 40).ms)
                              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
                        },
                      );
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: _showAddTodoSheet,
        child: const Icon(Icons.add, color: Colors.black),
      ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }

  void _showClearDialog(BuildContext context, TodoProvider todo) {
    showPremiumDialog(
      context: context,
      title: 'Очистить?',
      content: const Text(
        'Удалить все выполненные задачи?',
        style: TextStyle(color: AppTheme.white70),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white38)),
        ),
        TextButton(
          onPressed: () {
            todo.clearCompleted();
            Navigator.pop(context);
          },
          child: const Text('Удалить', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, TodoProvider todo) {
    final isSelected = todo.selectedCategory == category;
    return GestureDetector(
      onTap: () => todo.setSelectedCategory(category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.amber, width: 1) : null,
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.amber : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTodoCard(TodoItem item, TodoProvider todo) {
    final priorityColors = [Colors.green, Colors.orange, Colors.red];
    final priorityColor = priorityColors[item.priority];
    final dateStr = item.dueDate != null ? DateFormat('dd MMM', 'ru').format(item.dueDate!) : null;
    final isOverdue = item.dueDate != null && item.dueDate!.isBefore(DateTime.now()) && !item.isCompleted;
    
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => todo.deleteTodo(item.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => todo.toggleTodo(item.id),
        onLongPress: () => _showTimerSheet(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => todo.toggleTodo(item.id),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isCompleted 
                      ? Colors.green.withValues(alpha: 0.2)
                      : priorityColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: item.isCompleted ? Colors.green : priorityColor,
                      width: 2,
                    ),
                  ),
                  child: item.isCompleted
                    ? const Icon(Icons.check, color: Colors.green, size: 16)
                    : null,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTheme.titleStyle.copyWith(
                        color: item.isCompleted ? Colors.white38 : Colors.white,
                        fontSize: 16,
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: AppTheme.bodyStyle.copyWith(color: Colors.white54, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ),
                        if (dateStr != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: isOverdue ? Colors.redAccent : Colors.white30,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: isOverdue ? Colors.redAccent : Colors.white30,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Timer icon hint
              Icon(Icons.timer_outlined, color: Colors.white.withValues(alpha: 0.2), size: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  // Timer Sheet for task
  void _showTimerSheet(TodoItem item) {
    int minutes = 25; // Default Pomodoro
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Таймер для задачи',
                  style: AppTheme.headlineStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: AppTheme.bodyStyle.copyWith(color: Colors.amber),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                
                // Time presets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [5, 15, 25, 45, 60].map((m) {
                    final isSelected = minutes == m;
                    return GestureDetector(
                      onTap: () => setModalState(() => minutes = m),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected ? Border.all(color: Colors.amber, width: 2) : null,
                        ),
                        child: Center(
                          child: Text(
                            '$m',
                            style: TextStyle(
                              color: isSelected ? Colors.amber : Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text('минут', style: TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 24),
                
                // Start timer button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _startTimer(item, minutes);
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: Text('Запустить таймер', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _startTimer(TodoItem item, int minutes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskTimerScreen(task: item, minutes: minutes),
      ),
    );
  }
}

// Separate Timer Screen that works in background
class TaskTimerScreen extends StatefulWidget {
  final TodoItem task;
  final int minutes;
  
  const TaskTimerScreen({super.key, required this.task, required this.minutes});
  
  @override
  State<TaskTimerScreen> createState() => _TaskTimerScreenState();
}

class _TaskTimerScreenState extends State<TaskTimerScreen> with WidgetsBindingObserver {
  late int _secondsRemaining;
  Timer? _timer;
  bool _isRunning = false;
  DateTime? _pausedAt;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _secondsRemaining = widget.minutes * 60;
    _startTimer();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
  
  // Handle app lifecycle for background timer
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isRunning) {
      // App going to background - save current time
      _pausedAt = DateTime.now();
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed && _pausedAt != null && _isRunning) {
      // App returning from background - calculate elapsed time
      final elapsed = DateTime.now().difference(_pausedAt!).inSeconds;
      setState(() {
        _secondsRemaining = (_secondsRemaining - elapsed).clamp(0, widget.minutes * 60);
      });
      _pausedAt = null;
      if (_secondsRemaining > 0) {
        _startTimerTick();
      } else {
        _onTimerComplete();
      }
    }
  }
  
  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _startTimerTick();
  }
  
  void _startTimerTick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _onTimerComplete();
      }
    });
  }
  
  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }
  
  void _resumeTimer() {
    setState(() => _isRunning = true);
    _startTimerTick();
  }
  
  void _onTimerComplete() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    
    showPremiumDialog(
      context: context,
      title: 'Время вышло!',
      content: Text(
        'Задача "${widget.task.title}" завершена за ${widget.minutes} минут. Отличная работа! 🎉',
        style: const TextStyle(color: AppTheme.white70),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text('Закрыть', style: AppTheme.bodyStyle.copyWith(color: AppTheme.white38)),
        ),
        TextButton(
          onPressed: () {
            Provider.of<TodoProvider>(context, listen: false).toggleTodo(widget.task.id);
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text('Выполнено', style: AppTheme.titleStyle.copyWith(color: AppTheme.accentGreen, fontSize: 16)),
        ),
      ],
    );
  }
  
  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_secondsRemaining / (widget.minutes * 60));
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Consumer<UserProvider>(
              builder: (context, user, _) {
                return Image.asset(
                  user.wallpaperPath,
                  fit: BoxFit.cover,
                );
              }
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Timer Circle
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      // Progress circle
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation(Colors.amber),
                        ),
                      ),
                      // Time text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(_secondsRemaining),
                            style: AppTheme.headlineStyle.copyWith(fontSize: 56),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRunning ? 'В процессе' : 'Пауза',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Controls
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset button
                      GestureDetector(
                        onTap: () {
                          _timer?.cancel();
                          setState(() {
                            _secondsRemaining = widget.minutes * 60;
                            _isRunning = false;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.refresh, color: Colors.white54, size: 28),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Play/Pause button
                      GestureDetector(
                        onTap: () {
                          if (_isRunning) {
                            _pauseTimer();
                          } else {
                            _resumeTimer();
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber,
                          ),
                          child: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Skip button
                      GestureDetector(
                        onTap: _onTimerComplete,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.skip_next, color: Colors.white54, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
