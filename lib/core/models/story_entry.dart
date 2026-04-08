import 'dart:io';

class StoryEntry {
  final File file;
  final DateTime timestamp;

  StoryEntry({
    required this.file,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': file.path,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory StoryEntry.fromJson(Map<String, dynamic> json) {
    return StoryEntry(
      file: File(json['path']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
