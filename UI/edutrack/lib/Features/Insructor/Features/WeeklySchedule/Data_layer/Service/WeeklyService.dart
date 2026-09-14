import 'package:dio/dio.dart';

class WeeklyService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/', // عنوان السيرفر الأساسي
      connectTimeout: const Duration(seconds: 5),
    ),
  );

  Future<Map<String, dynamic>?> getWeeklySchedule(int instructorId) async {
    try {
      final response = await _dio.get(
        'schedule/instructor/weekly/$instructorId/',
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'];
      }
      return null;
    } on DioException catch (e) {
      // يمكنك تخصيص رسائل الخطأ هنا بناءً على e.type
      throw Exception("فشل الاتصال بالسيرفر: ${e.message}");
    }
  }
}
