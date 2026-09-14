import 'package:dio/dio.dart';

class FacultyService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/', // تأكد من الـ IP الخاص بك

      connectTimeout: const Duration(seconds: 5),

      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // جلب كل الكليات

  Future<Response> getAllFaculties() async {
    return await _dio.get('faculties/');
  }

  // إضافة كلية جديدة

  Future<Response> addFaculty(Map<String, dynamic> data) async {
    return await _dio.post('add-faculty/', data: data);
  }

  // جلب أقسام كلية معينة

  Future<Response> getDepartmentsByFaculty(int facultyId) async {
    return await _dio.get('faculties/$facultyId/departments/');
  }

  // إضافة قسم جديد

  Future<Response> addDepartment(Map<String, dynamic> data) async {
    return await _dio.post('add-department/', data: data);
  }
}
