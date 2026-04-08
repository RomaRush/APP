class TodoItem {
  String text;
  bool isDone;

  TodoItem({required this.text, this.isDone = false});

  Map<String, dynamic> toJson() => {
    'text': text,
    'isDone': isDone,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    text: json['text'],
    isDone: json['isDone'],
  );
}

class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  List<TodoItem>? todoItems;
  DateTime? reminderDateTime;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.todoItems,
    this.reminderDateTime,
  });

  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    List<TodoItem>? todoItems,
    DateTime? reminderDateTime,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      todoItems: todoItems ?? this.todoItems,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'todoItems': todoItems?.map((e) => e.toJson()).toList(),
      'reminderDateTime': reminderDateTime?.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      todoItems: json['todoItems'] != null 
        ? (json['todoItems'] as List).map((e) => TodoItem.fromJson(e)).toList()
        : null,
      reminderDateTime: json['reminderDateTime'] != null
        ? DateTime.parse(json['reminderDateTime'])
        : null,
    );
  }
}
