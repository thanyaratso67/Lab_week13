// lib/services/api_service.dart (คัดลอกฉบับรับมือความล้มเหลวจากหัวข้อ 12.6 มาทั้งไฟล์)
import 'dart:async'; // สำหรับ TimeoutException
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todos.dart';

// ข้อผิดพลาดที่แอปเข้าใจเอง พร้อมข้อความที่นำไปแสดงต่อผู้ใช้ได้ทันที
class ApiException implements Exception {
  final String message; // ข้อความภาษาคน ไม่ใช่ข้อความของระบบ
  final bool canRetry;  // ปุ่มลองใหม่ควรมีประโยชน์หรือไม่
  const ApiException(this.message, {this.canRetry = true});

  @override
  String toString() => message;
}

Future<List<Todo>> fetchTodos() async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/todos');
  try {
    // http ไม่มี timeout ให้โดยปริยาย ต้องกำหนดเองทุกคำขอ
    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => Todo.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (response.statusCode >= 500) {
      // ผิดที่ฝั่งเซิร์ฟเวอร์ การลองใหม่มีโอกาสสำเร็จ
      throw const ApiException('เซิร์ฟเวอร์ขัดข้องชั่วคราว โปรดลองอีกครั้ง');
    }
    // 4xx คือคำขอของเราเองไม่ถูกต้อง ลองใหม่ด้วยคำขอเดิมก็ได้ผลเดิม
    throw ApiException(
      'ไม่พบข้อมูลที่ร้องขอ (รหัส ${response.statusCode})',
      canRetry: false,
    );
  } on TimeoutException {
    throw const ApiException('เซิร์ฟเวอร์ตอบกลับช้าเกินไป โปรดลองอีกครั้ง');
  } on FormatException {
    // คำตอบไม่ใช่ JSON เช่นโดนหน้าล็อกอินของเครือข่ายขั้นกลางคั่นไว้
    throw const ApiException('รูปแบบข้อมูลที่ได้รับไม่ถูกต้อง', canRetry: false);
  } on ApiException {
    rethrow; // โยนต่อ ไม่ให้ตัวดักบรรทัดล่างกลืนข้อความที่เราตั้งใจไว้
  } catch (_) {
    // เหลือกรณีต่อไม่ติด เช่นไม่มีสัญญาณ หรือหาชื่อโฮสต์ไม่พบ
    throw const ApiException('เชื่อมต่ออินเทอร์เน็ตไม่ได้ โปรดตรวจสอบการเชื่อมต่อ');
  }
}

