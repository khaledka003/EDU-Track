import 'package:edutrack/Features/Insructor/Features/ExamAssignment/Data_layer/Model/ExamModel.dart';
import 'package:edutrack/Features/Insructor/Features/ExamAssignment/Data_layer/Service/ExamsService.dart';
import 'package:edutrack/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExamsController extends GetxController {
  final ExamsService _service = ExamsService();

  RxList<ExamModel> examsList = <ExamModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadExams(); // جلب البيانات عند تشغيل الكنترولر
  }

  Future<void> loadExams() async {
    isLoading.value = true;
    try {
      var fetchedExams = await _service.fetchExams(box.read("user_id"));
      examsList.assignAll(fetchedExams);
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void toggleStatus(int index) {
    examsList[index].isChecked.toggle();
  }

  // داخل ExamsController
  void saveExams() async {
    isLoading.value = true;
    int instructorId = box.read("user_id");

    // نفلتر المراقبات اللي المدرس حددها (الصح)
    var selectedExams = examsList.where((e) => e.isChecked.value).toList();

    if (selectedExams.isEmpty) {
      Get.snackbar("تنبيه", "لم تقم بتحديد أي مراقبة لتأكيد حضورها");
      isLoading.value = false;
      return;
    }

    try {
      for (var exam in selectedExams) {
        bool success = await _service.confirmAttendance(
          examDutyId: exam.id,
          instructorId: instructorId,
          courseCode: exam.course,
        );
        if (!success) throw Exception("فشل تأكيد حضور المادة: ${exam.course}");
      }

      Get.snackbar(
        "نجاح",
        "تم تأكيد حضور المراقبات المحددة بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // إعادة تحميل البيانات لتحديث الحالة من السيرفر
      loadExams();
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
