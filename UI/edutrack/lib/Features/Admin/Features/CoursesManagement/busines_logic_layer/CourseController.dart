import 'package:edutrack/Features/Admin/Features/CoursesManagement/Data_layer/Model/Course.dart';
import 'package:edutrack/Features/Admin/Features/CoursesManagement/Data_layer/source/Course_Service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edutrack/Features/Admin/Features/InstructorsManagement/Data_layer/Model/FacultyModel.dart';

class CourseController extends GetxController {
  final CourseApiService _apiService = CourseApiService();

  RxList<Course> courses = <Course>[].obs;
  RxList<FacultyModel> faculties = <FacultyModel>[].obs;
  RxList<String> departments = <String>[].obs;

  RxBool isLoading = false.obs;
  String? errorMessage;

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final theoryHoursController = TextEditingController();
  final practicalHoursController = TextEditingController();
  final creditHoursController = TextEditingController();

  String? selectedFaculty;
  int? selectedFacultyId;
  String? selectedDepartment;

  String? editingCourseId;
  bool get isEditing => editingCourseId != null;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([loadCourses(), loadFaculties()]);
  }

  Future<void> loadCourses() async {
    isLoading.value = true;
    update();
    try {
      courses.value = await _apiService.fetchCourses();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> loadFaculties() async {
    try {
      faculties.value = await _apiService.fetchFaculties();
      update();
    } catch (e) {}
  }

  Future<void> updateFaculty(String? facultyName) async {
    selectedFaculty = facultyName;
    selectedDepartment = null; // هنا يتم التصفير وهذا صحيح
    departments.clear();

    if (facultyName != null) {
      try {
        final faculty = faculties.firstWhere((f) => f.name == facultyName);
        selectedFacultyId = faculty.id;
        // تأكد أن الخدمة تعيد List<String> فعلاً
        departments.value = await _apiService.fetchDepartments(faculty.id);
        print("Fetched Departments: ${departments}"); // للـ Debugging
      } catch (e) {
        print("Error fetching departments: $e");
      }
    }
    update();
  }

  void updateDepartment(String? dept) {
    selectedDepartment = dept;
    update();
  }

  Future<void> saveCourse() async {
    if (nameController.text.isEmpty || codeController.text.isEmpty) {
      Get.snackbar("تنبيه", "يرجى ملء الكود والاسم");
      return;
    }

    // تحقق من اختيار القسم قبل البدء
    if (selectedDepartment == null || selectedDepartment!.isEmpty) {
      Get.snackbar("تنبيه", "يرجى اختيار القسم أولاً");
      return;
    }

    isLoading.value = true;
    update();

    try {
      // حساب الساعات وتحويلها لـ Integer لضمان قبولها في الدجانغو
      double theory = double.tryParse(theoryHoursController.text) ?? 0.0;
      double practical = double.tryParse(practicalHoursController.text) ?? 0.0;

      // حساب الساعات الكلية وتحويلها لـ int
      int totalCreditHours =
          (double.tryParse(creditHoursController.text) ??
                  (theory + (practical / 2)))
              .toInt();

      final Map<String, dynamic> courseData = {
        "course_code": codeController.text.trim().toUpperCase(),
        "course_name": nameController.text.trim(),
        "credit_hours": totalCreditHours, // الآن هو Integer
        "department_name": selectedDepartment,
      };

      bool success = isEditing
          ? await _apiService.updateCourse(editingCourseId!, courseData)
          : await _apiService.addCourse(courseData);

      if (success) {
        await loadCourses();
        clearFields();
        Get.snackbar(
          "نجاح",
          "تمت إضافة المقرر بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "خطأ",
          "فشلت العملية، تأكد من كود المقرر (قد يكون مكرراً)",
        );
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ غير متوقع");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void prepareUpdate(Course course) {
    editingCourseId = course.courseId;
    nameController.text = course.courseName;
    codeController.text = course.courseId;
    creditHoursController.text = course.creditHours.toString();
    selectedFaculty = course.facultyName;
    selectedDepartment = course.departmentName;
    update();
  }

  Future<void> deleteCourse(String courseId) async {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد من حذف المقرر $courseId؟",
      onConfirm: () async {
        Get.back(); // إغلاق الديالوج

        isLoading.value = true; // تشغيل لودينج بسيط إذا بدك
        update();

        try {
          final bool success = await _apiService.deleteCourse(courseId);

          if (success) {
            // 1. الحذف من القائمة المحلية (هذا اللي بيخفيه من الذاكرة)
            courses.removeWhere((c) => c.courseId == courseId);

            // 2. تحديث GetX ليقوم الـ Obx بإعادة بناء الجدول فوراً
            update();

            Get.snackbar(
              "نجاح",
              "تم حذف المقرر بنجاح",
              backgroundColor: Colors.green.withOpacity(0.2),
            );
          } else {
            Get.snackbar("خطأ", "فشل الحذف من السيرفر");
          }
        } catch (e) {
          Get.snackbar("خطأ", "حدث خطأ: $e");
        } finally {
          isLoading.value = false;
          update();
        }
      },
      textConfirm: "حذف",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
    );
  }

  void clearFields() {
    nameController.clear();
    codeController.clear();
    theoryHoursController.clear();
    practicalHoursController.clear();
    creditHoursController.clear();
    selectedFaculty = null;
    selectedDepartment = null;
    editingCourseId = null;
    update();
  }
}
