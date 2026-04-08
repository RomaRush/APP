import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/note.dart';
import '../../core/providers/notes_provider.dart';
import '../../core/theme/app_theme.dart';
import 'edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _sortByModified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
           // Background
           Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg_dark.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Заметки',
                            style: AppTheme.headlineStyle.copyWith(fontSize: 28),
                          ),
                        ],
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          popupMenuTheme: PopupMenuThemeData(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: PopupMenuButton<bool>(
                          icon: const Icon(Icons.sort, color: Colors.white),
                          offset: const Offset(0, 50),
                          elevation: 0,
                          onSelected: (bool sortByModified) {
                            setState(() {
                              _sortByModified = sortByModified;
                            });
                            context.read<NotesProvider>().sortNotes(byDateModified: sortByModified);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: false,
                              child: Text('По дате создания', style: TextStyle(color: Colors.white)),
                            ),
                            PopupMenuItem(
                              value: true,
                              child: Text('По дате изменения', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // List
                Expanded(
                  child: Consumer<NotesProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.amber));
                      }
                      
                      if (provider.notes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_note, size: 80, color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text(
                                'Нет заметок',
                                style: AppTheme.bodyStyle.copyWith(color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      }
            
                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
                        itemCount: provider.notes.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final note = provider.notes[index];
                          return _buildNoteCard(context, note);
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
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditNoteScreen()),
          );
        },
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    final date = _sortByModified ? note.updatedAt : note.createdAt;
    final dateStr = DateFormat('dd MMM HH:mm', 'ru').format(date);
    
    // Preview content logic
    String preview = note.content;
    if (preview.isEmpty && note.todoItems != null && note.todoItems!.isNotEmpty) {
       final done = note.todoItems!.where((i) => i.isDone).length;
       preview = '${done}/${note.todoItems!.length} выполнено';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (note.reminderDateTime != null)
                   Icon(Icons.alarm, size: 16, color: Colors.amber.withValues(alpha: 0.8)),
              ],
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                preview,
                style: AppTheme.bodyStyle.copyWith(color: Colors.white70, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              dateStr,
              style: TextStyle(color: Colors.white30, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
