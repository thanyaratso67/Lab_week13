// lib/providers/todo_provider.dart
import 'package:flutter/foundation.dart';
import '../models/todos.dart';
import '../repositories/todo_repository.dart';
import '../services/api_service.dart';

class TodoProvider extends ChangeNotifier {
  TodoProvider(this._repository);
  final TodoRepository _repository;

  List<Todo> _todos = [];
  bool _isRefreshing = false;
  String? _errorMessage;
  DateTime? _lastSynced;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSynced => _lastSynced;

  Future<void> load() async {
    // 1. แสดงชุดในเครื่องก่อน
    _todos = await _repository.readCached();
    _isRefreshing = true;
    notifyListeners();

    // 2. ขอชุดใหม่ ถ้าไม่สำเร็จ ชุดเดิมยังอยู่บนจอ
    try {
      _todos = await _repository.refresh();
      _lastSynced = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
}

