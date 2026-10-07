// lib/models/note.dart
class Note {
  final int? id; // null เมื่อยังไม่เคยบันทึก ฐานข้อมูลเป็นผู้กำหนดให้ตอน insert
  final String title;
  final String content;

  const Note({this.id, required this.title, required this.content});

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id, // ใส่ id เฉพาะเมื่อมีค่า
      'title': title,
      'content': content,
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
    );
  }
}
