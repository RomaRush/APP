import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/note.dart';
import '../../core/providers/notes_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/minimal_card.dart';
import 'edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _sortByModified = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Consumer<UserProvider>(
              builder: (context, user, _) =>
                  Image.asset(user.wallpaperPath, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      if (!_isSearching) ...[ 
                        const SizedBox(width: 12),
                        Text('Заметки', style: AppTheme.headlineStyle),
                        const Spacer(),
                        // Search toggle
                        IconButton(
                          icon: const Icon(Icons.search_rounded, color: AppTheme.white70),
                          onPressed: () => setState(() => _isSearching = true),
                        ),
                        // Sort
                        PopupMenuButton<bool>(
                          icon: const Icon(Icons.sort_rounded, color: AppTheme.white70),
                          color: const Color(0xFF1A1A2E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          onSelected: (bool sortByModified) {
                            setState(() => _sortByModified = sortByModified);
                            context.read<NotesProvider>().sortNotes(byDateModified: sortByModified);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: false,
                              child: Row(children: [
                                Icon(Icons.calendar_today_rounded, size: 16, color: _sortByModified ? AppTheme.white38 : AppTheme.accentIndigo),
                                const SizedBox(width: 10),
                                Text('По дате создания', style: AppTheme.bodyStyle.copyWith(color: _sortByModified ? AppTheme.white38 : AppTheme.white)),
                              ]),
                            ),
                            PopupMenuItem(
                              value: true,
                              child: Row(children: [
                                Icon(Icons.edit_calendar_rounded, size: 16, color: _sortByModified ? AppTheme.accentIndigo : AppTheme.white38),
                                const SizedBox(width: 10),
                                Text('По дате изменения', style: AppTheme.bodyStyle.copyWith(color: _sortByModified ? AppTheme.white : AppTheme.white38)),
                              ]),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Search mode
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.white08,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              autofocus: true,
                              style: AppTheme.bodyStyle.copyWith(color: AppTheme.white, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Поиск заметок...',
                                hintStyle: AppTheme.captionStyle.copyWith(fontSize: 14),
                                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.white38, size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onChanged: (v) => setState(() => _query = v.toLowerCase()),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _query = '';
                              _searchCtrl.clear();
                            });
                          },
                          child: Text('Отмена', style: AppTheme.captionStyle.copyWith(color: AppTheme.accentIndigo)),
                        ),
                      ],
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: Consumer<NotesProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.accentIndigo, strokeWidth: 2));
                      }

                      var notes = provider.notes;
                      if (_query.isNotEmpty) {
                        notes = notes.where((n) =>
                          n.title.toLowerCase().contains(_query) ||
                          n.content.toLowerCase().contains(_query)
                        ).toList();
                      }

                      if (notes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _query.isNotEmpty ? Icons.search_off_rounded : Icons.edit_note_rounded,
                                size: 72, color: AppTheme.white12,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _query.isNotEmpty ? 'Ничего не найдено' : 'Нет заметок',
                                style: AppTheme.bodyStyle.copyWith(color: AppTheme.white38),
                              ),
                              if (_query.isEmpty) ...[ 
                                const SizedBox(height: 8),
                                Text('Нажмите + чтобы добавить', style: AppTheme.captionStyle),
                              ],
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                        itemCount: notes.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _NoteCard(
                            note: notes[index],
                            sortByModified: _sortByModified,
                            index: index,
                            searchQuery: _query,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentIndigo,
        elevation: 0,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditNoteScreen()),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final bool sortByModified;
  final int index;
  final String searchQuery;

  const _NoteCard({
    required this.note,
    required this.sortByModified,
    required this.index,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final date = sortByModified ? note.updatedAt : note.createdAt;
    final dateStr = DateFormat('d MMM · HH:mm', 'ru').format(date);

    String preview = note.content;
    if (preview.isEmpty && note.todoItems != null && note.todoItems!.isNotEmpty) {
      final done = note.todoItems!.where((i) => i.isDone).length;
      preview = '$done / ${note.todoItems!.length} выполнено';
    }

    return MinimalCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditNoteScreen(note: note)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _HighlightText(
                  text: note.title,
                  query: searchQuery,
                  style: AppTheme.titleStyle.copyWith(fontSize: 16),
                  maxLines: 1,
                ),
              ),
              if (note.reminderDateTime != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.alarm_rounded, size: 15, color: AppTheme.accentGold.withValues(alpha: 0.8)),
                ),
            ],
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 8),
            _HighlightText(
              text: preview,
              query: searchQuery,
              style: AppTheme.bodyStyle.copyWith(fontSize: 13, height: 1.4),
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 14),
          Text(dateStr, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms).slideY(begin: 0.04, end: 0);
  }
}

// Highlights matching query text
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int maxLines;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(
          backgroundColor: AppTheme.accentGold.withValues(alpha: 0.3),
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ));
      start = idx + query.length;
    }

    return Text.rich(
      TextSpan(children: spans, style: style),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
