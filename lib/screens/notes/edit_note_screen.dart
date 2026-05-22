import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/note.dart';
import '../../core/providers/notes_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/premium_dialog.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DateTime _createdAt;
  bool _isDirty = false;
  
  List<TodoItem> _todos = [];
  bool _isTodoMode = false;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _createdAt = widget.note?.createdAt ?? DateTime.now();
    
    if (widget.note?.todoItems != null) {
      _todos = List.from(widget.note!.todoItems!);
      if (_todos.isNotEmpty) _isTodoMode = true;
    }
    _reminderTime = widget.note?.reminderDateTime;

    _titleController.addListener(_markAsDirty);
    _contentController.addListener(_markAsDirty);
  }

  void _markAsDirty() {
    if (!_isDirty) {
      if (mounted) setState(() => _isDirty = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && _todos.isEmpty) {
      return; 
    }

    final provider = context.read<NotesProvider>();
    final now = DateTime.now();

    if (widget.note == null) {
      final newNote = Note(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.isEmpty ? 'Без названия' : title,
        content: content,
        createdAt: _createdAt,
        updatedAt: now,
        todoItems: _isTodoMode ? _todos : null,
        reminderDateTime: _reminderTime,
      );
      await provider.addNote(newNote);
      if (mounted) context.read<UserProvider>().completeDailyTask('note');
    } else {
      final updatedNote = widget.note!.copyWith(
        title: title.isEmpty ? 'Без названия' : title,
        content: content,
        updatedAt: now,
        todoItems: _isTodoMode ? _todos : null,
        reminderDateTime: _reminderTime,
      );
      await provider.updateNote(updatedNote);
    }
    _isDirty = false;
  }
  
  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
      _isDirty = true;
    });
  }
  
  void _addTodoItem() {
    setState(() {
      _todos.add(TodoItem(text: ''));
      _isDirty = true;
      _isTodoMode = true;
    });
  }

  void _showReminderPicker() {
    DateTime tempDateTime = _reminderTime ?? DateTime.now().add(const Duration(minutes: 30));
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
           height: 350,
           decoration: BoxDecoration(
             color: const Color(0xFF1C1C1E),
             borderRadius: const BorderRadius.only(
               topLeft: Radius.circular(20),
               topRight: Radius.circular(20),
             ),
             boxShadow: [
               BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20),
             ],
           ),
           child: Column(
             children: [
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     TextButton(
                       onPressed: () {
                         Navigator.pop(context);
                         // if already set to something, clear? Or just cancel edit
                         // Cancel edit: do nothing.
                       },
                       child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
                     ),
                     const Text("Напоминание", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                     TextButton(
                       onPressed: () {
                         setState(() {
                           _reminderTime = tempDateTime;
                           _isDirty = true;
                         });
                         Navigator.pop(context);
                       },
                       child: const Text('Готово', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                     ),
                   ],
                 ),
               ),
               const Divider(color: Colors.grey, height: 1),
               Expanded(
                 child: CupertinoTheme(
                   data: const CupertinoThemeData(
                     textTheme: CupertinoTextThemeData(
                       dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                     ),
                   ),
                   child: CupertinoDatePicker(
                     initialDateTime: tempDateTime,
                     minimumDate: DateTime.now().subtract(const Duration(minutes: 5)),
                     mode: CupertinoDatePickerMode.dateAndTime,
                     onDateTimeChanged: (val) {
                       tempDateTime = val;
                     },
                   ),
                 ),
               ),
               if (_reminderTime != null)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 24, top: 8),
                   child: TextButton(
                     onPressed: () {
                        setState(() {
                          _reminderTime = null;
                          _isDirty = true;
                        });
                        Navigator.pop(context);
                     },
                     child: const Text('Удалить напоминание', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                   ),
                 ),
             ],
           ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop && _isDirty) {
          await _saveNote();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
             IconButton(
               icon: Icon(
                 _reminderTime != null ? Icons.alarm_on : Icons.alarm_add, 
                 color: _reminderTime != null ? Colors.amber : Colors.white70
               ),
               onPressed: _showReminderPicker,
             ),
             IconButton(
               icon: Icon(_isTodoMode ? Icons.check_box : Icons.check_box_outline_blank, color: Colors.white),
               onPressed: () {
                 if (!_isTodoMode && _todos.isEmpty) {
                   setState(() {
                     _isTodoMode = true;
                     if (_contentController.text.isNotEmpty) {
                       final lines = _contentController.text.split('\n');
                       _todos = lines.map((l) => TodoItem(text: l)).toList();
                       _contentController.clear();
                     } else {
                        _todos.add(TodoItem(text: ''));
                     }
                     _isDirty = true;
                   });
                 } else if (_isTodoMode) {
                    setState(() {
                       _isTodoMode = false;
                       _contentController.text = _todos.map((e) => e.text).join('\n');
                       _todos.clear();
                       _isDirty = true;
                    });
                 }
               },
             ),
             IconButton(
               icon: const Icon(Icons.check, color: Colors.amber),
               onPressed: () {
                 Navigator.of(context).pop();
               },
             ),
             if (widget.note != null)
               IconButton(
                 icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                 onPressed: () async {
                    final confirm = await showPremiumDialog<bool>(
                      context: context,
                      title: 'Удалить заметку?',
                      content: const Text(
                        'Это действие нельзя отменить.',
                        style: TextStyle(color: AppTheme.white70),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Отмена', style: TextStyle(color: AppTheme.white38)),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        TextButton(
                          child: const Text('Удалить', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    );
                   
                   if (confirm == true && mounted) {
                     await context.read<NotesProvider>().deleteNote(widget.note!.id);
                     _isDirty = false; 
                     Navigator.of(context).pop();
                   }
                 },
               ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_reminderTime != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.alarm, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM HH:mm', 'ru').format(_reminderTime!), 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() { _reminderTime = null; _isDirty = true;}),
                          child: const Icon(Icons.close, size: 18, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              
              TextField(
                controller: _titleController,
                style: AppTheme.headlineStyle.copyWith(fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'Заголовок',
                  hintStyle: AppTheme.headlineStyle.copyWith(color: Colors.white54),
                  border: InputBorder.none,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isTodoMode 
                  ? ReorderableListView(
                      proxyDecorator: (child, index, animation) => Material(color: Colors.transparent, child: child),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) newIndex -= 1;
                          final item = _todos.removeAt(oldIndex);
                          _todos.insert(newIndex, item);
                          _isDirty = true;
                        });
                      },
                      children: [
                        for (int i = 0; i < _todos.length; i++)
                           ListTile(
                             key: ValueKey(_todos[i]),
                             contentPadding: EdgeInsets.zero,
                             leading: Checkbox(
                               value: _todos[i].isDone,
                               activeColor: Colors.amber,
                               checkColor: Colors.black,
                               side: const BorderSide(color: Colors.white54, width: 2),
                               onChanged: (val) => _toggleTodo(i),
                             ),
                             title: TextField(
                               controller: TextEditingController(text: _todos[i].text)
                                  ..selection = TextSelection.collapsed(offset: _todos[i].text.length),
                               style: AppTheme.bodyStyle.copyWith(
                                 color: Colors.white.withValues(alpha: 0.9),
                                 decoration: _todos[i].isDone ? TextDecoration.lineThrough : null,
                                 decorationColor: Colors.white54,
                               ),
                               decoration: const InputDecoration(border: InputBorder.none),
                               onChanged: (val) {
                                 _todos[i].text = val;
                                 if (!_isDirty) setState(() => _isDirty = true);
                               },
                             ),
                             trailing: IconButton(
                               icon: const Icon(Icons.close, color: Colors.white30, size: 20),
                               onPressed: () => setState(() { _todos.removeAt(i); _isDirty = true; }),
                             ),
                           ),
                         // Add button at bottom
                         ListTile(
                           key: const ValueKey('add_btn'),
                           leading: const Icon(Icons.add, color: Colors.white54),
                           title: const Text('Добавить пункт', style: TextStyle(color: Colors.white54)),
                           onTap: _addTodoItem,
                         ),
                      ],
                    )
                  : TextField(
                      controller: _contentController,
                      style: AppTheme.bodyStyle.copyWith(color: Colors.white.withValues(alpha: 0.9), height: 1.5),
                      decoration: InputDecoration(
                        hintText: 'Начните писать...',
                        hintStyle: AppTheme.bodyStyle.copyWith(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
