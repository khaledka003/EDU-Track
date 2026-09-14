import 'package:dio/dio.dart';

class AcademicService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          "http://127.0.0.1:8000/api/", // استخدم IP جهازك أو 10.0.2.2 للأندرويد إيموليتر
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  // افتتاح سنة
  Future<Response> openYear(String yearName) async {
    return await _dio.post(
      "academic-years/open/",
      data: {"yearName": yearName},
    );
  }

  Future<Response> getYears() async {
    return await _dio.get("get/academic-years/");
  }

  // افتتاح فصل
  Future<Response> openSemester(Map<String, dynamic> data) async {
    return await _dio.post("semesters/open/", data: data);
  }

  // أضف هذه الدالة للسيرفس
  Future<Response> getAllSemesters() async {
    return await _dio.get(
      "get/academic-years/",
    ); // تأكد أن هذا الرابط موجود في urls.py
  }

  // تحديث فصل
  Future<Response> updateSemester(int id, Map<String, dynamic> data) async {
    return await _dio.put("semesters/update/$id/", data: data);
  }
}
