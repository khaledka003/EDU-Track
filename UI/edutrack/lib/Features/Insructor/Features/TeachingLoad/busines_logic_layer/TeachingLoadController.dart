import 'package:edutrack/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edutrack/Features/Insructor/Features/TeachingLoad/Data_layer/Model/TeachingLoadModel.dart';
import 'package:edutrack/Features/Insructor/Features/TeachingLoad/Data_layer/Service/TeachingLoadService.dart';
// استيراد السيرفس الخاص بجلب السنوات الديناميكية
import 'package:edutrack/Features/Employee/View_teaching_load/Data_layer/service/TeachingloadInstructor.dart';

class TeachingLoadController extends GetxController {
  // تعريف السيرفس
  final TeachingLoadService _service = TeachingLoadService();
  final TeachingloadInstructor _instructorService =
      TeachingloadInstructor(); // إضافة السيرفس هنا

  // متغيرات الحالة (Reactive)
  var isLoading = true.obs;
  var report = Rxn<TeachingLoadReportModel>();
  var errorMessage = ''.obs;
  var isLoadingYears = false.obs;

  // 🔥 تعديل المتغيرات لتتوافق تماماً مع الـ Dropdown الجديد والباك إند
  var selectedMonth = Rxn<int>(); // أصبح Rxn<int> ليقبل null (الفصل كامل)
  var selectedYear = "".obs; // أصبح String ليتوافق مع صيغة "2025-2026"
  var availableYears = <String>[].obs; // قائمة السنوات الديناميكية من السيرفر

  @override
  void onInit() {
    super.onInit();
    // 1. نجلب السنوات أولاً، وهي بدورها ستقوم باستدعاء fetchData تلقائياً بعد تحديد السنة الافتراضية
    fetchInitialYears();
  }

  // --- جلب السنوات الديناميكية من السيرفر ---
  Future<void> fetchInitialYears() async {
    try {
      isLoadingYears.value = true;
      final years = await _instructorService.getAvailableYears();

      if (years.isNotEmpty) {
        availableYears.assignAll(years);
        // نضع السنة الأولى كقيمة افتراضية (الأحدث دائماً)
        selectedYear.value = years.first;
      }

      // بعد إعداد السنوات بنجاح، نجلب بيانات التقرير الأولية
      await fetchData();
    } catch (e) {
      Get.snackbar("خطأ", "فشل تحميل السنوات الأكاديمية: $e");
      isLoading.value = false; // ننهي حالة اللودينغ العامة في حال الفشل
    } finally {
      isLoadingYears.value = false;
    }
  }

  // دالة موحدة لتحديث البيانات وتمريرها للواجهة (لتنفيذ controller.fetchData() مباشرة بالـ Dropdown)
  Future<void> fetchData() async {
    try {
      isLoading(true);
      errorMessage(''); // تصفير رسائل الخطأ

      // 1. قص نص السنة المستلمة (مثال: "2025-2026" تصبح "2025") وتحويلها لـ int
      int? yearInt;
      if (selectedYear.value.isNotEmpty) {
        String yearString = selectedYear.value.split('-').first;
        yearInt = int.tryParse(yearString);
      }

      // 2. تمرير المعاملات المفلترة (الشهر يقبل null والسنة int المجهزة)
      final result = await _service.getInstructorFullReport(
        box.read('user_id') ?? 0,
        month: selectedMonth.value,
        year: yearInt,
      );

      report.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // --- قفل النصاب ---
  Future<void> lockTeachingLoad({required int id, required int month}) async {
    try {
      isLoading.value = true;

      // استدعاء السيرفس وتمرير الشهر المختار بدقة لقفل النصاب المفلتر
      final result = await _service.confirmMonthlyLoad(
        userId: id,
        month: month,
      );

      // فحص حالة الاستجابة القادمة من الباك إند
      if (result['status'] == 'success') {
        Get.snackbar(
          "نجاح",
          result['message'] ?? "تم قفل النصاب لهذا الشهر بنجاح",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // إعادة جلب البيانات لتحديث حالة القفل بالواجهة (is_finished)
        fetchData();
      } else if (result['status'] == 'warning') {
        Get.snackbar(
          "تنبيه",
          result['message'] ?? "لا توجد محاضرات لتأكيدها",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل قفل النصاب: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- الحسابات (Getters) ---
  double get totalLecturesHours {
    return report.value?.totalCompletedHours ?? 0.0;
  }

  List<Object> get confirmedProjects {
    return report.value?.confirmedProjects ?? [];
  }

  // إذا كنت بحاجة لحساب إجمالي الساعات المنجزة للمشاريع فقط ديناميكياً
  double get totalProjectsHours {
    if (report.value == null) return 0.0;
    return report.value!.confirmedProjects.fold(0.0, (sum, item) {
      // نقوم بقص النص المستخرج من الـ time (مثال: "2 - 3") لأخذ الساعات المنجزة فقط
      String doneStr = item.time.split('-').first.trim();
      return sum + (double.tryParse(doneStr) ?? 0.0);
    });
  }

  // دالة لإعادة المحاولة (Retry) في حال فشل الاتصال
  void retry() => fetchData();

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "تنبيه",
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }
}
