import 'package:dio/dio.dart';
import 'package:edutrack/main.dart';

class AuthService {
  // 1. تعديل الـ IP ليطابق جهازك الجديد (اللي اشتغل عليه البوست مان)

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000",
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<bool> loginUser(String phone, String password) async {
    // تغيير المسمى لـ phone
    try {
      Response response = await _dio.post(
        "/api/login/",
        data: {'phone_number': phone, 'password': password},
      );
      if (response.data['status'] == 'success') {
        await box.write('token', response.data['token']);
        await box.write('user_id', response.data['user_id']);
        await box.write('faculty_name', response.data['faculty_name'] ?? '');
        await box.write('faculty_id', response.data['faculty_id'] ?? '');
        await box.write('ins_id', response.data['instructor_id'] ?? '');

        print(box.read("user_id"));
        await box.write('role', response.data['role']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
