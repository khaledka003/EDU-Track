import 'package:dio/dio.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/Data_layer/Model/FacultyModel.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/Data_layer/Model/Instructor.dart';

class InstructorApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  // 1. جلب قائمة المدرسين
  Future<List<Instructor>> fetchInstructors() async {
    try {
      final response = await _dio.get('instructors/');
      if (response.data['status'] == 'success') {
        List<dynamic> dataList = response.data['data'];
        return dataList.map((item) => Instructor.fromJson(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 2. إضافة مدرس جديد
  Future<bool> addInstructor(Map<String, dynamic> instructorData) async {
    try {
      final response = await _dio.post(
        "/register-instructor/",
        data: instructorData,
      );
      return response.data['status'] == 'success';
    } on DioException catch (e) {
      print("خطأ الباكند: ${e.response?.data}");
      return false;
    }
  }

  // 3. تحديث بيانات مدرس
  Future<bool> updateInstructor(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("/manage-instructor/$id/", data: data);
      return response.data['status'] == 'success';
    } on DioException catch (e) {
      print("خطأ التحديث: ${e.response?.data}");
      return false;
    }
  }

  // 4. حذف مدرس
  Future<bool> deleteInstructor(int id) async {
    try {
      final response = await _dio.delete("/manage-instructor/$id/");
      return response.data['status'] == 'success';
    } on DioException {
      return false;
    }
  }

  // جلب الكليات
  Future<List<FacultyModel>> fetchFaculties() async {
    try {
      final response = await _dio.get("faculties/");
      if (response.data['status'] == 'success') {
        var list = response.data['data'] as List;
        return list.map((e) => FacultyModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Failed to load faculties");
    }
  }

  // جلب الأقسام
  Future<List<String>> fetchDepartments(int facultyId) async {
    try {
      final response = await _dio.get("/faculties/$facultyId/departments/");
      if (response.data['status'] == 'success') {
        var list = response.data['data'] as List;
        return list.map((e) => e['name'].toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Failed to load departments");
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null && e.response?.data['message'] != null) {
      return e.response?.data['message'];
    }
    return "حدث خطأ غير متوقع في الاتصال بالسيرفر";
  }

  // أضف هذه الميثود داخل كلاس InstructorApiService
  Future<List<Instructor>> fetchInstructorsByFaculty(int employeeUserId) async {
    try {
      // تأكد من صحة مسار الـ URL في الـ urls.py عندك بالباكند
      final response = await _dio.get(
        'instructors-for-employee/$employeeUserId/',
      );

      if (response.data['status'] == 'success') {
        List<dynamic> dataList = response.data['data'];
        // ملاحظة: الـ API بيرجع instructor_id، تأكد أن الموديل Instructor.fromJson يتوافق مع أسماء الحقول
        return dataList.map((item) => Instructor.fromJson(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
