import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Auth/busines_logic_layer/Auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class AdminSidebarContent extends StatelessWidget {
  final RxInt selectedIndex;
  AdminSidebarContent({super.key, required this.selectedIndex});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // الكحلي الداكن الفخم
        borderRadius: BorderRadius.circular(35),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),

      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // لضمان وجود سكرول عند الحاجة فقط
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildSidebarLogo(),
                    const SizedBox(height: 50),

                    // --- القائمة الأساسية ---
                    _item(
                      0,
                      Icons.grid_view_rounded,
                      tr('dashboard_appbar_title'),
                      context,
                    ),
                    _item(
                      1,
                      Icons.people_rounded,
                      tr('manage_instructors_btn'),
                      context,
                    ),
                    _item(
                      2,
                      Icons.menu_book_rounded,
                      tr('manage_courses_btn'),
                      context,
                    ),
                    _item(
                      3,
                      Icons.calendar_today_rounded,
                      tr('EmployeesManagement'),
                      context,
                    ),
                    _item(
                      4,
                      Icons.fact_check,
                      tr('FacultyStructureScreen'),
                      context,
                    ),
                    _item(
                      5,
                      Icons.system_security_update,
                      tr('system_setup_title'),
                      context,
                    ),
                    _item(6, Icons.meeting_room_outlined, tr('Room'), context),

                    // يمكنك إضافة عناصر هنا مستقبلاً دون قلق من المساحة

                    // الفراغ المرن الذي يدفع العناصر للأسفل
                    const Spacer(),

                    const SizedBox(height: 30),
                    _buildLanguageToggle(context),
                    const SizedBox(height: 15),
                    _logoutItem(),
                    const SizedBox(height: 40), // مسافة أخيرة في أسفل السكرول
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- شعار التطبيق العلوي ---
  Widget _buildSidebarLogo() {
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
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // --- عنصر القائمة (Item) ---
  Widget _item(int index, IconData icon, String title, BuildContext context) {
    return Obx(() {
      bool sel = selectedIndex.value == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: sel
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                )
              : null,
          color: sel ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: Colors.blue.withAlpha(75),
                    blurRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ListTile(
          onTap: () {
            selectedIndex.value = index;
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.pop(context);
            }
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
              fontSize: 15,
            ),
          ),
        ),
      );
    });
  }

  // --- زر تبديل اللغة ---
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

  // --- زر تسجيل الخروج ---
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
          },
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}
