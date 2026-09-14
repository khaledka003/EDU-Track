import 'package:easy_localization/easy_localization.dart'; // إضافة الاستيراد للترجمة
// import 'package:edutrack/Features/Admin/Features/Home/presentation_layer/Screen/DashboardScreen.dart';
import 'package:edutrack/Features/Auth/Presentation_layer/Screen/Onboarding/TopCurveClipper.dart';
import 'package:edutrack/Features/Auth/busines_logic_layer/Auth_controller.dart';
// import 'package:edutrack/Features/Employee/Home/presentation_layer/EmployeeDashboard.dart';
// import 'package:edutrack/Features/Insructor/Home.dart';
import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans; // منع التضارب مع حفظ كل شيء

// ignore: must_be_immutable
class Login extends StatelessWidget {
  Login({super.key});

  AuthController controller = Get.put(AuthController());
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  void _handleLogin() async {
    if (_globalKey.currentState!.validate()) {
      await controller.login(phone.text, password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استخدام LayoutBuilder لتحديد نوع الجهاز بناءً على عرض الشاشة
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return _buildDesktopLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  // ----------------------------------------------------
  // تصميم الكمبيوتر (Desktop Layout)
  // ----------------------------------------------------
  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            MyColors().Oxford_Blue,
            MyColors().Deep_Ocean_Blue,
            MyColors().Ocean_Blue,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.70,
          height: MediaQuery.of(context).size.height * 0.75,
          constraints: const BoxConstraints(minHeight: 550, maxWidth: 1100),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            children: [
              // الجانب الأيسر: بصري وترحيبي
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: MyColors().Ocean_Blue.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 100,
                        color: MyColors().Ocean_Blue,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        tr('admin_portal_title'), // تعديل النص
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MyColors().Oxford_Blue,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        tr('admin_portal_desc'), // تعديل النص
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // الجانب الأيمن: نموذج تسجيل الدخول
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('login_header'), // تعديل النص
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: MyColors().Oxford_Blue,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildLoginForm(context, isDark: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  //  تصميم الموبايل (Mobile Layout)
  // ----------------------------------------------------
  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MyColors().Ocean_Blue,
                MyColors().Deep_Ocean_Blue,
                MyColors().Oxford_Blue,
              ],
            ),
          ),
        ),
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: Colors.white.withAlpha(200),
            child: Text(
              tr('login_mobile_title'), // تعديل النص
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: MyColors().Deep_Ocean_Blue,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(child: _buildLoginForm(context, isDark: true)),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // ويدجت النموذج (Login Form) - مشترك مع تغيير الألوان
  // ----------------------------------------------------
  Widget _buildLoginForm(BuildContext context, {required bool isDark}) {
    Color fieldColor = isDark
        ? Colors.white.withAlpha(40)
        : Colors.grey.shade100;
    Color labelStyle = isDark ? Colors.white70 : Colors.grey.shade600;
    Color inputTextStyle = isDark ? Colors.white : Colors.black;
    Color iconColor = isDark ? Colors.white : MyColors().Ocean_Blue;

    return Form(
      key: _globalKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            textInputAction: TextInputAction.next,
            controller: phone,
            validator: (value) {
              if (value == null || value.isEmpty) return tr('id_error_empty');
              if (value.length < 4) return tr('id_error_invalid');
              return null;
            },
            keyboardType: TextInputType.number,
            style: TextStyle(color: inputTextStyle),
            decoration: InputDecoration(
              labelText: tr('id_label'),
              labelStyle: TextStyle(color: labelStyle),
              filled: true,
              fillColor: fieldColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: isDark
                    ? BorderSide.none
                    : BorderSide(color: Colors.grey.shade300),
              ),
              prefixIcon: Icon(Icons.accessibility, color: iconColor),
            ),
          ),
          SizedBox(height: 25),

          Obx(
            () => TextFormField(
              textInputAction: TextInputAction.done, // يظهر زر "تم" أو "Enter"
              onFieldSubmitted: (value) => _handleLogin(),
              controller: password,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return tr('password_error_empty');
                if (value.length < 6) return tr('password_error_invalid');
                return null;
              },
              obscureText: controller.obscurePassword.value,
              style: TextStyle(color: inputTextStyle),
              decoration: InputDecoration(
                labelText: tr('password_label'),
                labelStyle: TextStyle(color: labelStyle),
                filled: true,
                fillColor: fieldColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: isDark
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade300),
                ),
                prefixIcon: Icon(Icons.lock, color: iconColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: iconColor,
                  ),
                  onPressed: () => controller.obscurePassword.toggle(),
                ),
              ),
            ),
          ),
          SizedBox(height: 35),

          Obx(() {
            if (controller.isLoading.value) {
              return CircularProgressIndicator(
                color: isDark ? Colors.white : MyColors().Ocean_Blue,
              );
            } else {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white.withAlpha(50)
                        : MyColors().Ocean_Blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    if (_globalKey.currentState!.validate()) {
                      await controller.login(phone.text, password.text);
                      // if (phone.text == "11111") {
                      //   Get.offAll(() => DashboardScreen());
                      // } else if (phone.text == "22222") {
                      //   Get.offAll(EmployeeDashboard());
                      // } else {
                      //   Get.offAll(Home());
                      // }
                    }
                  },
                  child: Text(
                    tr('verify_button'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}
