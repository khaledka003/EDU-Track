import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/main.dart';

class LectureService {
  final Dio dio = Dio();
  final String baseUrl = "http://127.0.0.1:8000/api/";

  // جلب محاضرات اليوم
  // عدل دالة fetchDailyLectures لتكون هكذا:
  Future<Map<String, dynamic>> fetchDailyLectures(int userId) async {
    try {
      String? token = box.read('token');
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      Response response = await dio.get(
        '${baseUrl}schedule/instructor/$userId/',
        queryParameters: {'date': today},
        options: Options(headers: {'Authorization': 'Token $token'}),
      );

      // نعيد الـ Map بالكامل كما جاء من البايثون
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // إرسال الحضور (POST)
  Future<bool> postAttendance(int lectureId, int instructorId) async {
    try {
      String? token = box.read('token');

      // الرابط المعدل بناءً على الـ URL Patterns الخاصة بك
      final String url = 'http://127.0.0.1:8000/api/check-attendance/';

      Response response = await dio.post(
        url,
        data: {'lecture_id': lectureId, 'instructor_id': instructorId},
        options: Options(
          headers: {'Authorization': 'Token $token'},
          // نطلب من Dio ألا يرمي خطأ إذا كان السيرفر رد بأي رقم (حتى نكشف الـ 404)
          validateStatus: (status) => status! < 500,
        ),
      );

      // التحقق من النتيجة الحقيقية
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return true;
      } else {
        print("فشل السيرفر: ${response.statusCode} - ${response.data}");
        return false;
      }
    } catch (e) {
      // إذا النت مقطوع، سيمسك الخطأ هنا فوراً ويرجع false للكنترولر
      print("خطأ اتصال (نت مقطوع): $e");
      return false;
    }
  }
}
