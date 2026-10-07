// lib/data/app_database.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// เปิดไฟล์ฐานข้อมูลของแอป และสร้างตาราง todos ในครั้งแรกที่ไฟล์ถูกสร้าง
Future<Database> openAppDatabase() async {
  final path = join(await getDatabasesPath(), 'todos.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      // id มาจากเซิร์ฟเวอร์ จึงไม่ใช้ AUTOINCREMENT
      return db.execute('''
        CREATE TABLE todos (
          id INTEGER PRIMARY KEY,
          userId INTEGER NOT NULL,
          title TEXT NOT NULL,
          completed INTEGER NOT NULL
        )
      ''');
    },
  );
}

