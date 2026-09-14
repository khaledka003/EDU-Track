import 'package:edutrack/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edutrack/Features/Employee/CourseAllocation/Data_layer/service/CourseAllocationService.dart';

class AllocationController extends GetxController {
  // 1. استدعاء السيرفس الذي صممناه
  final CourseAllocationService _service = CourseAllocationService();

  var isLoading = false.obs;
  var isDataLoading = false.obs;

  var facultyCourses = <dynamic>[].obs;
  var facultyInstructors = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    // بمجرد تشغيل الكنترولر، منجيب البيانات بناءً على الموظف اللي سجل دخول
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      isDataLoading.value = true;

      final int? userId = box.read('user_id');
      final dynamic facultyIdRaw = box.read(
        'faculty_id',
      ); // قراءتها كـ dynamic أولاً

      print("--- Debug Storage ---");
      print("User ID from box: $userId");
      print("Faculty ID from box: $facultyIdRaw");

      if (userId == null || facultyIdRaw == null) {
        print("Error: Missing ID in storage");
        return;
      }

      int facultyId = int.parse(facultyIdRaw.toString());

      // طلب المدرسين (هاد شغال عندك بالـ Logs)
      final instRes = await _service.getInstructorsByEmployeeFaculty(userId);
      if (instRes.statusCode == 200) {
        facultyInstructors.value = instRes.data['data'] ?? [];
      }

      // طلب المقررات (تأكد من الـ Print هنا)
      print("Sending request to courses-by-faculty with ID: $facultyId");
      final courseRes = await _service.getCoursesByFaculty(facultyId);

      if (courseRes.statusCode == 200) {
        facultyCourses.value = courseRes.data['data'] ?? [];
        print("Courses loaded: ${facultyCourses.length}");
      }
    } catch (e) {
      print("Catch Error: $e");
    } finally {
      isDataLoading.value = false;
    }
  }

  Future<void> submitAllAllocations(
    List<Map<String, dynamic>> payloadList,
  ) async {
    try {
      isLoading.value = true;

      // إرسال القائمة كاملة كما يتوقع الـ API المعدل لديك
      final response = await _service.allocateInstructor(payloadList);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          "تم بنجاح",
          response.data['message'] ?? "تم حفظ التوزيع بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // هنا يمكنك تفريغ القوائم في الواجهة إذا رغبت
      } else {
        // في حال وجود تضارب (Error 400 من دجانغو)
        String errorMsg = response.data['message'] ?? "حدث خطأ في التوزيع";
        _showErrorDialog("تنبيه التضارب", errorMsg);
      }
    } catch (e) {
      _showErrorDialog("خطأ", "تعذر الاتصال بالسيرفر: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorDialog(String title, String msg) {
    Get.defaultDialog(
      title: title,
      content: Text(msg, textAlign: TextAlign.center),
      textConfirm: "موافق",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }
}
