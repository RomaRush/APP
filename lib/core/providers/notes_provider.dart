import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NotesProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notesJson = prefs.getString('notes_data');
      if (notesJson != null) {
        final List<dynamic> decoded = jsonDecode(notesJson);
        _notes = decoded.map((e) => Note.fromJson(e)).toList();
        // Sort by default: Created Descending
        _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      _error = 'Failed to load notes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    _notes.insert(0, note);
    notifyListeners();
    await _saveNotes();
  }

  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
      await _saveNotes();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await _saveNotes();
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_notes.map((n) => n.toJson()).toList());
      await prefs.setString('notes_data', encoded);
    } catch (e) {
      _error = 'Failed to save notes: $e';
      notifyListeners();
    }
  }

  void sortNotes({bool byDateModified = false}) {
    if (byDateModified) {
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } else {
      _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    notifyListeners();
  }
}
