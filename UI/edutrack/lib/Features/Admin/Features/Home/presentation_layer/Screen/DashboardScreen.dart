import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Admin/Features/EmployeesManagement/presentation_layer/EmployeesManagementScreen.dart';
import 'package:edutrack/Features/Admin/Features/FacultyMangment/presentation_layer/FacultyStructureScreen.dart';
import 'package:edutrack/Features/Admin/Features/CoursesManagement/presentation_layer/CoursesManagementScreen.dart';
import 'package:edutrack/Features/Admin/Features/Home/presentation_layer/Screen/Widget/AdminSidebarContent.dart';
import 'package:edutrack/Features/Admin/Features/AddAcademicYear/presentation_layer/AddAcademicYearScreen.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/presentation_layer/InstructorsManagementScreen.dart';
import 'package:edutrack/Features/Admin/Features/RoomManagment/presentation_layer/RoomManagementScreen.dart';
import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

final MyColors colors = MyColors();

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final RxInt selectedPageIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth >= 1100;

    return Scaffold(
      backgroundColor: MyColors().backgroundColor,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: MyColors().AdminSidebarContent,
              elevation: 0,
              title: Obx(
                () => Text(
                  _getAppBarTitle(selectedPageIndex.value),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
      drawer: !isDesktop
          ? Drawer(child: AdminSidebarContent(selectedIndex: selectedPageIndex))
          : null,
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 20.0 : 0.0),
        child: Row(
          children: [
            if (isDesktop)
              AdminSidebarContent(selectedIndex: selectedPageIndex),
            if (isDesktop) const SizedBox(width: 20),
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // تم حذف _buildTopHeader من هنا ليلغى القسم العلوي
                    Expanded(
                      child: Obx(
                        () => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _buildPageContent(selectedPageIndex.value),
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

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return _buildStatsView();
      case 1:
        return InstructorsManagementScreen();
      case 2:
        return CoursesManagementScreen();
      case 3:
        return EmployeeManagementScreen();
      case 4:
        return FacultyStructureScreen();
      case 5:
        return AddAcademicYearScreen();
      case 6:
        return Roommanagementscreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStatsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 25,
            childAspectRatio: 1.3,
            children: [
              _modernStatCard(
                tr('total_instructors'),
                "45",
                Icons.group_add,
                const Color(0xFF3B82F6),
              ),
              _modernStatCard(
                tr('active_courses'),
                "12",
                Icons.book_rounded,
                const Color(0xFF6366F1),
              ),
              _modernStatCard(
                tr('occupied_rooms'),
                "8",
                Icons.meeting_room_rounded,
                const Color(0xFF8B5CF6),
              ),
              _modernStatCard(
                tr('system_tasks'),
                "95%",
                Icons.insights_rounded,
                const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _modernStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.05), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return tr('dashboard_appbar_title');
      case 1:
        return tr('manage_instructors_btn');
      case 2:
        return tr('manage_courses_btn');
      case 3:
        return tr('EmployeesManagement');
      case 4:
        return tr('Faculty Structure');
      case 5:
        return tr('system_setup_title');
      case 6:
        return tr('Room');
      default:
        return "";
    }
  }
}
