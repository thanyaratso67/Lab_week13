// lib/models/todo.dart
class Todo {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  const Todo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  // Factory constructor สำหรับสร้าง Todo instance จาก Map (JSON object)
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }

  
  // แปลงเป็นแถวของตาราง todos (หัวข้อ 13.7)
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completed': completed ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, Object?> map) {
    return Todo(
      userId: map['userId'] as int,
      id: map['id'] as int,
      title: map['title'] as String,
      completed: map['completed'] == 1,
    );
  }
}
