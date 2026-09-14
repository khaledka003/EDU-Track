import 'package:edutrack/Features/Employee/Lecture_mangment/data_layer/Model/EmployeeLectureModel.dart';
import 'package:edutrack/Features/Insructor/Features/Compensatory/busines_logic_layer/InstructorManagementcontroller.dart';
import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstructorLecturesView extends StatelessWidget {
  const InstructorLecturesView({super.key});

  @override
  Widget build(BuildContext context) {
    InstructorManagementcontroller controller = Get.put(
      InstructorManagementcontroller(),
    );

    return Scaffold(
      backgroundColor: const Color(
        0xffF8FAFC,
      ), // خلفية ناعمة جداً تبرز البطاقات
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingLectures.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.indigo,
                      ),
                    );
                  }

                  if (controller.lectures.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا يوجد فئات تطابق البحث الحالي.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // ✅ السحر هنا: Grid متجاوب يناسب الموبايل والشاشات الكبيرة تلقائياً
                  return GridView.builder(
                    itemCount: controller.lectures.length,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent:
                              450, // أقصى عرض للبطاقة قبل أن تفتح واحدة بجانبها
                          mainAxisExtent:
                              175, // الارتفاع الثابت والمثالي للبطاقة
                          crossAxisSpacing: 16, // المسافة الأفقية بين البطاقات
                          mainAxisSpacing: 16, // المسافة العمودية بين البطاقات
                        ),
                    itemBuilder: (context, index) {
                      final lecture = controller.lectures[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          // ظلال ناعمة جداً خالية من الحواف الحادة تمنح البطاقة طابعاً عائماً (Floating)
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade100,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // 🎨 لمسة جمالية: شريط جانبي ملون يعطي هوية بصرية لكل بطاقة
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 5,
                                  color: Colors.indigo.shade400,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  16,
                                  20,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // العنوان ونوع المحاضرة
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            lecture.courseName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xff0F172A),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            lecture.lectureType,
                                            style: TextStyle(
                                              color: Colors.indigo.shade700,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // تفاصيل المدرس والقاعة والوقت مرتبة بشكل نظيف جداً
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildInfoRow(
                                            Icons.person_outline_rounded,
                                            'المدرس: ${lecture.instructorName}',
                                          ),
                                          const SizedBox(height: 6),
                                          _buildInfoRow(
                                            Icons.access_time_rounded,
                                            'اليوم: ${lecture.dayOfWeek} | ${lecture.startTime} - ${lecture.endTime}',
                                          ),
                                          const SizedBox(height: 6),
                                          _buildInfoRow(
                                            Icons.room_outlined,
                                            'القاعة: ${lecture.roomName}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    // الزر السفلي للتعويض بتصميم فخم ومستقل
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: TextButton.icon(
                                        onPressed: () =>
                                            _showCompensatoryDialog(
                                              context,
                                              controller,
                                              lecture,
                                            ),
                                        style: TextButton.styleFrom(
                                          backgroundColor: MyColors().emerald
                                              .withOpacity(0.12),

                                          foregroundColor: MyColors().emerald,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),

                                        icon: const Icon(
                                          Icons.add_alarm_rounded,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'تعويض',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xff94A3B8),
        ), // لون رمادي كول ومريح
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff475569),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  // ----------------- دايلوج إضافة محاضرة تعويضية -----------------
  void _showCompensatoryDialog(
    BuildContext context,
    InstructorManagementcontroller controller,
    EmployeeLectureModel lecture,
  ) {
    final dateController = TextEditingController();
    final startTimeController = TextEditingController(text: lecture.startTime);
    final endTimeController = TextEditingController(text: lecture.endTime);
    int selectedRoomId = lecture.roomId ?? 1;

    Future<void> _selectTime(
      BuildContext ctx,
      TextEditingController textController,
    ) async {
      TimeOfDay initialTime = TimeOfDay.now();
      if (textController.text.isNotEmpty) {
        try {
          final parts = textController.text.split(':');
          initialTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        } catch (_) {}
      }

      TimeOfDay? pickedTime = await showTimePicker(
        context: ctx,
        initialTime: initialTime,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: Colors.indigo),
              ),
              child: child!,
            ),
          );
        },
      );

      if (pickedTime != null) {
        final String formattedHour = pickedTime.hour.toString().padLeft(2, '0');
        final String formattedMinute = pickedTime.minute.toString().padLeft(
          2,
          '0',
        );
        textController.text = '$formattedHour:$formattedMinute';
      }
    }

    Get.defaultDialog(
      title: 'إضافة محاضرة تعويضية',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Color(0xff0F172A),
      ),
      radius: 18,
      contentPadding: const EdgeInsets.all(20),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مادة: ${lecture.courseName}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'مدرس: ${lecture.instructorName}',
                style: const TextStyle(color: Color(0xff64748B), fontSize: 12),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: dateController,
                label: 'تاريخ التعويض',
                hint: 'اختر تاريخ المحاضرة البديلة',
                icon: Icons.date_range_rounded,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                    lastDate: DateTime(2030),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.indigo,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (pickedDate != null) {
                    dateController.text = pickedDate.toString().split(' ')[0];
                  }
                },
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: startTimeController,
                label: 'وقت البدء',
                icon: Icons.access_time_rounded,
                onTap: () => _selectTime(context, startTimeController),
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: endTimeController,
                label: 'وقت الانتهاء',
                icon: Icons.access_time_filled_rounded,
                onTap: () => _selectTime(context, endTimeController),
              ),
            ],
          ),
        ),
      ),
      textConfirm: 'حفظ كتعويضي',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      cancelTextColor: const Color(0xff64748B),
      buttonColor: Colors.indigo,
      onConfirm: () {
        if (dateController.text.isEmpty) {
          Get.snackbar(
            'تنبيه',
            'الرجاء اختيار تاريخ أولاً',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.amber.shade50,
            colorText: Colors.amber.shade900,
            margin: const EdgeInsets.all(12),
            borderRadius: 8,
          );
          return;
        }

        Get.back();

        controller.addCompensatory(
          courseAllocationId: lecture.courseAllocationId,
          roomId: selectedRoomId,
          date: dateController.text,
          start: startTimeController.text,
          end: endTimeController.text,
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xff64748B), fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xff94A3B8), fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.indigo, size: 20),
        filled: true,
        fillColor: const Color(0xffF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
        ),
      ),
    );
  }
}
