import 'package:edutrack/Features/Employee/CourseAllocation/presentation_layer/Widget/CustomSearchPicker.dart';
import 'package:edutrack/Features/Employee/Project_Allocation/busines_logic_layer/ProjectAllocationController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProjectAllocationFormView extends StatelessWidget {
  ProjectAllocationFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProjectAllocationController());
    final double screenWidth = MediaQuery.of(context).size.width;

    // تحديد نوع الشاشة (كبيرة أو صغيرة) بناءً على العرض المتاح
    final bool isLargeScreen =
        screenWidth > 950; // تم رفع القيمة قليلاً لتناسب العرض الجانبي المريح

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50.withOpacity(0.4),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Container(
              // نوسع الحد الأقصى للعرض في الشاشات الكبيرة ليتسع للطرفين معاً
              constraints: BoxConstraints(maxWidth: isLargeScreen ? 1200 : 700),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: controller.formKey,
                  child: isLargeScreen
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1️⃣ الطرف الأيمن: نموذج إدخال البيانات والإسناد
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProjectAllocationFields(
                                    controller,
                                    isLargeScreen,
                                  ),
                                  const SizedBox(height: 32),
                                  _buildDivider(),
                                  const SizedBox(height: 12),
                                  _buildFormActions(controller),
                                ],
                              ),
                            ),

                            // فاصل عمودي أنيق بين القسمين في الشاشات الكبيرة
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              height: 500, // طول تقريبي يناسب العناصر الجانبية
                              width: 1.2,
                              color: Colors.grey.shade200,
                            ),

                            // 2️⃣ الطرف الأيسر: عرض مشاريع الدكتور الحالية (بجانب الفورم)
                            Expanded(
                              flex: 3,
                              child: _buildInstructorProjectsSection(
                                controller,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          // التصميم المتجاوب للشاشات الصغيرة (أسفل بعضهم البعض)
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProjectAllocationFields(
                              controller,
                              isLargeScreen,
                            ),
                            const SizedBox(height: 32),
                            _buildDivider(),
                            const SizedBox(height: 12),
                            _buildFormActions(controller),
                            const SizedBox(height: 40),
                            _buildDivider(),
                            const SizedBox(height: 16),
                            _buildInstructorProjectsSection(controller),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // تجميع أزرار الحفظ والتنظيف في تابع مستقل لتجنب التكرار في شروط الشاشات
  Widget _buildFormActions(ProjectAllocationController controller) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 140,
                  child: OutlinedButton(
                    onPressed: () => controller.clearForm(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "إلغاء وتنظيف",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () => controller.submitAllocation(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue.shade700,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "تثبيت وحفظ الإسناد",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProjectAllocationFields(
    ProjectAllocationController controller,
    bool isLargeScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("1️⃣ اختيار المدرس المشرف"),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isFetchingInstructors.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return CustomSearchPicker(
            title: "مدرسي الكلية",
            hint: "ابحث عن اسم المدرس المعتمد...",
            icon: Icons.person_search_rounded,
            selectedItem: controller.selectedInstructorName.value.isEmpty
                ? null
                : controller.selectedInstructorName.value,
            items: RxList<String>(
              controller.facultyInstructors
                  .map((i) => i['full_name'].toString())
                  .toList(),
            ),
            onSelected: (val) {
              controller.onInstructorSelected(val);
              controller.fetchInstructorProjects();
            },
          );
        }),
        Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: controller.selectedInstructorDept.isNotEmpty ? 42 : 0,
            child: controller.selectedInstructorDept.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.widgets_outlined,
                          size: 16,
                          color: Colors.blue.shade800,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "القسم الحالي للدكتور: ${controller.selectedInstructorDept.value}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),

        const SizedBox(height: 24),

        _buildSectionHeader("2️⃣ القسم الأكاديمي"),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isFetchingDepartments.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return CustomSearchPicker(
            title: "الأقسام المتاحة",
            hint: "اختر القسم المستهدف للعملية...",
            icon: Icons.account_tree_outlined,
            selectedItem: controller.selectedDepartmentName.value.isEmpty
                ? null
                : controller.selectedDepartmentName.value,
            items: RxList<String>(
              controller.facultyDepartments
                  .map((d) => d['name'].toString())
                  .toList(),
            ),
            onSelected: (val) => controller.onDepartmentSelected(val),
          );
        }),

        const SizedBox(height: 24),

        _buildSectionHeader("3️⃣ نوع المشروع والساعات المعتمدة"),
        const SizedBox(height: 14),
        Obx(
          () => DropdownButtonFormField<String>(
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontFamily: 'Tajawal',
            ),
            decoration: _buildInputDecoration(
              label: "تصنيف المادة / المشروع",
              icon: Icons.workspace_premium_outlined,
            ),
            value: controller.selectedProjectType.value,
            items: controller.projectTypes.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.selectedProjectType.value = val;
            },
          ),
        ),

        const SizedBox(height: 16),

        // بقاء حقول الساعات بجانب بعضها معتمد على تمدد الشاشة الأساسي للفورم
        if (isLargeScreen)
          Row(
            children: [
              Expanded(child: _buildTheoryHoursField(controller)),
              const SizedBox(width: 16),
              Expanded(child: _buildPracticalHoursField(controller)),
            ],
          )
        else
          Column(
            children: [
              _buildTheoryHoursField(controller),
              const SizedBox(height: 16),
              _buildPracticalHoursField(controller),
            ],
          ),
      ],
    );
  }

  Widget _buildTheoryHoursField(ProjectAllocationController controller) {
    return TextFormField(
      controller: controller.theoryHoursController,
      style: const TextStyle(fontSize: 14),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: _buildInputDecoration(
        label: "الساعات النظرية",
        icon: Icons.menu_book_rounded,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "حقل الساعات النظرية مطلوب" : null,
    );
  }

  Widget _buildPracticalHoursField(ProjectAllocationController controller) {
    return TextFormField(
      controller: controller.practicalHoursController,
      style: const TextStyle(fontSize: 14),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: _buildInputDecoration(
        label: "الساعات العملية",
        icon: Icons.handyman_rounded,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "حقل الساعات العملية مطلوب" : null,
    );
  }

  Widget _buildInstructorProjectsSection(
    ProjectAllocationController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // الحفاظ على حجم مرن داخل الـ Row
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildSectionHeader("📊 الإسنادات الحالية للمدرس")),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "العدد: ${controller.totalCount.value}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (controller.selectedInstructorId.isEmpty) {
            return Text(
              "قم باختيار المدرس أولاً لعرض مشاريعه الحالية.",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            );
          }

          if (controller.projectList.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: Text(
                  "لا يوجد مشاريع مسندة حالياً لهذا المدرس.",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.projectList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final project = controller.projectList[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(
                      Icons.assignment_turned_in_outlined,
                      color: Colors.blue.shade700,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    project.projectTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "${controller.projectTypes[project.projectTypeKey] ?? project.projectTypeDisplay}\nنظري: ${project.theoryHours} | عملي: ${project.practicalHours}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () {
                      Get.defaultDialog(
                        title: "تأكيد الحذف",
                        middleText: "هل أنت متأكد من رغبتك في حذف هذا الإسناد؟",
                        textConfirm: "نعم، احذف",
                        textCancel: "تراجع",
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.redAccent,
                        onConfirm: () {
                          Get.back();
                          controller.deleteProject(project.projectId);
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey.shade600),
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      floatingLabelStyle: TextStyle(
        color: Colors.blue.shade700,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.8),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Divider(color: Colors.grey.shade100, thickness: 1.2),
    );
  }
}
