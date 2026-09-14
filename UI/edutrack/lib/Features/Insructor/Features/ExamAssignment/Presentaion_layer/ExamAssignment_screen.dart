import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Insructor/Features/ExamAssignment/Data_layer/Model/ExamModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:edutrack/Style/Colors.dart';
import '../busines_logic_layer/ExamsController.dart';
import '../../DailyLectures/Presentaion_layer/Widget/InfoCard.dart';

class ExamAssignmentsScreen extends StatelessWidget {
  const ExamAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام Get.find إذا تم حقنه مسبقاً أو Get.put هنا
    final ExamsController controller = Get.put(ExamsController());

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 1 : 2;

    return Scaffold(
      backgroundColor: MyColors().Ghost_White,
      // appBar: AppBar(
      //   title: Text(tr("exam_assignments")),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh),
      //       onPressed: () => controller.loadExams(),
      //     ),
      //   ],
      // ),
      body: Obx(() {
        // حالة التحميل
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // حالة القائمة الفارغة
        if (controller.examsList.isEmpty) {
          return Center(child: Text(tr("no_exams_found")));
        }

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
                itemCount: controller.examsList.length,
                itemBuilder: (context, index) {
                  ExamModel exam = controller.examsList[index];
                  return InfoCard(
                    title: exam.course, // تم التغيير من subject إلى course
                    subTitle: exam.date,
                    time: exam.time,
                    room: exam.room,
                    isChecked: exam.isChecked, // .value لأنها RxBool
                    onCheckChanged: () => controller.toggleStatus(index),
                  );
                },
              ),
            ),

            // زر الحفظ
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => controller.saveExams(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  tr("save_assignments_status"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
