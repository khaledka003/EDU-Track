import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/busines_logic_layer/InstructorController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstructorForm extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _ranks = ['دكتوراه', 'مدرس', 'معيد', 'أستاذ مساعد'];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstructorController>(
      builder: (controller) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.isEditing
                    ? "تعديل بيانات مدرس"
                    : tr('add_edit_instructor'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 25),
              _buildModernField(
                tr('first_name_label'),
                Icons.person_rounded,
                controller.firstNameController,
              ),
              const SizedBox(height: 15),
              _buildModernField(
                tr('last_name_label'),
                Icons.person_outline_rounded,
                controller.lastNameController,
              ),
              const SizedBox(height: 15),

              // حقل رقم الهاتف الجديد
              _buildModernField(
                "رقم الهاتف",
                Icons.phone_android_rounded,
                controller.phoneController,
              ),
              const SizedBox(height: 15),

              _buildModernDropdown(
                tr('faculty_label'),
                Icons.account_balance_rounded,
                controller.faculties.map((f) => f.name).toList(),
                controller.selectedFacultyName,
                (val) => controller.onFacultyChanged(val),
              ),
              const SizedBox(height: 15),
              _buildModernDropdown(
                tr('Department'),
                Icons.lan_rounded,
                controller.departments,
                controller.selectedDepartmentName,
                (val) {
                  controller.selectedDepartmentName = val;
                  controller.update();
                },
              ),
              const SizedBox(height: 15),
              _buildModernDropdown(
                tr('col_rank'),
                Icons.workspace_premium_rounded,
                _ranks,
                controller.selectedRank,
                (val) {
                  controller.selectedRank = val;
                  controller.update();
                },
              ),
              const SizedBox(height: 15),
              _buildModernField(
                tr('email_label'),
                Icons.alternate_email_rounded,
                controller.emailController,
              ),
              const SizedBox(height: 15),
              _buildModernField(
                controller.isEditing
                    ? "كلمة المرور الجديدة (اختياري)"
                    : tr('password_label'),
                Icons.lock_rounded,
                controller.passwordController,
                isPassword: true,
                isRequired: !controller.isEditing,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            controller.saveInstructor();
                          }
                        },
                  icon: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          controller.isEditing
                              ? Icons.update_rounded
                              : Icons.save_rounded,
                          color: Colors.white,
                        ),
                  label: Text(
                    controller.isLoading
                        ? "جاري الحفظ..."
                        : (controller.isEditing
                              ? "تحديث البيانات"
                              : tr('save_add_instructor_btn')),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isEditing
                        ? Colors.orange
                        : const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              if (controller.isEditing)
                Center(
                  child: TextButton.icon(
                    onPressed: () => controller.clearFields(),
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                    label: const Text(
                      "إلغاء",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernField(
    String label,
    IconData icon,
    TextEditingController textController, {
    bool isPassword = false,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: textController,
      obscureText: isPassword,
      validator: (value) => (isRequired && (value == null || value.isEmpty))
          ? tr('required_field')
          : null,
      decoration: InputDecoration(
        labelText: label,
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

  Widget _buildModernDropdown(
    String label,
    IconData icon,
    List<String> items,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    String? validValue = items.contains(currentValue) ? currentValue : null;
    return DropdownButtonFormField<String>(
      value: validValue,
      items: items
          .map((f) => DropdownMenuItem(value: f, child: Text(f)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? tr('required_field') : null,
      decoration: InputDecoration(
        labelText: label,
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
}
