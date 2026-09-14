// lib/services/system_service.dart
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class Roomservice {
  final box = GetStorage();
  final Dio _dio = Dio();

  // الحصول على الـ Headers مع التوكن

  Future<Map<String, dynamic>> getAllRooms() async {
    try {
      final response = await _dio.get(
        'http://127.0.0.1:8000/api/rooms/get/',
      ); // عدل المسار حسب السيرفر
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // خدمات الغرف
  Future<Response> addRoom(Map<String, dynamic> data) async {
    return await _dio.post('http://127.0.0.1:8000/api/rooms/add/', data: data);
  }

  Future<Map<String, dynamic>> updateRoom(
    int roomId,
    Map<String, dynamic> data,
  ) async {
    try {
      // نرسل الطلب إلى الرابط الذي يحتوي على الـ room_id
      final response = await _dio.put(
        'http://127.0.0.1:8000/api/manage-room/$roomId/',
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // حذف قاعة (Delete)
  Future<Map<String, dynamic>> deleteRoom(int roomId) async {
    try {
      // نرسل طلب DELETE إلى نفس الرابط مع الـ room_id
      final response = await _dio.delete(
        'http://127.0.0.1:8000/api/manage-room/$roomId/',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
