import 'package:dio/dio.dart';

class ExamDutyService {
  static final Dio _dio = Dio();
  // تأكد من وضع الـ Base URL الصحيح هنا أو استخدامه من كلاس الإعدادات
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // جلب مدرسي الكلية بناءً على معرف الموظف (أو الكلية)
  static Future<Response> getInstructorsByFaculty(int employeeId) async {
    try {
      return await _dio.get('$baseUrl/instructors-for-employee/$employeeId/');
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> submitExamDuty({
    required String courseCode,
    required String examDate,
    required String startTime, // إضافة وقت البدء
    required String endTime, // إضافة وقت النهاية
    required int roomId,
    required List<int> instructorIds,
  }) async {
    try {
      final response = await _dio.post(
        "$baseUrl/exams/assign-duties/",
        data: {
          "course_code": courseCode,
          "exam_date": examDate,
          "start_time": startTime, // إرسال الوقت الجديد
          "end_time": endTime, // إرسال الوقت الجديد
          "room_id": roomId,
          "instructors": instructorIds,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return {
        "status": "error",
        "message": e.response?.data['message'] ?? e.message,
      };
    }
  }
}
