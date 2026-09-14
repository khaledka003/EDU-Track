import 'package:dio/dio.dart';
import 'package:edutrack/Features/Admin/Features/CoursesManagement/Data_layer/Model/Course.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/Data_layer/Model/FacultyModel.dart';

class CourseApiService {
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

  // 1. جلب قائمة المقررات (دالة all_courses بالباكند)
  Future<List<Course>> fetchCourses() async {
    try {
      final response = await _dio.get("courses/");
      if (response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data.map((json) => Course.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("حدث خطأ أثناء جلب المقررات: $e");
    }
  }

  // 2. إضافة مقرر جديد (دالة add_course_api بالباكند)
  Future<bool> addCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _dio.post("courses/add/", data: courseData);
      return response.data['status'] == 'success';
    } on DioException catch (e) {
      // هذا السطر هو "عينك" داخل الباكند
      print("Backend Error Details: ${e.response?.data}");
      return false;
    }
  }

  // 3. حذف مقرر (دالة delete_course بالباكند)
  Future<bool> deleteCourse(String courseCode) async {
    try {
      final response = await _dio.delete("courses/delete/$courseCode/");
      return response.data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  // 4. تحديث مقرر (دالة manage_course بالباكند - PUT)
  Future<bool> updateCourse(
    String courseCode,
    Map<String, dynamic> courseData,
  ) async {
    try {
      final response = await _dio.put(
        "courses/manage/$courseCode/",
        data: courseData,
      );
      return response.data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  // 5. جلب الكليات
  Future<List<FacultyModel>> fetchFaculties() async {
    try {
      final response = await _dio.get("faculties/");
      if (response.data['status'] == 'success') {
        var list = response.data['data'] as List;
        return list.map((e) => FacultyModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 6. جلب الأقسام بناءً على الكلية
  Future<List<String>> fetchDepartments(int facultyId) async {
    try {
      final response = await _dio.get("faculties/$facultyId/departments/");
      if (response.data['status'] == 'success') {
        var list = response.data['data'] as List;
        return list.map((e) => e['name'].toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
