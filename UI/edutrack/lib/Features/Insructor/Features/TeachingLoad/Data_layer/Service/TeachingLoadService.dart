import 'package:dio/dio.dart';
import 'package:edutrack/Features/Insructor/Features/TeachingLoad/Data_layer/Model/TeachingLoadModel.dart';

class TeachingLoadService {
  final Dio _dio = Dio(
    BaseOptions(
      // ملاحظة: 10.0.2.2 هو IP السيرفر المحلي لمحاكي أندرويد
      baseUrl: 'http://127.0.0.1:8000/api/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// جلب تقرير النصاب التدريسي لمدرس معين
  /// جلب تقرير النصاب التدريسي لمدرس معين مع فلترة اختيارية
  Future<TeachingLoadReportModel> getInstructorFullReport(
    int userId, {
    int? month,
    int? year,
  }) async {
    try {
      // بناء الـ query parameters
      Map<String, dynamic> queryParams = {};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        'instructor-report/$userId/',
        queryParameters: queryParams, // ديو لحاله رح يضيف ?month=5&year=2025
      );

      if (response.statusCode == 200 && response.data != null) {
        return TeachingLoadReportModel.fromJson(response.data);
      } else {
        throw 'بيانات التقرير غير متوفرة حالياً';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw 'حدث خطأ مفاجئ أثناء جلب البيانات';
    }
  }

  /// دالة معالجة الأخطاء (متل الخلق والناس)
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "فشل الاتصال: السيرفر لا يستجيب، تأكد من تشغيل الباك إند.";
      case DioExceptionType.sendTimeout:
        return "انتهت مهلة إرسال البيانات للسيرفر.";
      case DioExceptionType.receiveTimeout:
        return "السيرفر استغرق وقتاً طويلاً للرد (Timeout).";
      case DioExceptionType.badResponse:
        // هنا نستخرج رسالة الخطأ القادمة من الباك إند إن وجدت
        final status = e.response?.statusCode;
        if (status == 404)
          return "عذراً، لم يتم العثور على بيانات لهذا المدرس (404).";
        if (status == 500)
          return "خطأ داخلي في السيرفر، يرجى مراجعة الباك إند (500).";
        return "حدث خطأ غير متوقع من السيرفر: $status";
      case DioExceptionType.cancel:
        return "تم إلغاء عملية الاتصال بالسيرفر.";
      case DioExceptionType.connectionError:
        return "لا يوجد اتصال بالإنترنت أو السيرفر غير متاح.";
      default:
        return "حدث خطأ غير معروف في عملية الربط، حاول ثانية.";
    }
  }

  Future<Map<String, dynamic>> confirmMonthlyLoad({
    required int userId,
    required int month,
    int? year,
  }) async {
    try {
      // إذا لم يتم تمرير السنة، نأخذ السنة الحالية تلقائياً لتجنب الخطأ في الباك إند
      final int targetYear = year ?? DateTime.now().year;

      final response = await _dio.post(
        'confirm-load/$userId/', // الرابط حسب الـ URL المعرف في Django
        data: {'month': month, 'year': targetYear},
      );

      if (response.statusCode == 200 && response.data != null) {
        // الباك إند يرجع إما success أو warning
        return response.data as Map<String, dynamic>;
      } else {
        throw 'فشل في إتمام عملية التأكيد';
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw 'حدث خطأ غير متوقع أثناء تأكيد النصاب';
    }
  }
}
