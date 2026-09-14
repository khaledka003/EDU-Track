import 'package:dio/dio.dart';
import 'package:edutrack/Features/Insructor/Features/Notifecation/data_layer/Model/NotificationResponseModel.dart';

class NotificationService {
  // استخدام الـ Dio Client الخاص بـ EduTrack
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api/",
      headers: {"Content-Type": "application/json"},
    ),
  );

  Future<NotificationResponseModel> getMyNotifications(int userId) async {
    try {
      // تعديل الـ Endpoint حسب المسار الفعلي بالباك إند
      final response = await _dio.get('user-notifications/$userId');

      if (response.statusCode == 200) {
        return NotificationResponseModel.fromJson(response.data);
      }
      throw Exception("فشل جلب الإشعارات");
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? "حدث خطأ في الاتصال";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("خطأ غير متوقع: $e");
    }
  }

  Future<bool> markAllAsRead(int notificationId) async {
    try {
      final response = await _dio.post(
        'user-notifications/$notificationId/mark-as-read/',
        data: {"notification_id": notificationId},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error marking notifications as read: $e");
      return false;
    }
  }
}
