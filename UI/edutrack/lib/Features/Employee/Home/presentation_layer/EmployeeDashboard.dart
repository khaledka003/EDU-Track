import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Employee/Lecture_mangment/presentation_layer/employee_lectures_view.dart';
import 'package:edutrack/Features/Employee/CourseAllocation/presentation_layer/CourseAllocationScreen.dart';
import 'package:edutrack/Features/Employee/ExamAssignment/presentation_layer/Exam_duty_Screen.dart';
import 'package:edutrack/Features/Employee/Home/busines_logic_layer/EmployeeDashboardController.dart';
import 'package:edutrack/Features/Employee/Home/presentation_layer/EmployeeHomeView.dart';
import 'package:edutrack/Features/Employee/Home/presentation_layer/Widget/EmployeeSidebarContent.dart';
import 'package:edutrack/Features/Employee/Project_Allocation/presentation_layer/ProjectAllocationFormView.dart';
import 'package:edutrack/Features/Employee/View_teaching_load/presentation_layer/Admin_teaching_load_screen.dart';
import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class EmployeeDashboard extends StatelessWidget {
  EmployeeDashboard({super.key});

  final EmployeeNavigationController navContext = Get.put(
    EmployeeNavigationController(),
  );

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth >= 1100;

    return Scaffold(
      backgroundColor: MyColors().backgroundColor, // لون الخلفية العام
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1E293B),
              elevation: 0,
              title: Obx(
                () => Text(_getTitle(navContext.selectedPageIndex.value)),
              ),
            ),
      drawer: !isDesktop ? Drawer(child: EmployeeSidebarContent()) : null,
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 20.0 : 0.0),
        child: Row(
          children: [
            // السايد بار يظهر فقط في الديسك توب
            if (isDesktop) EmployeeSidebarContent(),
            if (isDesktop) const SizedBox(width: 20),

            // منطقة المحتوى المتغيرة
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC), // خلفية المحتوى بيضاء مريحة
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (isDesktop)
                      Expanded(
                        child: Obx(
                          () => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: _buildPageContent(
                              navContext.selectedPageIndex.value,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة تبديل المحتوى حسب الصفحة المختارة
  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return EmployeeHomeView();
      case 1:
        return CourseAllocationScreen();
      case 2:
        return ExamDutyScreen();
      case 3:
        return const AdminTeachingLoadScreen();
      case 4:
        return EmployeeLecturesView();
      case 5:
        return ProjectAllocationFormView();

      default:
        return const SizedBox();
    }
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return tr('dashboard_appbar_title');
      case 1:
        return tr('allocate_courses_btn');
      case 2:
        return tr('Exam_duty');
      case 3:
        return tr("AdminTeachingLoadScreen");
      case 4:
        return tr("Cat_manage");
      case 5:
        return tr("pro_Allo");
      default:
        return "";
    }
  }
}
