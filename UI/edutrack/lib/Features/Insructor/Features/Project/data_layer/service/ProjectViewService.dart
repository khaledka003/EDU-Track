import 'package:dio/dio.dart';

class ProjectViewService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/', // ضع رابط السيرفر الأساسي هنا
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // جلب كافة المشاريع المسجلة بالنظام
  Future<Response> getProjectsByInstructor(int instructorId) async {
    try {
      final response = await _dio.get('instructor-projects/$instructorId/');
      return response;
    } on DioException catch (e) {
      throw Exception(
        e.message ?? "فشل الاتصال بالسيرفر أثناء جلب مشاريع الدكتور",
      );
    }
  }

  // 🔥 التابع الجديد: إرسال بيانات الجلسة المقترحة إلى الباك إند
  Future<Response> recordProjectSession({
    required int projectId,
    required String sessionDate, // صيغة YYYY-MM-DD
    required String startTime, // صيغة HH:MM:SS
    required String endTime, // صيغة HH:MM:SS
  }) async {
    try {
      final response = await _dio.post(
        'record-project-session/', // تأكد من مطابقة الـ الـ URL عندك بالـ urls.py
        data: {
          'project_id': projectId,
          'session_date': sessionDate,
          'start_time': startTime,
          'end_time': endTime,
        },
      );
      return response;
    } on DioException catch (e) {
      // إرجاع الـ response حتى لو كان 400 Bad Request لنتمكن من قراءة رسالة الخطأ المخصصة من الباك
      if (e.response != null) {
        return e.response!;
      }
      throw Exception(e.message ?? "فشل الاتصال بالسيرفر أثناء تسجيل الجلسة");
    }
  }
}
