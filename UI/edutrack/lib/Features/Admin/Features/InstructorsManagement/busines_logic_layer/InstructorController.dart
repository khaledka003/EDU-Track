import 'package:edutrack/Features/Admin/Features/InstructorsManagement/Data_layer/Model/FacultyModel.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/Data_layer/Model/Instructor.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/Data_layer/source/Instructor_Service.dart';
import 'package:edutrack/main.dart'; // تأكد من وجود تعريف الـ box هنا
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

class InstructorController extends GetxController {
  InstructorApiService apiService = InstructorApiService();

  // القائمة الأساسية التي ستعرض في الواجهة
  var instructors = <Instructor>[].obs;
  bool isLoading = false;
  RxBool isLoadingExam = false.obs;

  String? errorMessage;

  var faculties = <FacultyModel>[].obs;
  var departments = <String>[].obs;

  // المتحكمات بالنصوص
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String? selectedFacultyName;
  int? selectedFacultyId;
  String? selectedDepartmentName;
  String? selectedRank;

  bool isEditing = false;
  int? currentInstructorId;

  @override
  void onInit() {
    super.onInit();
    loadFaculties();
    initializeDataByRole(); // تحديد البيانات المطلوبة عند التشغيل
  }

  // الدالة المسؤولية عن فحص الدور وجلب البيانات المناسبة
  void initializeDataByRole() {
    String role = box.read('role') ?? 'admin';

    if (role == 'admin') {
      loadInstructors(); // جلب الكل للآدمن
    } else {
      // جلب المدرسين التابعين لكلية الموظف الحالي
      int employeeId = box.read('user_id') ?? 0;
      loadInstructorsByFaculty(employeeId);
    }
  }

  Future<void> loadFaculties() async {
    try {
      faculties.value = await apiService.fetchFaculties();
      update();
    } catch (e) {
      print("Error loading faculties: $e");
    }
  }

  Future<void> loadDepartments(int facultyId) async {
    try {
      departments.clear();
      selectedDepartmentName = null;
      update();
      departments.value = await apiService.fetchDepartments(facultyId);
      update();
    } catch (e) {
      print("Error loading departments: $e");
    }
  }

  void onFacultyChanged(String? name) {
    selectedFacultyName = name;
    if (name != null) {
      final faculty = faculties.firstWhere((f) => f.name == name);
      selectedFacultyId = faculty.id;
      loadDepartments(faculty.id);
    }
    update();
  }

  // جلب كافة المدرسين
  Future<void> loadInstructors() async {
    isLoading = true;
    errorMessage = null;
    update();
    try {
      var fetchedData = await apiService.fetchInstructors();
      instructors.assignAll(fetchedData);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
  }

  // جلب مدرسين حسب الكلية
  Future<void> loadInstructorsByFaculty(int employeeId) async {
    isLoading = true;
    errorMessage = null;
    update();
    try {
      var fetchedData = await apiService.fetchInstructorsByFaculty(employeeId);
      instructors.assignAll(fetchedData);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
  }

  void prepareEdit(Instructor instructor) {
    isEditing = true;
    currentInstructorId = instructor.userId;

    firstNameController.text = instructor.firstName;
    lastNameController.text = instructor.lastName;
    emailController.text = instructor.email;
    phoneController.text = instructor.phoneNumber;

    selectedFacultyName = instructor.facultyName;
    selectedDepartmentName = instructor.departmentName;
    selectedRank = instructor.academicRank;

    passwordController.clear();

    if (faculties.isNotEmpty) {
      try {
        final f = faculties.firstWhere(
          (element) => element.name == instructor.facultyName,
        );
        selectedFacultyId = f.id;
        loadDepartments(f.id);
      } catch (e) {}
    }
    update();
  }

  Future<void> saveInstructor() async {
    if (firstNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Get.snackbar("تنبيه", "يرجى ملء الاسم، البريد، ورقم الهاتف");
      return;
    }

    isLoading = true;
    update();

    try {
      final Map<String, dynamic> data = {
        "first_name": firstNameController.text.trim(),
        "last_name": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone_number": phoneController.text.trim(),
        "academic_rank": selectedRank ?? "مدرس",
      };

      bool success;
      if (isEditing && currentInstructorId != null) {
        data["department_id"] = selectedFacultyId;
        success = await apiService.updateInstructor(currentInstructorId!, data);
      } else {
        data["department_name"] = selectedDepartmentName ?? "";
        data["password"] = passwordController.text;
        success = await apiService.addInstructor(data);
      }

      if (success) {
        initializeDataByRole(); // إعادة تحميل البيانات المناسبة بعد الحفظ
        clearFields();
        Get.snackbar(
          "نجاح",
          "تمت العملية بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("فشل", "تأكد من البيانات المبعوثة");
      }
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteInstructor(int userId) async {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد من حذف هذا المدرس؟",
      onConfirm: () async {
        Get.back();
        isLoading = true;
        update();
        try {
          final bool success = await apiService.deleteInstructor(userId);
          if (success) {
            initializeDataByRole(); // تحديث القائمة فوراً
            Get.snackbar("نجاح", "تم الحذف بنجاح");
          } else {
            // هذا الجزء الجديد ليعطيك السناك بار عند الفشل
            Get.snackbar("خطأ", "فشل الحذف، يرجى المحاولة مرة أخرى");
          }
        } catch (e) {
          Get.snackbar("خطأ", e.toString());
        } finally {
          isLoading = false;
          update();
        }
      },
      textConfirm: "حذف",
      textCancel: "إلغاء",
      buttonColor: Colors.red,
    );
  }

  void clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    selectedFacultyName = null;
    selectedFacultyId = null;
    selectedDepartmentName = null;
    selectedRank = null;
    isEditing = false;
    currentInstructorId = null;
    departments.clear();
    update();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
