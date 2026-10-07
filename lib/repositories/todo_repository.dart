// lib/repositories/todo_repository.dart
import 'package:sqflite/sqflite.dart';
import '../models/todos.dart';
import '../services/api_service.dart';

class TodoRepository {
  TodoRepository(this._db);
  final Database _db;

  // อ่านชุดที่เก็บไว้ในเครื่อง ได้ทันทีแม้ไม่มีสัญญาณ
  Future<List<Todo>> readCached() async {
    final rows = await _db.query('todos', orderBy: 'id');
    return rows.map(Todo.fromMap).toList();
  }

  // ดึงชุดใหม่ เขียนทับในเครื่อง แล้วคืนสิ่งที่อยู่ในเครื่อง
  Future<List<Todo>> refresh() async {
    final fresh = await fetchTodos(); // ชั้นเครือข่ายจากหัวข้อ 12.6
    await _db.transaction((txn) async {
      await txn.delete('todos');
      final batch = txn.batch();
      for (final todo in fresh) {
        batch.insert('todos', todo.toMap());
      }
      await batch.commit(noResult: true);
    });
    return readCached(); // หน้าจอเห็นเฉพาะสิ่งที่อยู่ในฐานข้อมูล
  }
}

