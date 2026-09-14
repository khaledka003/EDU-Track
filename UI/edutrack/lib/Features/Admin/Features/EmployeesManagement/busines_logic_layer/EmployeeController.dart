import 'package:edutrack/Features/Admin/Features/EmployeesManagement/Data_layer/EmployeeService.dart';
import 'package:get/get.dart';

class EmployeeController extends GetxController {
  final EmployeeService _service = EmployeeService();

  var employees = [].obs;
  var faculties = [].obs;
  var isLoading = false.obs;

  // متغير للقيمة المختارة يقبل null بالبداية
  var selectedFacultyId = Rxn<int>();

  @override
  void onInit() {
    fetchEmployees();
    fetchFaculties();
    super.onInit();
  }

  // داخل كلاس EmployeeController
  var isPasswordHidden = true.obs; // متغير لمراقبة حالة إخفاء كلمة المرور

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void fetchEmployees() async {
    try {
      isLoading(true);
      var response = await _service.getAllEmployees();
      if (response.data['status'] == 'success') {
        employees.assignAll(response.data['data']);
      }
    } catch (e) {
      print("Error fetching employees: $e");
    } finally {
      isLoading(false);
    }
  }

  void fetchFaculties() async {
    try {
      var response = await _service.getFaculties();
      // الدخول لعمق الداتا (JSON -> data)
      if (response.data['status'] == 'success') {
        faculties.assignAll(response.data['data']);
      }
    } catch (e) {
      print("Error fetching faculties: $e");
    }
  }

  Future<void> registerEmployee(Map<String, dynamic> data) async {
    try {
      var response = await _service.addEmployee(data);
      if (response.data['status'] == 'success') {
        fetchEmployees();
        Get.back();
        Get.snackbar(
          "تم",
          "تم تسجيل الموظف بنجاح",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل في تسجيل الموظف");
    }
  }

  Future<void> editEmployee(int id, Map<String, dynamic> data) async {
    try {
      var response = await _service.updateEmployee(id, data);
      if (response.data['status'] == 'success') {
        fetchEmployees();
        Get.back();
        Get.snackbar(
          "تم",
          "تم التحديث بنجاح",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل في التحديث");
    }
  }

  Future<void> removeEmployee(int id) async {
    try {
      var response = await _service.deleteEmployee(id);
      if (response.data['status'] == 'success') {
        fetchEmployees();
        Get.snackbar("تم", "تم حذف الموظف");
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل في الحذف");
    }
  }
}
