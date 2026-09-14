import 'package:edutrack/Features/Insructor/Features/DailyLectures/Data_layer/Model/LectureModel.dart';
import 'package:edutrack/Features/Insructor/Features/DailyLectures/Data_layer/Service/LectureService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edutrack/main.dart';

class LecturesController extends GetxController {
  final LectureService _service = LectureService();

  // قائمة المحاضرات (RxList لمراقبة التغييرات)
  RxList<LectureModel> lecturesList = <LectureModel>[].obs;

  // متغيرات الحالات المختلفة
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxBool isEmpty = false.obs;

  // الرسالة القادمة من السيرفر (عطلة، خارج الفصل، إلخ)
  RxString serverMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onReady() {
    super.onReady();
    // هذه تعمل في كل مرة تظهر فيها الشاشة للمستخدم (إذا كان الكنترولر موجوداً)
    // أو بمجرد أن تصبح الواجهة جاهزة
    loadInitialData();
  }

  // دالة تحميل البيانات الأولية
  void loadInitialData() {
    var id = box.read('user_id');
    print(
      "DEBUG: Checking user_id in storage: $id",
    ); // للتأكد في الـ Debug Console

    if (id != null) {
      getAllLectures(int.parse(id.toString()));
    } else {
      print("DEBUG: user_id is NULL");
      hasError(true); // نعتبرها حالة خطأ لعدم وجود هوية للمستخدم
    }
  }

  // دالة جلب المحاضرات من السيرفر
  // داخل ملف LecturesController.dart

  Future<void> getAllLectures(int id) async {
    try {
      isLoading(true);
      hasError(false);
      isEmpty(false);

      // نمرر الـ id للسيرفس (التاريخ سيُحسب داخل السيرفس عند الاستدعاء)
      var response = await _service.fetchDailyLectures(id);

      // تحديث الرسالة القادمة من الباك إند (عطلة، خارج الفصل، إلخ)
      serverMessage.value = response['message'] ?? "";

      List rawData = response['data'] ?? [];

      if (rawData.isEmpty) {
        isEmpty(true);
        lecturesList.clear();
      } else {
        isEmpty(false);
        lecturesList.assignAll(
          rawData.map((json) => LectureModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  // تبديل حالة المحاضرة (تم إعطاؤها أم لا)
  void toggleStatus(int index) => lecturesList[index].isChecked.toggle();

  // دالة حفظ الحضور (إرسال POST للسيرفر)
  Future<void> saveLectures() async {
    // تصفية المحاضرات التي تم اختيارها فقط
    var selected = lecturesList.where((l) => l.isChecked.value).toList();

    if (selected.isEmpty) {
      Get.snackbar(
        "تنبيه",
        "يرجى اختيار محاضرة واحدة على الأقل لتسجيل الحضور",
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading(true);
    bool allSuccess = true;

    try {
      // جلب المعرف المخزن
      var storedId = box.read('user_id');
      if (storedId == null) throw Exception("User ID missing");
      int uId = int.parse(storedId.toString());

      // إرسال طلب لكل محاضرة مختارة
      for (var lecture in selected) {
        bool result = await _service.postAttendance(lecture.id, uId);
        if (!result) {
          allSuccess = false;
          break; // نوقف الإرسال في حال حدوث أول خطأ (مثلاً انقطاع نت)
        }
      }

      if (allSuccess) {
        Get.snackbar(
          "نجاح العملية",
          "تم تسجيل حضور المحاضرات المحددة بنجاح",
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // تحديث البيانات بعد الحفظ لضمان مزامنة حالة is_done
        loadInitialData();
      } else {
        Get.snackbar(
          "فشل التسجيل",
          "حدث خطأ أثناء محاولة تسجيل الحضور، يرجى المحاولة لاحقاً",
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Save Error: $e");
      Get.snackbar("خطأ", "حدث خطأ غير متوقع أثناء الحفظ");
    } finally {
      isLoading(false);
    }
  }
}
