import 'package:edutrack/Features/Employee/Lecture_mangment/busines_logic_layer/EmployeeManagementController.dart';
import 'package:edutrack/Features/Employee/Lecture_mangment/data_layer/Model/EmployeeLectureModel.dart';
import 'package:edutrack/Features/Employee/CourseAllocation/presentation_layer/Widget/CustomSearchPicker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// تأكد من استيراد المسار الصحيح للـ CustomSearchPicker هنا
// import 'path_to_custom_search_picker/CustomSearchPicker.dart';

class EmployeeLecturesView extends StatelessWidget {
  const EmployeeLecturesView({super.key});

  @override
  Widget build(BuildContext context) {
    EmployeeManagementController controller = Get.put(
      EmployeeManagementController(),
    );

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------- قسم الفلاتر (Pickers) -----------------
              // ----------------- قسم الفلاتر (Pickers) -----------------
              Obx(() {
                if (controller.isLoadingFilters.value) {
                  return const LinearProgressIndicator();
                }
                return Card(
                  elevation: 2, // تقليل الـ elevation ليصبح التصميم أنعم وملموم
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ), // تقليل الحواشي العمودية
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // سطر العنوان وزر إعادة التعيين
                        Row(
                          children: [
                            const Icon(
                              Icons.filter_alt,
                              color: Colors.indigo,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'خيارات الفلترة والبحث',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: controller.resetFilters,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                              ),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text(
                                'إعادة تعيين',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 8, thickness: 0.8),
                        const SizedBox(height: 4),

                        // سطر الفلاتر الرئيسي (البحث في المدرسين + البحث في المقررات) بجانب بعضهما
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. اختيار المدرس
                            Expanded(
                              child: CustomSearchPicker(
                                title: "البحث في المدرسين",
                                hint: "اختر مدرس...",
                                icon: Icons.person_search_rounded,
                                selectedItem: controller.facultyInstructors
                                    .firstWhereOrNull(
                                      (e) =>
                                          e['instructor_id'] ==
                                          controller.selectedInstructorId.value,
                                    )?['full_name'],
                                items: RxList<String>(
                                  controller.facultyInstructors
                                      .map((e) => e['full_name'].toString())
                                      .toList(),
                                ),
                                onSelected: (val) {
                                  var selected = controller.facultyInstructors
                                      .firstWhereOrNull(
                                        (e) => e['full_name'] == val,
                                      );
                                  controller.selectedInstructorId.value =
                                      selected != null
                                      ? selected['instructor_id']
                                      : null;
                                  controller.fetchLectures();
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ), // مسافة أفقية بين الفلترين
                            // 2. اختيار المادة الدراسية
                            Expanded(
                              child: CustomSearchPicker(
                                title: "البحث في مقررات الكلية",
                                hint: "ابحث عن مقرر...",
                                icon: Icons.library_books_rounded,
                                selectedItem: controller.facultyCourses
                                    .firstWhereOrNull(
                                      (e) =>
                                          e['course_id'] ==
                                          controller.selectedCourseId.value,
                                    )?['course_name'],
                                items: RxList<String>(
                                  controller.facultyCourses
                                      .map((e) => e['course_name'].toString())
                                      .toList(),
                                ),
                                onSelected: (val) {
                                  var selected = controller.facultyCourses
                                      .firstWhereOrNull(
                                        (e) => e['course_name'] == val,
                                      );
                                  controller.selectedCourseId.value =
                                      selected != null
                                      ? selected['course_id']
                                      : null;
                                  controller.fetchLectures();
                                },
                              ),
                            ),
                          ],
                        ),

                        // 3. تصفية حسب أيام العطل (تظهر فقط إذا كانت متوفرة دون أخذ مساحة إضافية كبيرة)
                        if (controller.holidays.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'أيام العطل:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: 40, // تقليص الارتفاع لتوفير مساحة عمودية
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.holidays.length,
                              itemBuilder: (context, index) {
                                final holiday = controller.holidays[index];
                                final isSelected =
                                    controller.selectedHolidayDate.value ==
                                    holiday.date;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3.0,
                                  ),
                                  child: FilterChip(
                                    visualDensity: VisualDensity
                                        .compact, // ضغط الـ Chip لتصبح أصغر
                                    label: Text(
                                      '${holiday.date} (${holiday.dayName})',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    selected: isSelected,
                                    selectedColor: Colors.orange.shade100,
                                    checkmarkColor: Colors.orange.shade800,
                                    onSelected: (bool selected) {
                                      controller.selectedHolidayDate.value =
                                          selected ? holiday.date : null;
                                      controller.fetchLectures();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // ----------------- قسم عرض الفئات والجدول -----------------
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingLectures.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.lectures.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا يوجد فئات تطابق البحث الحالي.',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.lectures.length,
                    itemBuilder: (context, index) {
                      final lecture = controller.lectures[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            '${lecture.courseName} (${lecture.lectureType})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.indigo,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('المدرس: ${lecture.instructorName}'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'اليوم: ${lecture.dayOfWeek} | التوقيت: ${lecture.startTime} - ${lecture.endTime}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.room,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('القاعة: ${lecture.roomName}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                tooltip: 'تعديل كامل للفئة',
                                onPressed: () => _showEditLectureDialog(
                                  context,
                                  controller,
                                  lecture,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'حذف الفئة',
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: 'تأكيد الحذف',
                                    middleText:
                                        'هل أنت متأكد من حذف هذه الفئة نهائياً من الجدول الأسبوعي؟',
                                    textConfirm: 'نعم، احذف',
                                    textCancel: 'إلغاء',
                                    confirmTextColor: Colors.white,
                                    buttonColor: Colors.red,
                                    onConfirm: () {
                                      Get.back();
                                      controller.deleteLecture(
                                        lecture.lectureId,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- دايلوج تعديل كامل الفئة الأساسية -----------------
  void _showEditLectureDialog(
    BuildContext context,
    EmployeeManagementController controller,
    EmployeeLectureModel lecture,
  ) {
    final dayController = TextEditingController(text: lecture.dayOfWeek);
    final startController = TextEditingController(text: lecture.startTime);
    final endController = TextEditingController(text: lecture.endTime);

    Get.defaultDialog(
      title: 'تعديل الفئة بالجدول العام',
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            TextField(
              controller: dayController,
              decoration: const InputDecoration(labelText: 'يوم الأسبوع'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: startController,
              decoration: const InputDecoration(labelText: 'وقت البدء'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: endController,
              decoration: const InputDecoration(labelText: 'وقت الانتهاء'),
            ),
          ],
        ),
      ),
      textConfirm: 'تحديث البيانات',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.updateLecture(lecture.lectureId, {
          'day_of_week': dayController.text,
          'start_time': startController.text,
          'end_time': endController.text,
        });
      },
    );
  }
}
