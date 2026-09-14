import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Insructor/Features/DailyLectures/Presentaion_layer/Widget/InfoCard.dart';
import 'package:edutrack/Features/Insructor/Features/DailyLectures/busines_logic_layer/LecturesController.dart';
import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class DailyLecturesScreen extends StatelessWidget {
  DailyLecturesScreen({super.key});

  // استدعاء الكنترولر
  final LecturesController controller = Get.put(LecturesController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 1 : 2;

    return Scaffold(
      backgroundColor: MyColors().Ghost_White,
      body: RefreshIndicator(
        onRefresh: () async {
          // عند السحب للأسفل، يعيد جلب البيانات بالتاريخ الجديد
          controller.loadInitialData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Obx(() {
          // 1. حالة التحميل
          if (controller.isLoading.value && controller.lecturesList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. حالة الخطأ (النت مقطوع)
          if (controller.hasError.value) {
            return _buildStateView(
              icon: Icons.wifi_off_rounded,
              iconColor: Colors.red.shade300,
              title: "فشل في الاتصال",
              description: "تأكد من الإنترنت وحاول مجدداً",
              onRetry: () => controller.loadInitialData(),
            );
          }

          // 3. الحالة الديناميكية (إما عطلة، أو جدول فارغ، أو خارج الفصل)
          // إذا كانت القائمة فارغة، نعرض الرسالة القادمة من الباك إند
          if (controller.isEmpty.value || controller.lecturesList.isEmpty) {
            return ListView(
              // استخدمنا ListView ليتمكن الـ RefreshIndicator من العمل
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                _buildStateView(
                  icon: Icons.event_note_rounded,
                  iconColor: Colors.orange.shade300,
                  // هنا نستخدم الرسالة القادمة من الباك إند مباشرة
                  title: controller.serverMessage.value.isEmpty
                      ? "لا يوجد بيانات"
                      : controller.serverMessage.value,
                  description: "اسحب للأسفل للتحديث إذا تغير التاريخ",
                  onRetry: () => controller.loadInitialData(),
                ),
              ],
            );
          }

          // 4. حالة وجود محاضرات
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 175,
                  ),
                  itemCount: controller.lecturesList.length,
                  itemBuilder: (context, index) {
                    final lecture = controller.lecturesList[index];
                    return InfoCard(
                      title: lecture.subject,
                      subTitle: lecture.type,
                      time: lecture.time,
                      room: lecture.room,
                      isChecked: lecture.isChecked,
                      onCheckChanged: () => controller.toggleStatus(index),
                    );
                  },
                ),
              ),
              _buildSaveButton(),
            ],
          );
        }),
      ),
    );
  }

  // --- ودجيت مساعدة لعرض الحالات (خطأ أو فارغ) ---
  Widget _buildStateView({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("تحديث"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- ودجيت زر الحفظ ---
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.saveLectures(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                tr("save_daily_changes"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
