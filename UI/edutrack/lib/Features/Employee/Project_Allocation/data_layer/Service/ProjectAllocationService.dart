import 'package:dio/dio.dart';

class ProjectAllocationService {
  // تعريف كائن الـ Dio
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api/", // ضع رابط السيرفر الأساسي هنا
      connectTimeout: const Duration(seconds: 10), // وقت انتهاء الاتصال
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // دالة إرسال طلب إسناد المشروع
  Future<Response> allocateProject(Map<String, dynamic> projectData) async {
    try {
      // إرسال طلب POST للباك آند المكتوب بالـ Django
      final response = await _dio.post('add-project/', data: projectData);
      return response;
    } on DioException catch (e) {
      // في حال حدوث خطأ من السيرفر (مثل 400 أو 404 أو 500) مرر الاستجابة للكنترولر ليعالجها
      if (e.response != null) {
        return e.response!;
      }
      // في حال كان الخطأ شبكة أو عدم القدرة على الوصول للسيرفر
      throw Exception(e.message ?? "فشل الاتصال بالسيرفر، تحقق من الإنترنت.");
    }
  }

  Future<Response> getInstructorsByEmployeeFaculty(int employeeId) async {
    try {
      return await _dio.get('instructors-for-employee/$employeeId/');
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> getDepartmentsByFaculty(int facultyId) async {
    return await _dio.get('faculties/$facultyId/departments/');
  }

  Future<Response> deleteProject(int projectId) async {
    try {
      // إرسال طلب DELETE للباك آند ممرراً الـ ID في الرابط كما هو متوقع في الـ Django
      final response = await _dio.delete('delete-project/$projectId/');
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      }
      throw Exception(e.message ?? "فشل الاتصال بالسيرفر، تحقق من الشبكة.");
    }
  }
}
