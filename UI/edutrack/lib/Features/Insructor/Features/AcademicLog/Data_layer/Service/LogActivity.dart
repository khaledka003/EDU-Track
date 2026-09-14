// import 'package:dio/dio.dart';
// import 'package:edutrack/Features/Home/Features/AcademicLog/Data_layer/Model/LogActivityModel.dart';

// class ActivityService {
//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: 'http://127.0.0.1:8000/', // استبدله بـ IP السيرفر الحقيقي
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//     ),
//   );

//   // جعلنا التاريخ اختياري تماماً بوضع علامة استفهام ?
//   Future<List<LogActivityModel>> getActivities(
//     String userId, {
//     String? date,
//   }) async {
//     try {
//       Map<String, dynamic> queryParams = {};
//       if (date != null) {
//         queryParams['date'] = date;
//       }

//       final response = await _dio.get(
//         'http://127.0.0.1:8000/academic_log_manager/$userId/',
//         queryParameters: queryParams,
//       );

//       if (response.statusCode == 200) {
//         List data = response.data;
//         return data.map((json) => LogActivityModel.fromJson(json)).toList();
//       } else {
//         throw "فشل السيرفر في الرد: ${response.statusCode}";
//       }
//     } on DioException catch (e) {
//       throw e.message ?? "خطأ غير متوقع في الاتصال";
//     }
//   }
// }
import 'package:dio/dio.dart';

class ActivityService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // التعديل: غيرنا نوع المرجوع إلى Future<List<dynamic>> وحذفنا الـ Map
  Future<List<dynamic>> getActivities(String userId, {String? date}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (date != null) {
        queryParams['date'] = date;
      }

      final response = await _dio.get(
        'academic-log/$userId/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // نعيد البيانات كما جاءت من الجانغو (List of Maps)
        return response.data as List;
      } else {
        throw "فشل السيرفر في الرد: ${response.statusCode}";
      }
    } on DioException catch (e) {
      throw e.message ?? "خطأ غير متوقع في الاتصال";
    }
  }
}
