// lib/screens/todo_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    // load() เรียก notifyListeners() ทันที จึงเลื่อนไปหลังเฟรมแรก (หัวข้อ 12.8)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TodoProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final hasData = provider.todos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos (offline-first)'),
        // สถานะที่สี่: มีข้อมูลและกำลังรีเฟรช แสดงแถบบาง ๆ ใต้ AppBar
        bottom: hasData && provider.isRefreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: _buildBody(provider, hasData),
    );
  }

  Widget _buildBody(TodoProvider provider, bool hasData) {
    // ไม่มีข้อมูลและกำลังรีเฟรช: เปิดแอปครั้งแรก
    if (!hasData && provider.isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }
    // ไม่มีข้อมูลและรีเฟรชไม่สำเร็จ: ข้อความผิดพลาดพร้อมปุ่มลองใหม่เต็มหน้า
    if (!hasData && provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: provider.load,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }
    // มีข้อมูล: แสดงรายการเดิมเสมอ ถ้ารีเฟรชไม่สำเร็จให้มีแถบบอกที่มาของข้อมูล
    return Column(
      children: [
        if (provider.errorMessage != null)
          MaterialBanner(
            content: Text(
              'แสดงข้อมูล${_syncedText(provider.lastSynced)}\n'
              '${provider.errorMessage}',
            ),
            actions: [
              TextButton(
                onPressed: provider.load,
                child: const Text('ลองใหม่'),
              ),
            ],
          ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.todos.length,
            itemBuilder: (context, index) {
              final todo = provider.todos[index];
              return CheckboxListTile(
                value: todo.completed,
                onChanged: null, // แสดงอย่างเดียว ไม่ให้แก้ไข
                title: Text(todo.title),
              );
            },
          ),
        ),
      ],
    );
  }

  // lastSynced เป็น null เมื่อเปิดแอปใหม่แล้วยังซิงก์ไม่สำเร็จเลย
  String _syncedText(DateTime? synced) {
    if (synced == null) return 'ที่บันทึกไว้ในเครื่องจากครั้งก่อน';
    return 'เมื่อ ${TimeOfDay.fromDateTime(synced).format(context)}';
  }
}

