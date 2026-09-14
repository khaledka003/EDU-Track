import 'package:edutrack/Features/Admin/Features/CoursesManagement/busines_logic_layer/CourseController.dart';
import 'package:edutrack/Features/Admin/Features/CoursesManagement/presentation_layer/Widget/CourseDataSource.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Style/Colors.dart';

class CoursesManagementScreen extends StatelessWidget {
  const CoursesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CourseController controller = Get.put(CourseController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // خلفية فاتحة ومريحة
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // القسم الأيسر: نموذج الإضافة والتعديل
          Expanded(
            flex: 35,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: _buildAddCourseForm(controller),
              ),
            ),
          ),

          VerticalDivider(
            width: 1,
            thickness: 1,
            color: MyColors().Deep_Ocean_Blue.withOpacity(0.1),
          ),

          // القسم الأيمن: جدول البيانات
          Expanded(
            flex: 65,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('distributed_courses_list'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: MyColors().Oxford_Blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: _buildCoursesTable(controller, context),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // مكوّن فورم الإضافة والتعديل المطور
  Widget _buildAddCourseForm(CourseController controller) {
    return GetBuilder<CourseController>(
      builder: (_) {
        bool isEditing = controller.editingCourseId != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? "تعديل بيانات المقرر" : tr('add_new_course'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isEditing ? Colors.orange : MyColors().Deep_Ocean_Blue,
              ),
            ),
            const SizedBox(height: 25),

            // رمز المقرر
            _buildModernTextField(
              controller: controller.codeController,
              label: tr('course_code_label'),
              icon: Icons.qr_code_rounded,
            ),
            const SizedBox(height: 15),

            // اسم المقرر
            _buildModernTextField(
              controller: controller.nameController,
              label: tr('course_name_label'),
              icon: Icons.book_rounded,
            ),
            const SizedBox(height: 15),

            // الساعات النظري والعملي في سطر واحد
            Row(
              children: [
                Expanded(
                  child: _buildModernTextField(
                    controller: controller.theoryHoursController,
                    label: tr('theory_hours'),
                    icon: Icons.menu_book_rounded,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildModernTextField(
                    controller: controller.practicalHoursController,
                    label: tr('practical_hours'),
                    icon: Icons.science_rounded,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // --- دروب داون الكلية ---
            _buildModernDropdown(
              label: tr('faculty_label'),
              icon: Icons.location_city_rounded,
              value: controller.selectedFaculty, // القيمة المختارة (اسم الكلية)
              items: controller.faculties
                  .map((f) => f.name)
                  .toList(), // جلب الأسماء من قائمة الـ FacultyModel
              onChanged: (val) => controller.updateFaculty(val),
            ),
            const SizedBox(height: 15),

            // --- دروب داون القسم ---
            _buildModernDropdown(
              label: tr('department_label'),
              icon: Icons.account_tree_rounded,
              value:
                  controller.selectedDepartment, // القيمة المختارة (اسم القسم)
              // استخدام قائمة الأقسام التي تم جلبها ديناميكياً في الكنترولر
              items: controller.departments,
              onChanged: controller.selectedFaculty == null
                  ? null
                  : (val) => controller.updateDepartment(val),
              hint: controller.selectedFaculty == null
                  ? tr('select_faculty_first')
                  : null,
            ),

            const SizedBox(height: 30),

            // زر الحفظ / التعديل
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // استدعاء دالة الحفظ الموحدة التي تتعامل مع الحالتين
                  controller.saveCourse();

                  // إذا كنت تريد إغلاق الصفحة أو الـ BottomSheet بعد الحفظ بنجاح
                  // يمكنك إضافة منطق بسيط هنا أو داخل الدالة في الكنترولر
                },
                icon: Icon(
                  controller.isEditing
                      ? Icons.save_as_rounded
                      : Icons.add_task_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  controller.isEditing
                      ? tr('update_course_btn')
                      : tr('save_course_btn'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isEditing
                      ? Colors.orange
                      : const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            // زر إلغاء التعديل (يظهر فقط عند التعديل)
            if (isEditing) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () => controller.clearFields(),
                  icon: const Icon(Icons.close_rounded, color: Colors.red),
                  label: const Text(
                    "إلغاء عملية التعديل",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // مكوّن الحقول النصية الحديث
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1),
        ),
      ),
    );
  }

  // مكوّن القوائم المنسدلة الحديث
  Widget _buildModernDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    String? hint,
  }) {
    // حماية ضد خطأ الـ Assertion
    String? validValue = items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: validValue,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCoursesTable(CourseController controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PaginatedDataTable(
          header: Text(tr('courses_dept_table')),
          rowsPerPage: 8,
          columns: [
            DataColumn(label: Text(tr('col_code'))),
            DataColumn(label: Text(tr('col_course'))),
            DataColumn(label: Text(tr('col_dept'))),
            DataColumn(label: Text(tr('col_hours'))),
            DataColumn(label: Text(tr('col_actions'))),
          ],
          source: CourseDataSource(controller.courses, controller),
        ),
      ),
    );
  }
}
