import 'package:edutrack/Features/Insructor/Features/AcademicLog/Data_layer/Model/LogActivityModel.dart';
import 'package:edutrack/Features/Insructor/Features/AcademicLog/busines_logic_layer/LogController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class AcademicLogScreen extends StatelessWidget {
  LogController controller = Get.put(LogController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          "سجل النشاطات الأكاديمية",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildTopDatePicker(context), // شريط التاريخ العلوي
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value)
                return Center(child: CircularProgressIndicator());
              if (controller.activitiesList.isEmpty) return _buildEmptyState();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.activitiesList.length,
                itemBuilder: (context, index) =>
                    _buildActivityCard(controller.activitiesList[index], index),
              );
            }),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  // استبدل ويدجت _buildCalendarStrip بهذا التصميم
  Widget _buildTopDatePicker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "عرض سجل تاريخ:",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  DateFormat(
                    'EEEE, d MMMM',
                    'ar',
                  ).format(controller.selectedDate.value),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // زر اختيار التاريخ
          InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2025), // بداية الفصل الدراسي
                lastDate: DateTime.now(),
                locale: const Locale('ar'), // ليكون التقويم بالعربي
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF3B82F6), // لونك الأساسي
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                controller.fetchActivitiesForDate(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء كرت النشاط (محاضرة أو تكليف)
  Widget _buildActivityCard(LogActivityModel item, int index) {
    bool isExam = item.type == ActivityType.exam;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          // أيقونة النوع
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isExam
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExam ? Icons.assignment_late : Icons.menu_book,
              color: isExam ? Colors.orange : Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // تفاصيل النشاط
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.typeLabel,
                  style: TextStyle(
                    color: isExam ? Colors.orange : Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      item.time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.room,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // الـ Checkbox للتعديل في الماضي
          Obx(
            () => Checkbox(
              value: item.isChecked.value,
              activeColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (val) => controller.toggleStatus(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () => controller.saveChanges(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "حفظ التعديلات في السجل",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "لا يوجد سجل نشاطات لهذا التاريخ",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
