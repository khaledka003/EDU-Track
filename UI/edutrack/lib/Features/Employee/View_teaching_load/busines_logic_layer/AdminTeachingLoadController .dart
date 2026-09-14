import 'package:edutrack/Features/Employee/View_teaching_load/Data_layer/service/TeachingloadInstructor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edutrack/main.dart';
import 'package:edutrack/Features/Insructor/Features/TeachingLoad/Data_layer/Model/TeachingLoadModel.dart';
import 'package:edutrack/Features/Insructor/Features/TeachingLoad/Data_layer/Service/TeachingLoadService.dart';

class AdminTeachingLoadController extends GetxController {
  final TeachingloadInstructor _instructorService = TeachingloadInstructor();
  final TeachingLoadService _teachingLoadService = TeachingLoadService();

  var facultyInstructors = [].obs; // قائمة المدرسين (Maps)
  var isLoadingInstructors = false.obs;
  var selectedInstructor = {}.obs;
  var selectedYear = "".obs;
  var availableYears = <String>[].obs;
  var isLoadingYears = false.obs;

  // التقرير باستخدام الموديل الخاص بك
  var report = Rxn<TeachingLoadReportModel>();
  var isLoadingReport = false.obs;
  // سنة افتراضية
  var selectedMonth = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchInstructors();
    fetchInitialYears();
  }

  Future<void> fetchInitialYears() async {
    try {
      isLoadingYears.value = true;
      final years = await _instructorService.getAvailableYears();

      if (years.isNotEmpty) {
        availableYears.assignAll(years);
        // نضع السنة الأولى كقيمة افتراضية مسبقة الاختيار (الأحدث دائماً حسب ترتيب الباك إند)
        selectedYear.value = years.first;
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل تحميل السنوات الأكاديمية: $e");
    } finally {
      isLoadingYears.value = false;
    }
  }

  Future<void> fetchReport() async {
    if (selectedInstructor.isEmpty) return;

    isLoadingReport.value = true;
    try {
      int instructorUserId = selectedInstructor['user_id'] ?? 0;

      String yearString = selectedYear.value
          .split('-')
          .first; // ستعطيك "2025" مثلاً

      // 2. تحويل النص المستخرج إلى int
      int? yearInt = int.tryParse(yearString);

      // 3. تمرير القيمة بعد التحويل للدالة
      final result = await _teachingLoadService.getInstructorFullReport(
        instructorUserId,
        month: selectedMonth.value,
        year: yearInt, // الآن تمرر int? متوافق تماماً مع تعريف الدالة
      );
      report.value = result;
    } catch (e) {
      Get.snackbar("تنبيه", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingReport.value = false;
    }
  }

  Future<void> fetchInstructors() async {
    isLoadingInstructors.value = true;
    try {
      int userId = box.read('user_id') ?? 0;
      final instRes = await _instructorService.getInstructorsByEmployeeFaculty(
        userId,
      );
      if (instRes.statusCode == 200) {
        facultyInstructors.value = instRes.data['data'] ?? [];
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoadingInstructors.value = false;
    }
  }

  // دالة اختيار المدرس وجلب تقريره (استخدام السيرفس والموديل تبعك)
  Future<void> selectInstructor(dynamic instructor) async {
    // تحديث القيمة فوراً لجعل الواجهة تتفاعل
    selectedInstructor.value = Map<String, dynamic>.from(instructor);

    report.value = null;
    await fetchReport();
    isLoadingReport.value = true;

    try {
      // تأكد من مفتاح الـ ID حسب شو عم يرجعلك الباك إند (user_id أو id)
      int instructorUserId = selectedInstructor['user_id'] ?? 0;

      final result = await _teachingLoadService.getInstructorFullReport(
        instructorUserId,
      );
      report.value = result;
    } catch (e) {
      Get.snackbar("تنبيه", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingReport.value = false;
    }
  }

  // متغير لحالة تحميل إرسال الإشعار (لمنع الضغط المتكرر)
  var isSendingNotification = false.obs;

  Future<void> sendNotificationToInstructor() async {
    if (selectedInstructor.isEmpty) return;

    isSendingNotification.value = true;
    try {
      int instructorUserId = selectedInstructor['user_id'] ?? 0;

      // 1. نقص النص لنأخذ سنة البدء فقط (مثلاً "2025") ونحولها لـ int
      int yearInt =
          int.tryParse(selectedYear.value.split('-').first) ??
          DateTime.now().year;

      // 2. نمرر القيمة الجاهزة للدالة
      bool success = await _instructorService.sendReminderToInstructor(
        userId: instructorUserId,
        month: selectedMonth.value,
        year: yearInt, // تمرير الـ int المتوافق هنا
      );

      if (success) {
        // إغلاق أي لودينغ وعرض الدايلوج الخرافي للنجاح
        _showSuccessDialog(
          instructorName: selectedInstructor['name'] ?? 'المدرس',
          period: selectedMonth.value == null
              ? "الفصل كامل"
              : "شهر ${selectedMonth.value}",
        );
      }
    } catch (e) {
      String cleanError = e.toString().replaceAll("Exception: ", "");
      // عرض دايلوج الخطأ الأنيق
      _showErrorDialog(errorMessage: cleanError);
    } finally {
      isSendingNotification.value = false;
    }
  }

  // 🌟 تصميم دايلوج النجاح الاحترافي
  void _showSuccessDialog({
    required String instructorName,
    required String period,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(
            maxWidth: 400,
          ), // مثالي لشاشات الويب والموبايل
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة النجاح مع خلفية دائرية متدرجة ونبض لطيف
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 3),
                ),
                child: const Icon(
                  Icons
                      .mark_email_read_rounded, // أيقونة تعبر عن وصول الرسالة/الإشعار
                  color: Color(0xFF2E7D32),
                  size: 45,
                ),
              ),
              const SizedBox(height: 20),

              // العنوان الرئيسي
              const Text(
                "تم إرسال التذكير بنجاح",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  fontFamily: 'Cairo', // أو الخط المستخدم بمشروعك
                ),
              ),
              const SizedBox(height: 12),

              // تفاصيل العملية داخل بطاقة أنيقة (Card)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  children: [
                    Text(
                      "المدرس: ${selectedInstructor["full_name"]}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF495057),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      " $period / ${selectedYear.value}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C757D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // زر الإغلاق الذكي الممتد
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "موافق",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true, // يغلق عند الضغط خارج النافذة
      transitionCurve: Curves.easeOutBack, // حركة دخول مطاطية سينمائية وجذابة
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  // 🌟 تصميم دايلوج الخطأ الأنيق
  void _showErrorDialog({required String errorMessage}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFCDD2), width: 3),
                ),
                child: const Icon(
                  Icons.gpp_bad_rounded,
                  color: Color(0xFFC62828),
                  size: 45,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "عذراً، حدث خطأ ما",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "إغلاق",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      transitionCurve: Curves.elasticIn,
    );
  }
}
