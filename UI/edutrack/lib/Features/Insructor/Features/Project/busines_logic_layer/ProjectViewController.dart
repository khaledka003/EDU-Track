import 'package:edutrack/Features/Insructor/Features/Project/data_layer/Model/ProjectListResponse.dart';
import 'package:edutrack/Features/Insructor/Features/Project/data_layer/service/ProjectViewService.dart';
import 'package:edutrack/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectViewController extends GetxController {
  final ProjectViewService _service = ProjectViewService();

  final int instructorId = box.read("ins_id");

  var isLoading = false.obs;
  var isSavingSession =
      false.obs; // 🔥 مراقبة حالة حفظ الجلسة لمنع النقرات المتعددة
  var projectList = <ProjectModel>[].obs;
  var totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInstructorProjects();
  }

  void fetchInstructorProjects() async {
    try {
      isLoading.value = true;
      final response = await _service.getProjectsByInstructor(instructorId);

      if (response.statusCode == 200) {
        final parsedData = ProjectListResponse.fromJson(response.data);
        if (parsedData.status == 'success') {
          projectList.value = parsedData.projects;
          totalCount.value = parsedData.count;
        }
      } else {
        Get.snackbar("تنبيه", "فشل جلب مشاريع الدكتور من السيرفر");
      }
    } catch (e) {
      Get.snackbar("خطأ اتصال", "حدث خطأ غير متوقع: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // 🔥 التابع الجديد لربط الحفظ مع السيرفر وتمرير النتائج بدقة للـ UI
  Future<bool> saveProjectSession({
    required int projectId,
    required String sessionDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      isSavingSession.value = true;

      final response = await _service.recordProjectSession(
        projectId: projectId,
        sessionDate: sessionDate,
        startTime: startTime,
        endTime: endTime,
      );

      // فحص حالة النجاح
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.data['status'] == 'success') {
        Get.snackbar(
          "تم التسجيل بنجاح",
          response.data['message'] ?? "تم حجز وتثبيت الجلسة بنجاح.",
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return true; // العملية نجحت
      } else {
        Get.snackbar(
          "لم يتم التسجيل",
          response.data['message'] ??
              "تعذر تسجيل الجلسة بسبب تضارب في المواعيد.",
          backgroundColor: Colors.amber.shade900,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      // في حال كانت مكتبة الـ API ترمي خطأ (DioException كمثال) عند الـ 400 Bad Request
      String errorMessage = "تعذر الاتصال بالسيرفر";

      // إذا كنت تستخدم Dio يمكنك استخراج رسالة الخطأ القادمة من الباك إند هنا
      // مثال: if (e is DioException) errorMessage = e.response?.data['message'] ?? errorMessage;

      Get.snackbar(
        "خطأ في العملية",
        e.toString().contains("400")
            ? "تضارب في المواعيد أو تجاوز سقف الساعات!"
            : errorMessage,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isSavingSession.value = false;
    }
  }
}
