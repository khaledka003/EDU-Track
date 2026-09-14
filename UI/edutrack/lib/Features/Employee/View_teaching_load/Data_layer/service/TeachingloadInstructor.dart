import 'package:dio/dio.dart';

class TeachingloadInstructor {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/'),
  ); // تأكد من الـ BaseUrl

  Future<Response> getInstructorsByEmployeeFaculty(int employeeId) async {
    try {
      return await _dio.get('instructors-for-employee/$employeeId/');
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<bool> sendReminderToInstructor({
    required int userId,
    required int? month,
    required int year,
  }) async {
    try {
      // الـ API يتوقع رقم شهر صريح، إذا كان الفصل كامل (null) يفضل إرسال قيمة افتراضية أو معالجتها
      // هنا نقوم بتمرير 0 أو قيمة تعبر عن "الفصل كامل" إذا كان الشهر null لتجنب الـ 400 Bad Request
      final int finalMonth = month ?? 0;

      final response = await _dio.post(
        'send-reminder/', // استبدل المسار بالـ Endpoint الصحيحة تماماً عندك
        data: {"user_id": userId, "month": finalMonth, "year": year},
      );

      // الـ API يرجع 201 في حال النجاح (Created) كما هو مكتوب بكود الباك إند
      if (response.statusCode == 201) {
        return true;
      }

      return false;
    } on DioException catch (e) {
      // جلب رسالة الخطأ القادمة من الباك إند إن وجدت
      String errorMessage = "حدث خطأ غير متوقع";
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      // رمي الاستثناء ليتم التقاطه في الـ Controller وعرضه بالـ Snackbar
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("فشل الاتصال بالسيرفر: $e");
    }
  }

  Future<List<String>> getAvailableYears() async {
    try {
      final response = await _dio.get(
        'get/available-years/',
      ); // تأكد من مطابقة الرابط بالباك إند

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          // تحويل قائمة الديناميك القادمة من السيرفر إلى List<String>
          List<dynamic> yearsData = response.data['years'];
          return yearsData.map((e) => e.toString()).toList();
        } else {
          throw response.data['message'] ?? 'فشل في جلب السنوات الأكاديمية';
        }
      } else {
        throw 'السيرفر لم يستجب بشكل صحيح';
      }
    } on DioException catch (e) {
      throw (e);
    } catch (e) {
      throw 'حدث خطأ غير متوقع أثناء جلب السنوات الأكاديمية';
    }
  }
}
