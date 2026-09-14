import 'package:dio/dio.dart';

class EmployeeService {
  // ملاحظة: تأكد من رابط السيرفر الأساسي عندك
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api/",
      // زدنا الوقت لـ 10 ثواني متل الكود الشغال
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      // ضفنا الـ Headers الضرورية
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  // جلب الكل - التابع حافظت على اسمه
  Future<Response> getAllEmployees() async {
    return await _dio.get('employees/'); // الرابط من الـ urls.py
  }

  // إضافة موظف جديد (POST) - التابع حافظت على اسمه
  Future<Response> addEmployee(Map<String, dynamic> data) async {
    return await _dio.post(
      'register-employee/',
      data: data,
    ); // الرابط من الـ urls.py
  }

  // تعديل موظف (PUT) - التابع حافظت على اسمه
  Future<Response> updateEmployee(int userId, Map<String, dynamic> data) async {
    return await _dio.put(
      'manage-employee/$userId/',
      data: data,
    ); // الرابط من الـ urls.py
  }

  // حذف موظف (DELETE) - التابع حافظت على اسمه
  Future<Response> deleteEmployee(int userId) async {
    return await _dio.delete(
      'manage-employee/$userId/',
    ); // الرابط من الـ urls.py
  }

  // جلب الكليات (عشان الـ Dropdown) - التابع حافظت على اسمه
  Future<Response> getFaculties() async {
    try {
      // الـ try/catch هون ضروري مشان إذا علق السيرفر ما يضرب التطبيق
      return await _dio.get('faculties/');
    } catch (e) {
      print("Error in getFaculties: $e");
      rethrow;
    }
  }

  // إضافة كلية (للمستقبل)
}
