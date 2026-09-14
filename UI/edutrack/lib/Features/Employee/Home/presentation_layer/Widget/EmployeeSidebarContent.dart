import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Auth/busines_logic_layer/Auth_controller.dart';
import 'package:edutrack/Features/Employee/Home/busines_logic_layer/EmployeeDashboardController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
// قم بتغيير المسار حسب مكان ملف الـ Controller عندك
// import 'package:your_project_path/employee_navigation_controller.dart';

class EmployeeSidebarContent extends StatelessWidget {
  EmployeeSidebarContent({super.key});

  // استدعاء الكنترولر
  final EmployeeNavigationController navContext = Get.put(
    EmployeeNavigationController(),
  );
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2, // عرض مناسب للديسك توب
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // الكحلي الفخم
        borderRadius: BorderRadius.circular(35),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildLogo(),
                    const SizedBox(height: 50),

                    // عناصر القائمة
                    _item(
                      0,
                      Icons.grid_view_rounded,
                      tr('dashboard_appbar_title'),
                    ),
                    _item(
                      1,
                      Icons.menu_book_rounded,
                      tr('allocate_courses_btn'),
                    ), // تأكد من وجود المفاتيح في ملفات الترجمة
                    _item(2, Icons.fact_check, tr('Exam_duty')),
                    _item(
                      3,
                      Icons.receipt_long_rounded,
                      tr('AdminTeachingLoadScreen'),
                    ),
                    _item(
                      4,
                      Icons
                          .edit_calendar_rounded, // أيقونة معبرة عن إدارة الجداول والعطل
                      tr(
                        "Cat_manage",
                      ), // فيك تستبدلها بـ tr('manage_lectures_btn') بالترجمة عندك
                    ),
                    _item(
                      5,
                      Icons
                          .edit_calendar_rounded, // أيقونة معبرة عن إدارة الجداول والعطل
                      tr(
                        "pro_Allo",
                      ), // فيك تستبدلها بـ tr('manage_lectures_btn') بالترجمة عندك
                    ),

                    const Spacer(),

                    const SizedBox(height: 30),
                    _buildLanguageToggle(context),
                    const SizedBox(height: 15),
                    _logoutItem(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "EduTrack",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _item(int index, IconData icon, String title) {
    return Obx(() {
      bool sel = navContext.selectedPageIndex.value == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: sel
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: ListTile(
          onTap: () {
            navContext.changePage(index);
            if (Scaffold.of(Get.context!).isDrawerOpen) Get.back();
          },
          leading: Icon(
            icon,
            color: sel ? Colors.white : Colors.white38,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: sel ? Colors.white : Colors.white60,
              fontWeight: sel ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLanguageToggle(BuildContext context) {
    bool isAr = context.locale.languageCode == 'ar';
    return InkWell(
      onTap: () async {
        Locale newLocale = isAr ? const Locale("en") : const Locale("ar");
        await context.setLocale(newLocale);
        Get.updateLocale(newLocale);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.language_rounded,
              size: 20,
              color: Colors.blueAccent,
            ),
            Text(
              isAr ? "English" : "العربية",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutItem() {
    return ListTile(
      leading: const Icon(Icons.logout_rounded, color: Color(0xFFFDA4AF)),
      title: Text(
        tr('logout_btn'),
        style: const TextStyle(
          color: Color(0xFFFDA4AF),
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Get.defaultDialog(
          title: tr("warning"),
          middleText: tr("logout_confirm_msg"),
          textConfirm: tr("yes"),
          textCancel: tr("cancel"),
          confirmTextColor: Colors.white,
          buttonColor: Colors.red,
          onConfirm: () {
            controller.logout();
            // أضف كود تسجيل الخروج هنا
          },
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}
