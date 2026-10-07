// lib/helpers/database_helper.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';

class DatabaseHelper {
  static const _databaseName = "MyNotes.db";
  static const _databaseVersion = 2;

  // ทำให้คลาสนี้เป็น Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // มี reference ไปยังฐานข้อมูลเพียงหนึ่งเดียว
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // หาก _database เป็น null จะทำการ initialize ให้
    _database = await _initDatabase();
    return _database!;
  }

  // เมธอดสำหรับเปิดฐานข้อมูล (หรือสร้างขึ้นใหม่ถ้ายังไม่มี)
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    print('Database path: $path'); // แสดง path ของฐานข้อมูลใน console
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate, // จะถูกเรียกเมื่อฐานข้อมูลถูกสร้างขึ้นครั้งแรก
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    print('onCreate ถูกเรียก: กำลังจะสร้างตาราง notes...');
    await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL
          created_at TEXT
        )
        ''');
    print('ตาราง notes ถูกสร้างแล้ว');
  }

  // ไล่ปรับจากเวอร์ชันที่อยู่ในเครื่องขึ้นมาทีละขั้น
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN created_at TEXT');
      print("ตาราง notes ถูก upgraded.");
    }
    // เวอร์ชันถัดไปให้เพิ่ม if (oldVersion < 3) ต่อท้ายตรงนี้
    // ห้ามแก้ขั้นที่ปล่อยให้ผู้ใช้ไปแล้ว เพราะมีเครื่องที่ผ่านขั้นนั้นไปแล้วจริง
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    // db.insert จะคืนค่า id ของแถวที่ถูกเพิ่มล่าสุด
    return await db.insert('notes', row);
  }

  // ภายในคลาส DatabaseHelper
  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert('notes', note.toMap());
  }

  Future<List<Note>> queryAllNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'id DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // ภายในคลาส DatabaseHelper
  // Read/Query
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    // db.query จะคืนค่าเป็น List ของ Map
    // orderBy ช่วยให้เราเรียงลำดับผลลัพธ์ (ในที่นี้คือเรียงตาม id จากมากไปน้อย)
    return await db.query('notes', orderBy: 'id DESC');
  }

  // ภายในคลาส DatabaseHelper
  // Update
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    // db.update จะคืนค่าจำนวนแถวที่ได้รับผลกระทบ
    return await db.update('notes', row, where: 'id = ?', whereArgs: [id]);
  }

  // ภายในคลาส DatabaseHelper
  // Delete
  Future<int> delete(int id) async {
    Database db = await instance.database;
    // db.delete จะคืนค่าจำนวนแถวที่ถูกลบ
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
