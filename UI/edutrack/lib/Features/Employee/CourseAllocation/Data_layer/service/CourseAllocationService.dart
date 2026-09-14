import 'package:dio/dio.dart';

class CourseAllocationService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/',
      headers: {
        'Content-Type': 'application/json', // التأكيد على إرسال JSON
        'Accept': 'application/json',
      },
    ),
  );

  Future<Response> allocateInstructor(dynamic body) async {
    try {
      // هنا الـ body سيتم إرساله كـ JSON Raw تماماً كما في Postman
      final response = await _dio.post(
        'courses/allocate/',
        data: body, // Dio هنا يحول الـ Map لـ JSON تلقائياً
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> getCoursesByFaculty(int facultyId) async {
    try {
      return await _dio.get('courses-by-faculty/$facultyId/');
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  // جلب المدرسين حسب ID الموظف (ليعرف كليته من الباك إند)
  Future<Response> getInstructorsByEmployeeFaculty(int employeeId) async {
    try {
      return await _dio.get('instructors-for-employee/$employeeId/');
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }
}
