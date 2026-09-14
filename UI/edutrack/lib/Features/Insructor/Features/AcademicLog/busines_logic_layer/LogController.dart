import 'package:edutrack/Features/Insructor/Features/AcademicLog/Data_layer/Model/LogActivityModel.dart';
import 'package:edutrack/Features/Insructor/Features/AcademicLog/Data_layer/Service/LogActivity.dart';
// استيراد السيرفس الثانية لاستخدامها هنا
import 'package:edutrack/Features/Insructor/Features/DailyLectures/Data_layer/Service/LectureService.dart';
import 'package:edutrack/main.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class LogController extends GetxController {
  final ActivityService _logService = ActivityService(); // لجلب السجل
  final LectureService _attendanceService =
      LectureService(); // لتسجيل الحضور (استخدام مشترك)

  var selectedDate = DateTime.now().obs;
  var isLoading = false.obs;
  var activitiesList = <LogActivityModel>[].obs;

  // قراءة المعرفات من GetStorage
  final String userId = box.read("user_id").toString();
  final String? instructorId = box.read('user_id')?.toString();

  @override
  void onInit() {
    super.onInit();
    fetchAllActivities();
  }

  void _mapData(List response) {
    List<LogActivityModel> loadedData = [];
    for (var item in response) {
      try {
        loadedData.add(LogActivityModel.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        print("خطأ في تحليل العنصر: $e");
      }
    }
    activitiesList.assignAll(loadedData);
  }

  Future<void> fetchAllActivities() async {
    isLoading(true);
    try {
      var response = await _logService.getActivities(userId);
      _mapData(response);
    } catch (e) {
      Get.snackbar("خطأ", "فشل جلب كل السجلات");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchActivitiesForDate(DateTime date) async {
    isLoading(true);
    selectedDate.value = date;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    try {
      var response = await _logService.getActivities(
        userId,
        date: formattedDate,
      );
      _mapData(response);
    } catch (e) {
      activitiesList.clear();
      Get.snackbar("تنبيه", "لا توجد سجلات لهذا التاريخ");
    } finally {
      isLoading(false);
    }
  }

  void toggleStatus(int index) {
    activitiesList[index].isChecked.toggle();
  }

  // الدالة "المعقدة" بعد تبسيطها باستخدام السيرفس المشترك
  Future<void> saveChanges() async {
    // 1. تصفية العناصر التي تم اختيارها (Checked)
    var selectedToSave = activitiesList
        .where((item) => item.isChecked.value)
        .toList();

    if (selectedToSave.isEmpty) {
      Get.snackbar("تنبيه", "الرجاء اختيار محاضرة لتسجيل حضورها");
      return;
    }

    if (instructorId == null) {
      Get.snackbar("خطأ", "لم يتم العثور على معرف المدرس");
      return;
    }

    isLoading(true);
    int successCount = 0;
    bool hasConnectionError = false;

    try {
      for (var activity in selectedToSave) {
        // نستخدم دالة postAttendance من الـ LectureService مباشرة
        // ملاحظة: قمنا بتحويل id من String إلى int لأنه مطلوب في السيرفس
        bool result = await _attendanceService.postAttendance(
          int.parse(activity.id),
          int.parse(instructorId!),
        );

        if (result) {
          successCount++;
        } else {
          hasConnectionError = true;
        }
      }

      // إظهار النتيجة للمستخدم
      if (successCount > 0) {
        Get.snackbar(
          "نجاح",
          "تم تسجيل حضور ($successCount) نشاط بنجاح",
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
        // إعادة تحديث القائمة لمزامنة البيانات مع السيرفر
        fetchActivitiesForDate(selectedDate.value);
      } else if (hasConnectionError) {
        Get.snackbar(
          "فشل",
          "تعذر الاتصال بالسيرفر، حاول مرة أخرى",
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ غير متوقع أثناء الحفظ");
    } finally {
      isLoading(false);
    }
  }
}
