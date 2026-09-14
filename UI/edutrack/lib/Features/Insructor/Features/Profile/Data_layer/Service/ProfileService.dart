import 'package:dio/dio.dart';
import 'package:edutrack/Features/Insructor/Features/Profile/Data_layer/Model/ProfileModel.dart';
import 'package:get_storage/get_storage.dart';

class ProfileService {
  final Dio _dio = Dio();
  final box = GetStorage();

  // أضفنا علامة الاستفهام ليقبل الـ null في حال الخطأ
  Future<ProfileModel?> fetchProfileData() async {
    try {
      // 1. جلب الـ ID المخزن
      int? userId = box.read('user_id');

      if (userId == null) {
        print("Error: User ID is null in GetStorage");
        return null;
      }

      // 2. طلب البيانات من السيرفر
      final response = await _dio.get(
        "http://127.0.0.1:8000/api/profile/$userId/",
      );

      // 3. التحقق من حالة الرد وتحويله للموديل
      if (response.data['status'] == 'success') {
        // هنا السر: لازم تستخدم ProfileModel.fromJson
        return ProfileModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      print("Error fetching profile from Service: $e");
      return null;
    }
  }
}
