import 'package:edutrack/Features/Auth/Presentation_layer/Screen/Login.dart';
import 'package:edutrack/Features/Auth/data_layer/source/auth_service.dart';
import 'package:edutrack/Features/Employee/Home/presentation_layer/EmployeeDashboard.dart';
import 'package:edutrack/Features/Insructor/Home.dart';
import 'package:edutrack/Features/Admin/Features/Home/presentation_layer/Screen/DashboardScreen.dart';
import 'package:edutrack/main.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  // استخدام التسمية الصحيحة للمتغيرات (يفضل نهج Singleton أو الـ Dependency Injection)
  AuthService _service = AuthService();

  RxBool obscurePassword = true.obs;
  RxBool isLoading = false.obs;

  Future<void> login(String phone, String password) async {
    // تغيير لـ phone
    if (phone.isEmpty || password.isEmpty) {
      Get.snackbar("تنبيه", "يرجى إدخال رقم الهاتف وكلمة المرور");
      return;
    }
    try {
      isLoading.value = true;
      bool isSuccess = await _service.loginUser(phone, password);
      isLoading.value = false;

      if (isSuccess) {
        String role = box.read('role').toString().toLowerCase();
        if (role == "admin") {
          Get.offAll(() => DashboardScreen());
        } else if (role == "employee") {
          Get.offAll(() => EmployeeDashboard());
        } else {
          Get.offAll(() => Home());
        }
      } else {
        Get.snackbar("خطأ", "رقم الهاتف أو كلمة المرور غير صحيحة");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "فشل الاتصال بالسيرفر");
    }
  }

  void toggleObscure() {
    obscurePassword.value = !obscurePassword.value;
  }

  void logout() {
    box.erase();
    Get.offAll(() => Login());
  }
}

// extension on bool {
//   operator [](String other) {}
// }
