import 'package:edutrack/Features/Admin/Features/InstructorsManagement/busines_logic_layer/InstructorController.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/presentation_layer/Widget/InstructorForm.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/presentation_layer/Widget/InstructorsTable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstructorsManagementScreen extends StatefulWidget {
  const InstructorsManagementScreen({super.key});

  @override
  State<InstructorsManagementScreen> createState() =>
      _InstructorsManagementScreenState();
}

class _InstructorsManagementScreenState
    extends State<InstructorsManagementScreen> {
  InstructorController controller = Get.put(InstructorController());
  @override
  void initState() {
    super.initState();
    controller.loadInstructors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // ليظهر لون خلفية الداشبورد الأساسية
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. قسم الفورم (يسار أو يمين حسب اللغة) - أعطيناه شكل كرت منفصل
          Expanded(
            flex: 35,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: InstructorForm(),
              ),
            ),
          ),

          // 2. قسم الجدول - كرت آخر منفصل ليعطي طابع الـ Dashboard الموزعة
          Expanded(
            flex: 65,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: GetBuilder<InstructorController>(
                builder: (controller) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      ),
                    );
                  }
                  if (controller.errorMessage != null) {
                    return _buildErrorState(controller);
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(25.0),
                    child: InstructorsTable(
                      instructors: controller.instructors,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(InstructorController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 15),
          Text(
            controller.errorMessage!,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => controller.loadInstructors(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
            ),
            child: const Text(
              "Try_again",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
