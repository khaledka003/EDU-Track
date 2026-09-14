import 'package:dio/dio.dart';

class EmployeeManagementService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          'http://127.0.0.1:8000/api/', // استبدله برابط السيرفر الأساسي المعتمد عندك
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Response?> getCoursesByFaculty(int facultyId) async {
    try {
      final response = await _dio.get('courses-by-faculty/$facultyId/');
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e); // قذف الخطأ ليتم معالجته في الكونترولر
    } catch (e) {
      throw 'حدث خطأ غير متوقع أثناء جلب المواد';
    }
  }

  Future<Response?> getInstructorsByEmployeeFaculty(int employeeId) async {
    try {
      final response = await _dio.get('instructors-for-employee/$employeeId/');
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e); // قذف الخطأ ليتم معالجته في الكونترولر
    } catch (e) {
      throw 'حدث خطأ غير متوقع أثناء جلب المدرسين';
    }
  }

  // دالة معالجة الأخطاء المعتمدة عندك
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final status = e.response?.statusCode;
      final serverMessage = e.response?.data?['message'];
      if (status == 404) return "عذراً، السجل غير موجود بالسيرفر (404).";
      if (status == 400) return serverMessage ?? "طلب غير صالحة (400).";
      if (status == 500) return "خطأ داخلي في السيرفر (500): $serverMessage";
      return "خطأ من السيرفر: $status";
    }
    return "لا يوجد اتصال بالسيرفر، تأكد من تشغيل الباك إند.";
  }

  // 1. جلب العطل الأكاديمية (تمت إضافة السلاش النهائي لتوافق Django)
  Future<Response?> getAcademicHolidays({int? month, int? year}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      return await _dio.get(
        'get/academic-holidays/',
        queryParameters: queryParams,
      );
    } on DioException catch (e) {
      return e.response;
    }
  }

  // 2. جلب المحاضرات/الفئات مع الفلاتر
  Future<Response?> getLectures({
    String? holidayDate,
    int? instructorId,
    dynamic courseId,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (holidayDate != null) queryParams['holiday_date'] = holidayDate;
      if (instructorId != null) queryParams['instructor_id'] = instructorId;
      if (courseId != null) queryParams['course_id'] = courseId;

      return await _dio.get('get/lectures/', queryParameters: queryParams);
    } on DioException catch (e) {
      return e.response;
    }
  }

  // 3. إدارة الفئة (تعديل كامل أو حذف)
  Future<Response?> manageLecture(
    int lectureId,
    String method, {
    Map<String, dynamic>? data,
  }) async {
    try {
      if (method.toUpperCase() == 'DELETE') {
        return await _dio.delete('manage-lectures/$lectureId/');
      } else {
        return await _dio.put('manage-lectures/$lectureId/', data: data);
      }
    } on DioException catch (e) {
      return e.response;
    }
  }

  // 4. إضافة محاضرة تعويضية
  Future<Response?> addCompensatoryLecture({
    required int courseAllocationId,
    required int roomId,
    required String lectureDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      return await _dio.post(
        'add-compensatory-lecture/',
        data: {
          'course_allocation_id': courseAllocationId,
          'room_id': roomId,
          'lecture_date': lectureDate,
          'start_time': startTime,
          'end_time': endTime,
        },
      );
    } on DioException catch (e) {
      return e.response;
    }
  }
}
