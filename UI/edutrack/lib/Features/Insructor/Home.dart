import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Auth/busines_logic_layer/Auth_controller.dart';
import 'package:edutrack/Features/Insructor/Features/Compensatory/presentation_layer/Instructor_lectures_view.dart';
import 'package:edutrack/Features/Insructor/Features/DailyLectures/busines_logic_layer/LecturesController.dart';
import 'package:edutrack/Features/Insructor/Features/Notifecation/presentation_layer/NotificationView.dart';
import 'package:edutrack/Features/Insructor/Features/Profile/Data_layer/Model/ProfileModel.dart';
import 'package:edutrack/Features/Insructor/Features/Profile/busines_logic_layer/ProfileController.dart';
import 'package:edutrack/Features/Insructor/Features/AcademicLog/Presentaion_layer/AcademicLogScreen.dart';
import 'package:edutrack/Features/Insructor/Features/DailyLectures/Presentaion_layer/DailyLectures_Screen.dart';
import 'package:edutrack/Features/Insructor/Features/ExamAssignment/Presentaion_layer/ExamAssignment_screen.dart';
import 'package:edutrack/Features/Insructor/Features/Profile/Screen/ProfileScreen.dart';
import 'package:edutrack/Features/Insructor/Features/Project/Presentaion_layer/ProjectListView.dart';
import 'package:edutrack/Features/Insructor/Features/TeachingLoad/Presentaion_layer/TeachingLoad_screen.dart';
import 'package:edutrack/Features/Insructor/Features/WeeklySchedule/Presentaion_layer/WeeklyScheduleScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthController authController = Get.put(AuthController());
  ProfileController controller = Get.put(ProfileController());
  final RxInt _selectedIndex = 0.obs;

  // الإصلاح 1: دالة لإرجاع الصفحة المطلوبة بدلاً من قائمة ثابتة لتجنب تضارب الـ Lifecycle
  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return DailyLecturesScreen();
      case 1:
        return ExamAssignmentsScreen();
      case 2:
        return const TeachingLoadScreen();
      case 3:
        return const WeeklyScheduleScreen(); // تأكد أنها StatefulWidget كما أصلحناها سابقاً
      case 4:
        return AcademicLogScreen();
      case 5:
        return ProjectListView();
      case 6:
        return InstructorLecturesView();
      case 7:
        return NotificationView();
      default:
        return DailyLecturesScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLaptop = constraints.maxWidth > 900;

        return Scaffold(
          backgroundColor: Colors.white,
          drawer: isLaptop
              ? null
              : Drawer(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: _buildSidebarContent(context, isLaptop),
                ),
          appBar: isLaptop
              ? null
              : AppBar(
                  backgroundColor: const Color(0xFF1E293B),
                  elevation: 0,
                  centerTitle: true,
                  title: Obx(
                    () => Text(
                      _getTranslatedTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
          body: Row(
            children: [
              if (isLaptop)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSidebarContent(context, isLaptop),
                ),
              Expanded(
                child: Container(
                  margin: isLaptop
                      ? const EdgeInsets.only(top: 16, bottom: 16, right: 16)
                      : null,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: isLaptop
                        ? BorderRadius.circular(35)
                        : BorderRadius.zero,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: isLaptop
                        ? BorderRadius.circular(35)
                        : BorderRadius.zero,
                    child: Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        // هذا السطر هو مفتاح الحل: يخبر Flutter أن الشاشة تغيرت فعلياً
                        child: Container(
                          key: ValueKey<int>(_selectedIndex.value),
                          child: _getSelectedPage(_selectedIndex.value),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTranslatedTitle() {
    if (_selectedIndex.value == 0) return "daily_schedule".tr();
    if (_selectedIndex.value == 1) return "exam_assignments".tr();
    if (_selectedIndex.value == 2) return "teaching_load".tr();
    if (_selectedIndex.value == 3) return "weekly_schedule".tr();
    if (_selectedIndex.value == 4) return "Academic_Log".tr();
    if (_selectedIndex.value == 5) return "Project".tr();
    if (_selectedIndex.value == 6) return "InstructorLecturesView".tr();

    if (_selectedIndex.value == 7) return "Notification".tr();
    return "";
  }

  Widget _buildSidebarContent(BuildContext context, bool isLaptop) {
    return Container(
      width: 290,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints
                    .maxHeight, // يضمن توزيع العناصر على كامل الارتفاع
              ),
              child: IntrinsicHeight(
                // يسمح للـ Spacer بالعمل داخل ScrollView
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildSidebarLogo(),
                    const SizedBox(height: 35),
                    _buildUserProfile(),
                    const SizedBox(height: 30),
                    const Divider(
                      color: Colors.white10,
                      indent: 10,
                      endIndent: 10,
                    ),
                    const SizedBox(height: 20),
                    _item(
                      0,
                      Icons.grid_view_rounded,
                      "daily_schedule".tr(),
                      context,
                      isLaptop,
                    ),
                    _item(
                      1,
                      Icons.assignment_ind_rounded,
                      "exam_assignments".tr(),
                      context,
                      isLaptop,
                    ),
                    _item(
                      2,
                      Icons.auto_stories_rounded,
                      "teaching_load".tr(),
                      context,
                      isLaptop,
                    ),
                    _item(
                      3,
                      Icons.calendar_month_rounded,
                      "weekly_schedule".tr(),
                      context,
                      isLaptop,
                    ),
                    _item(
                      4,
                      Icons.calendar_month_rounded,
                      "Academic_Log".tr(),
                      context,
                      isLaptop,
                    ),
                    _item(
                      5,
                      Icons.calendar_month_rounded,
                      "Project".tr(),
                      context,
                      isLaptop,
                    ),
                    _item(
                      6,
                      Icons.calendar_month_rounded,
                      "InstructorLecturesView".tr(),
                      context,
                      isLaptop,
                    ),
                    _item(
                      7,
                      Icons.calendar_month_rounded,
                      "Notification".tr(),
                      context,
                      isLaptop,
                    ),

                    // بديل للـ Spacer يضمن عدم حدوث Overflow
                    const Expanded(child: SizedBox(height: 40)),

                    _buildBottomActions(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.blue],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 24,
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

  Widget _buildUserProfile() {
    return InkWell(
      onTap: () {
        if (Navigator.canPop(context)) Navigator.pop(context);
        Get.to(() => ProfileScreen(), transition: Transition.rightToLeft);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                // أضفنا Obx هنا لمراقبة التغيير
                // التحقق من وجود البيانات لتجنب الـ Crash
                ProfileModel? profile = controller.profile.value;
                String instructorName = profile != null
                    ? profile.fullName
                    : "loading".tr();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "instructor".tr(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              }),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.2),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    int index,
    IconData icon,
    String title,
    BuildContext context,
    bool isLaptop,
  ) {
    return Obx(() {
      bool sel = _selectedIndex.value == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: sel ? Colors.blueAccent.withOpacity(0.15) : Colors.transparent,
        ),
        child: ListTile(
          onTap: () {
            // 1. إذا كان العنصر مختاراً بالفعل، لا تفعل شيئاً لمنع إعادة البناء غير الضرورية
            if (_selectedIndex.value == index) {
              if (!isLaptop && Navigator.canPop(context))
                Navigator.pop(context);
              return;
            }

            // 2. تحديث الـ Index
            _selectedIndex.value = index;

            // 3. تحديث البيانات تلقائياً عند الانتقال لجدول المحاضرات
            if (index == 0) {
              // نستخدم try-catch كصمام أمان في حال لم يكن الكنترولر جاهزاً في الذاكرة بعد
              try {
                Get.find<LecturesController>().loadInitialData();
              } catch (e) {
                debugPrint("Controller not found yet");
              }
            }

            // 4. إغلاق القائمة الجانبية في وضع الموبايل
            if (!isLaptop && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          leading: Icon(
            icon,
            color: sel ? Colors.blueAccent : Colors.white38,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: sel ? Colors.white : Colors.white60,
              fontWeight: sel ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _buildLanguageToggle(context),
          const SizedBox(height: 5),
          _logoutItem(),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    bool isAr = context.locale.languageCode == 'ar';
    return ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () async {
        Locale newLocale = isAr ? const Locale("en") : const Locale("ar");
        await context.setLocale(newLocale);
        Get.updateLocale(newLocale);
      },
      leading: const Icon(
        Icons.language_rounded,
        size: 20,
        color: Colors.blueAccent,
      ),
      title: Text(
        isAr ? "English" : "العربية",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _logoutItem() {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: const Icon(
        Icons.logout_rounded,
        color: Color(0xFFFDA4AF),
        size: 20,
      ),
      title: Text(
        "logout".tr(),
        style: const TextStyle(
          color: Color(0xFFFDA4AF),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Get.defaultDialog(
          title: "warning".tr(),
          middleText: "logout_confirm_msg".tr(),
          textConfirm: "yes".tr(),
          textCancel: "cancel".tr(),
          onConfirm: () => authController.logout(),
        );
      },
    );
  }
}
