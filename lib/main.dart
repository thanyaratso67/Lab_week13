// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/app_database.dart';
import 'providers/todo_provider.dart';
import 'repositories/todo_repository.dart';
import 'screen/todo_list_screen.dart';

Future<void> main() async {
  // ต้องเรียกก่อนใช้ plugin ใด ๆ ก่อน runApp เพราะ sqflite ต้องคุยกับฝั่งแพลตฟอร์ม
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openAppDatabase(); // เปิดครั้งเดียวตลอดอายุของแอป

  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(TodoRepository(db)),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Offline-first Todos',
      home: TodoListScreen(),
    );
  }
}

