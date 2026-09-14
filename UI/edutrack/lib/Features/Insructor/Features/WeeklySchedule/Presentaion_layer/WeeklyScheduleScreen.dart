import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edutrack/Features/Insructor/Features/WeeklySchedule/busines_logic_layer/WeeklyController.dart';

class WeeklyScheduleScreen extends StatelessWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استدعاء الكنترولر
    final WeeklyController controller = Get.put(WeeklyController());

    final List<String> weekOrder = [
      "الأحد",
      "الاثنين",
      "الثلاثاء",
      "الأربعاء",
      "الخميس",
      "الجمعة",
      "السبت",
    ];

    // متغير لمتابعة اليوم المختار في نسخة الموبايل
    var selectedDay = controller.currentDayArabic.obs;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // إذا كان العرض أكبر من 1100 بكسل نعتبره لابتوب
          if (constraints.maxWidth > 1100) {
            return _buildLaptopView(weekOrder, controller);
          } else {
            // غير ذلك نعتبره موبايل
            return _buildMobileView(weekOrder, controller, selectedDay);
          }
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // تصميم اللابتوب (الأول - نظام الأعمدة المتجاورة)
  // ---------------------------------------------------------------------------
  Widget _buildLaptopView(List<String> days, WeeklyController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: days
              .map(
                (day) => Expanded(
                  child: _buildDayColumnLaptop(
                    day,
                    controller.weeklyData[day] ?? [],
                    controller,
                  ),
                ),
              )
              .toList(),
        ),
      );
    });
  }

  Widget _buildDayColumnLaptop(
    String dayName,
    List<dynamic> lectures,
    WeeklyController controller,
  ) {
    bool isToday = dayName == controller.currentDayArabic;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isToday ? Colors.white : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF1F2937),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Text(
              dayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: lectures.isEmpty
                ? const Center(
                    child: Text("لا محاضرات", style: TextStyle(fontSize: 10)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: lectures.length,
                    itemBuilder: (context, index) =>
                        _buildLaptopCard(lectures[index], isToday),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaptopCard(Map<String, dynamic> item, bool isToday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['course'] ?? "",
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(item['time'] ?? "", style: const TextStyle(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // تصميم الموبايل (الثاني - نظام شريط الأيام العلوي)
  // ---------------------------------------------------------------------------
  Widget _buildMobileView(
    List<String> days,
    WeeklyController controller,
    RxString selectedDay,
  ) {
    return Column(
      children: [
        // شريط الأيام العلوي
        Container(
          padding: const EdgeInsets.only(
            top: 40,
            bottom: 16,
          ), // Padding للأعلى بسبب الـ AppBar الملغي
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Obx(
              () => Row(
                children: days.map((day) {
                  bool isSelected = selectedDay.value == day;
                  bool isRealToday = day == controller.currentDayArabic;
                  return GestureDetector(
                    onTap: () => selectedDay.value = day,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isRealToday)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        // قائمة المحاضرات
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            var lectures = controller.weeklyData[selectedDay.value] ?? [];
            if (lectures.isEmpty) return _buildMobileEmptyState();
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lectures.length,
              itemBuilder: (context, index) =>
                  _buildMobileLectureTile(lectures[index]),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMobileLectureTile(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.access_time, size: 16, color: Color(0xFF3B82F6)),
              const SizedBox(height: 4),
              Text(
                item['time'].split(' - ')[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                item['time'].split(' - ')[1],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 20),
          const SizedBox(height: 40, child: VerticalDivider(thickness: 1)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['course'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['room'],
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "لا يوجد محاضرات لهذا اليوم",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
