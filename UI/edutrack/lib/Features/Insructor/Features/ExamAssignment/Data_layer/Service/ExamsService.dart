import 'package:dio/dio.dart';
// تأكد من مطابقة المسار التالي لمجلد مشروعك الفعلي
import 'package:edutrack/Features/Insructor/Features/ExamAssignment/Data_layer/Model/ExamModel.dart';

class ExamsService {
  // تعريف Dio مع الإعدادات الأساسية
  Dio dio = Dio();

  // دالة جلب البيانات باستخدام الـ ID
  Future<List<ExamModel>> fetchExams(int instructorId) async {
    try {
      final response = await dio.get(
        "http://127.0.0.1:8000/api/schedule_exams/instructor/$instructorId/",
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          List<dynamic> data = response.data['data'];
          return data.map((json) => ExamModel.fromJson(json)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      rethrow;
    } catch (e) {
      print("General Error: $e");
      rethrow;
    }
  }

  // داخل ExamsService
  Future<bool> confirmAttendance({
    required int examDutyId,
    required int instructorId,
    required String courseCode, // أضفنا هذا المتغير
  }) async {
    try {
      final response = await dio.post(
        "http://127.0.0.1:8000/api/check-exam-attendance/",
        data: {
          "exam_duty_id": examDutyId,
          "instructor_id": instructorId,
          "course_code": courseCode, // إرسال الكود للباك إند
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error confirming attendance: $e");
      return false;
    }
  }
}
