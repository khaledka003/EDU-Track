import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Admin/Features/CoursesManagement/busines_logic_layer/CourseController.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/busines_logic_layer/InstructorController.dart';
import 'package:edutrack/Features/Admin/Features/RoomManagment/busines_logic_layer/RoomController.dart';
import 'package:edutrack/Features/Employee/CourseAllocation/presentation_layer/Widget/CustomSearchPicker.dart';
import 'package:edutrack/Features/Employee/ExamAssignment/busines_logic_layer/ExamAssignmentController.dart';

import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExamDutyScreen extends StatelessWidget {
  ExamDutyScreen({super.key});

  final ExamAssignmentController controller = Get.put(
    ExamAssignmentController(),
  );
  final CourseController courseController = Get.put(CourseController());
  final InstructorController instructorController = Get.put(
    InstructorController(),
  );
  final Roomcontroller roomController = Get.put(Roomcontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // القسم الأيسر: الإدخالات
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                    "بيانات الامتحان الأساسية",
                    Icons.assignment_outlined,
                  ),
                  _buildCourseDropdown(),
                  const SizedBox(height: 15),
                  _buildDateTimeRow(context),
                  const SizedBox(height: 15),
                  _buildRoomDropdown(),

                  const SizedBox(height: 30),
                  _buildSectionTitle(
                    "تحديد طاقم المراقبة (مراقب أو أكثر)",
                    Icons.groups_3_outlined,
                  ),
                  _buildStaffSelection(),

                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),

          // القسم الأيمن: المعاينة
          Expanded(flex: 4, child: Obx(() => _buildPreviewCard())),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: MyColors().Ocean_Blue),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Obx(() {
      if (courseController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (courseController.courses.isEmpty) {
        return const Text(
          "لا توجد مقررات متاحة",
          style: TextStyle(color: Colors.grey),
        );
      }
      return CustomSearchPicker(
        title: "البحث في المواد",
        hint: "اختر المادة الامتحانية",
        icon: Icons.book_outlined,
        selectedItem: controller.selectedCourse.value?['name'],
        items: RxList<String>(
          courseController.courses.map((e) => e.courseName).toList(),
        ),
        onSelected: (val) {
          var selected = courseController.courses.firstWhere(
            (e) => e.courseName == val,
          );
          controller.selectedCourse.value = {
            'name': selected.courseName,
            'id': selected.courseId.toString(),
          };
        },
      );
    });
  }

  Widget _buildRoomDropdown() {
    return Obx(() {
      if (roomController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (roomController.rooms.isEmpty) {
        return const Text(
          "لا توجد قاعات",
          style: TextStyle(color: Colors.grey),
        );
      }
      return CustomSearchPicker(
        title: "اختر القاعة الامتحانية",
        hint: "اضغط للبحث عن قاعة...",
        icon: Icons.meeting_room_outlined,
        selectedItem: controller.selectedRoomName.value,
        items: RxList<String>(
          roomController.rooms.map((r) => r['name'].toString()).toList(),
        ),
        onSelected: (val) {
          var room = roomController.rooms.firstWhere(
            (r) => r['name'].toString() == val,
          );
          controller.selectedRoomName.value = val;
          controller.selectedRoomId.value = room['id'];
        },
      );
    });
  }

  Widget _buildDateTimeRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) controller.selectedDate.value = picked;
            },
            child: Obx(
              () => Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      controller.selectedDate.value == null
                          ? "تاريخ الامتحان"
                          : DateFormat(
                              'yyyy-MM-dd',
                            ).format(controller.selectedDate.value!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        _buildTimeCard(
          context,
          title: "وقت البدء",
          time: controller.startTime,
          icon: Icons.play_circle_outline,
          color: Colors.blueAccent,
          onTap: () => controller.chooseTime(context, true),
        ),
        const SizedBox(width: 12),
        _buildTimeCard(
          context,
          title: "وقت النهاية",
          time: controller.endTime,
          icon: Icons.stop_circle_outlined,
          color: Colors.orangeAccent, // لون مختلف للنهاية لسهولة التمييز
          onTap: () => controller.chooseTime(context, false),
        ),
      ],
    );
  }

  Widget _buildStaffSelection() {
    return Column(
      children: [
        // استخدام Obx لضمان التفاعل مع حالة التحميل والبيانات
        Obx(() {
          if (controller.isInstructorsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomSearchPicker(
            title: "البحث عن مراقب",
            hint: "اضغط لإضافة مراقب للطاقم...",
            icon: Icons.person_add_alt_1_outlined,
            // جلب الأسماء من القائمة المحلية في الـ controller
            items: RxList<String>(
              controller.facultyInstructors
                  .map((i) => i['full_name'].toString().trim())
                  .toList(),
            ),
            onSelected: (val) {
              String selectedName = val.toString().trim();

              // البحث عن المدرس المختار لجلب بياناته كاملة
              var instructor = controller.facultyInstructors.firstWhere(
                (i) => i['full_name'].toString().trim() == selectedName,
              );

              controller.toggleStaff({
                'name': instructor['full_name'].toString(),
                'id': instructor['user_id']
                    .toString(), // تأكد أن المفاتيح تطابق الـ API
              });
            },
          );
        }),
        const SizedBox(height: 10),
        // عرض قائمة المراقبين المختارين
        Obx(() => _buildSelectedStaffList()),
      ],
    );
  }

  Widget _buildSelectedStaffList() {
    if (controller.selectedStaff.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.selectedStaff.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          var staff = controller.selectedStaff[index];
          return ListTile(
            title: Text(
              staff['name'] ?? "",
              style: const TextStyle(color: Colors.black),
            ),
            leading: const Icon(Icons.person_outline, color: Colors.black54),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => controller.toggleStaff(staff),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      margin: const EdgeInsets.all(25),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: MyColors().Oxford_Blue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ملخص التكليف",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            controller.selectedCourse.value?['name'] ?? "اسم المادة",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24, height: 40),
          _previewItem(
            Icons.calendar_today,
            "التاريخ: ",
            controller.selectedDate.value != null
                ? DateFormat(
                    'yyyy-MM-dd',
                  ).format(controller.selectedDate.value!)
                : "---",
          ),
          _previewItem(
            Icons.timer_outlined,
            "الوقت: ",
            controller.selectedTime.value ?? "---",
          ),
          _previewItem(
            Icons.place_outlined,
            "القاعة: ",
            controller.selectedRoomName.value ?? "---",
          ),
          const SizedBox(height: 30),
          const Text(
            "طاقم المراقبة المختار:",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: controller.selectedStaff.isEmpty
                ? const Text(
                    "لم يتم اختيار مراقبين بعد",
                    style: TextStyle(color: Colors.white30),
                  )
                : ListView(
                    children: controller.selectedStaff
                        .map(
                          (s) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  s['name']!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _previewItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white60)),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(
    BuildContext context, {
    required String title,
    required Rxn<TimeOfDay> time,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Obx(() {
        bool isSelected = time.value != null;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isSelected ? color : Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time.value?.format(context) ?? "-- : --",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.black87 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors().Deep_Ocean_Blue,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: controller.isLoading.value
              ? null
              : controller.submitAssignment,
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "اعتماد تكليف المراقبين",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
        ),
      ),
    );
  }
}
