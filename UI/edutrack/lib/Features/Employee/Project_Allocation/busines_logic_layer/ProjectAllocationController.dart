import 'package:edutrack/Features/Employee/Project_Allocation/data_layer/Service/ProjectAllocationService.dart';
import 'package:edutrack/Features/Insructor/Features/Project/data_layer/Model/ProjectListResponse.dart';
import 'package:edutrack/Features/Insructor/Features/Project/data_layer/service/ProjectViewService.dart';
import 'package:edutrack/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectAllocationController extends GetxController {
  final ProjectAllocationService _service = ProjectAllocationService();
  final ProjectViewService service = ProjectViewService();

  final formKey = GlobalKey<FormState>();

  // 🎯 متحكمات حقول الساعات المعتمدة
  final theoryHoursController = TextEditingController();
  final practicalHoursController = TextEditingController();

  // --- إدارة المدرسين ---
  var facultyInstructors = <dynamic>[].obs;
  var selectedInstructorName = ''.obs;
  var selectedInstructorId = ''.obs;
  var selectedInstructorDept = ''.obs;
  var projectList = <ProjectModel>[].obs;
  var facultyId = 0.obs;
  var totalCount = 0.obs;

  // --- إدارة الأقسام الأكاديمية ---
  var facultyDepartments = <dynamic>[].obs;
  var selectedDepartmentName = ''.obs;
  var departmentId = 0.obs;
  var isFetchingDepartments = false.obs;

  var selectedProjectType = 'grad_2'.obs;
  final Map<String, String> projectTypes = {
    'term_project': 'مشروع فصلي',
    'grad_1': 'مشروع تخرج 1',
    'grad_2': 'مشروع تخرج 2 🌟',
  };

  var isLoading = false.obs;
  var isFetchingInstructors = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFacultyInstructors(employeeId: box.read("user_id"));
  }

  void fetchFacultyInstructors({required int employeeId}) async {
    try {
      isFetchingInstructors.value = true;
      final instRes = await _service.getInstructorsByEmployeeFaculty(
        employeeId,
      );
      if (instRes.statusCode == 200) {
        facultyInstructors.value = instRes.data['data'] ?? [];
      }
    } catch (e) {
      Get.snackbar("خطأ اتصال", "تعذر الوصول للمدرسين");
    } finally {
      isFetchingInstructors.value = false;
    }
  }

  void fetchDepartments(int fId) async {
    try {
      isFetchingDepartments.value = true;
      facultyDepartments.clear();
      selectedDepartmentName.value = '';
      departmentId.value = 0;

      final response = await _service.getDepartmentsByFaculty(fId);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        facultyDepartments.value = response.data['departments'] ?? [];
      }
    } catch (e) {
      Get.snackbar("خطأ في جلب الأقسام", "تعذر تحميل أقسام هذه الكلية");
    } finally {
      isFetchingDepartments.value = false;
    }
  }

  void onInstructorSelected(String fullName) {
    selectedInstructorName.value = fullName;
    var selectedInst = facultyInstructors.firstWhere(
      (i) => i['full_name'].toString() == fullName,
      orElse: () => null,
    );

    if (selectedInst != null) {
      selectedInstructorId.value = selectedInst['instructor_id'].toString();
      selectedInstructorDept.value =
          selectedInst['department_name'] ?? 'قسم تخصصي';
      facultyId.value = box.read("faculty_id");

      fetchDepartments(facultyId.value);
    }
  }

  void onDepartmentSelected(String deptName) {
    selectedDepartmentName.value = deptName;
    var selectedDept = facultyDepartments.firstWhere(
      (d) => d['name'].toString() == deptName,
      orElse: () => null,
    );
    if (selectedDept != null) {
      departmentId.value = selectedDept['department_id'];
    }
  }

  void submitAllocation() async {
    // تم تحديث التحقق هنا لحذف شرط عنوان المشروع
    if (!formKey.currentState!.validate() ||
        selectedInstructorId.isEmpty ||
        departmentId.value == 0) {
      Get.snackbar(
        "تنبيه",
        "يرجى تحديد المشرف، واختيار القسم الأكاديمي بدقة.",
        backgroundColor: Colors.amber.withOpacity(0.9),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    // قراءة الساعات وتحويلها بأمان
    double parsedTheoryHours =
        double.tryParse(theoryHoursController.text.trim()) ?? 0.0;
    double parsedPracticalHours =
        double.tryParse(practicalHoursController.text.trim()) ?? 0.0;

    // تجهيز جسم الطلب مع تمرير قيم ثابتة للحقول المحذوفة تلافياً لمشاكل الـ Validation في السيرفر
    Map<String, dynamic> requestBody = {
      "instructor_id": int.parse(selectedInstructorId.value),
      "project_type": selectedProjectType.value,
      "theory_hours": parsedTheoryHours,
      "practical_hours": parsedPracticalHours,
    };

    try {
      final response = await _service.allocateProject(requestBody);
      isLoading.value = false;
      final responseData = response.data;

      if (response.statusCode == 201 || responseData['status'] == 'success') {
        Get.snackbar(
          "تمت العملية بنجاح 🎉",
          responseData['message'] ?? "تم تسجيل الإسناد بنجاح.",
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        clearForm();
      } else {
        Get.snackbar(
          "خطأ في الإسناد",
          responseData['message'] ?? "حدث خطأ",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "خطأ في الاتصال",
        "فشل حفظ المشروع",
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  void fetchInstructorProjects() async {
    try {
      isLoading.value = true;
      // 🎯 استدعاء التابع المحدث وتمرير الـ ID
      final response = await service.getProjectsByInstructor(
        int.parse(selectedInstructorId.value),
      );

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

  void deleteProject(int projectId) async {
    try {
      isLoading.value = true;

      // استدعاء السيرفس لإرسال طلب الحذف
      final response = await _service.deleteProject(projectId);
      final responseData = response.data;

      if (response.statusCode == 200 || responseData['status'] == 'success') {
        // تحديث القائمة محلياً عبر حذف العنصر الذي يحمل نفس الـ ID
        projectList.removeWhere(
          (project) => project.projectId == projectId,
        ); // تأكد أن حقل الـ ID في الموديل اسمه id أو قم بتغييره حسب الموديل لديك
        totalCount.value = projectList.length;

        Get.snackbar(
          "تم الحذف بنجاح 🎉",
          responseData['message'] ?? "تم حذف المشروع وكافة متعلقاته بنجاح.",
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          "خطأ في الحذف",
          responseData['message'] ?? "لم نتمكن من حذف المشروع.",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ في الاتصال",
        "فشل الاتصال بالسيرفر لإتمام عملية الحذف.",
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    theoryHoursController.clear();
    practicalHoursController.clear();
    selectedInstructorId.value = '';
    selectedInstructorDept.value = '';
    selectedInstructorName.value = '';
    facultyDepartments.clear();
    selectedDepartmentName.value = '';
    departmentId.value = 0;
  }

  @override
  void onClose() {
    theoryHoursController.dispose();
    practicalHoursController.dispose();
    super.onClose();
  }
}
