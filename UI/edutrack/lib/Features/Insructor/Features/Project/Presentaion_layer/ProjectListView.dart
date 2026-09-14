import 'package:edutrack/Features/Insructor/Features/Project/Presentaion_layer/QuotaFillingSheet.dart';
import 'package:edutrack/Features/Insructor/Features/Project/busines_logic_layer/ProjectViewController.dart';
import 'package:edutrack/Features/Insructor/Features/Project/data_layer/Model/ProjectListResponse.dart';

import 'package:edutrack/Features/Insructor/Features/WeeklySchedule/busines_logic_layer/WeeklyController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectListView extends StatelessWidget {
  ProjectListView({Key? key}) : super(key: key);

  // متغير Rx لحفظ المشروع المحدد حالياً في عرض اللابتوب (Split View)
  final RxInt selectedProjectIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProjectViewController());
    // التأكد من عمل Injection أو إيجاد الـ WeeklyController في الذاكرة
    Get.put(WeeklyController());

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 950;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            );
          }

          if (controller.projectList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 80,
                    color: Colors.indigo.shade100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "لا يوجد مشاريع مسجلة حالياً.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return isDesktop
              ? _buildDesktopSplitDashboard(controller.projectList)
              : _buildMobileGrid(controller.projectList);
        }),
      ),
    );
  }

  // 💻 واجهة اللابتوب الفخمة: قائمة تفاعلية يمين + لوحة تحليل ومتابعة يسار
  Widget _buildDesktopSplitDashboard(List<ProjectModel> list) {
    return Row(
      children: [
        // القائمة الجانبية اليمنى للمشاريع
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final project = list[index];
                return Obx(() {
                  final bool isSelected = selectedProjectIndex.value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.indigo.shade50.withOpacity(0.6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.indigo.shade300
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      onTap: () => selectedProjectIndex.value = index,
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Colors.indigo
                            : Colors.grey.shade100,
                        child: Text(
                          '${project.projectId}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text(
                        project.projectTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.indigo.shade900
                              : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: isSelected
                            ? Colors.indigo
                            : Colors.grey.shade400,
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ),

        // لوحة التحليل والعرض اليسرى مع عدادات دائرية وزر النصاب التدريسي
        Expanded(
          flex: 6,
          child: Obx(() {
            final currentProject = list[selectedProjectIndex.value];
            final double theory = currentProject.theoryHours;
            final double practical = currentProject.practicalHours;
            final double total = theory + practical;

            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_mosaic_rounded,
                          color: Colors.indigo.shade400,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "تفاصيل وتحليل المشروع المختار",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentProject.projectTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "معرف الفريد بالنظام: #${currentProject.projectId}",
                      style: TextStyle(
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // العدادات الإحصائية الدائرية الفخمة للحركات والحيوية البصرية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircularIndicator(
                          "الساعات النظرية",
                          theory,
                          total,
                          Colors.amber.shade600,
                          Icons.menu_book_rounded,
                        ),
                        _buildCircularIndicator(
                          "الساعات العملية",
                          practical,
                          total,
                          Colors.teal.shade500,
                          Icons.handyman_rounded,
                        ),
                      ],
                    ),
                    const Spacer(),

                    // شريط سفلي متطور يحتوي على تفاصيل وزر منبثق لتعبئة النصاب الزمني
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.indigo.shade100.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "إجمالي الساعات المعتمدة للمشروع:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$total ساعة تدريسية",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.bottomSheet(
                                QuotaFillingSheet(
                                  projectId: currentProject.projectId,
                                  projectTitle: currentProject.projectTitle,
                                ),
                                isScrollControlled: true,
                                barrierColor: Colors.black.withOpacity(0.3),
                              );
                            },
                            icon: const Icon(
                              Icons.add_alarm_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              "تعبئة النصاب الزمني",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 📱 واجهة الموبايل: نظام كروت عمودي نظيف وسريع
  Widget _buildMobileGrid(List<ProjectModel> list) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final project = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${project.projectId}',
                      style: TextStyle(
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.bottomSheet(
                          QuotaFillingSheet(
                            projectId: project.projectId,
                            projectTitle: project.projectTitle,
                          ),
                          isScrollControlled: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade50,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "تعبئة النصاب",
                        style: TextStyle(
                          color: Colors.indigo.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  project.projectTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "📖 نظري: ${project.theoryHours} س",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "🛠️ عملي: ${project.practicalHours} س",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircularIndicator(
    String title,
    double value,
    double total,
    Color color,
    IconData icon,
  ) {
    double percentage = total > 0 ? value / total : 0.0;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: color.withOpacity(0.8), size: 32),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$value ساعة",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
