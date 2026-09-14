import 'package:edutrack/Features/Admin/Features/EmployeesManagement/busines_logic_layer/EmployeeController.dart';
import 'package:edutrack/Features/Admin/Features/FacultyMangment/busines_logic_layer/FacultyController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edutrack/Style/Colors.dart';

class EmployeeManagementScreen extends StatelessWidget {
  EmployeeManagementScreen({super.key});

  final EmployeeController controller = Get.put(EmployeeController());
  final FacultyController facultyController = Get.put(FacultyController());
  final MyColors colors = MyColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            const SizedBox(height: 30),
            _buildStatsRow(),
            const SizedBox(height: 30),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: colors.Ocean_Blue),
                  );
                }
                if (controller.employees.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildEmployeeGrid();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "إدارة شؤون الموظفين",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.Oxford_Blue,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "إضافة وتعديل بيانات الموظفين الإداريين في الكليات",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _openEmployeeModal(),
          icon: const Icon(Icons.add_circle_outline, size: 22),
          label: const Text(
            "إضافة موظف جديد",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.Ocean_Blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Obx(
      () => Row(
        children: [
          _statItem(
            "عدد الموظفين الحاليين",
            controller.employees.length.toString(),
            Icons.badge_outlined,
            Colors.blue,
          ),
          const SizedBox(width: 20),
          _statItem(
            "الكليات المسجلة",
            controller.faculties.length
                .toString(), // استخدمنا لستة الكليات من كنترولر الموظفين للتأكد من المزامنة
            Icons.account_balance_outlined,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeGrid() {
    return GridView.builder(
      itemCount: controller.employees.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final emp = controller.employees[index];
        return _buildCard(emp);
      },
    );
  }

  Widget _buildCard(Map emp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: colors.Ocean_Blue.withOpacity(0.1),
                  child: Icon(Icons.person, color: colors.Ocean_Blue),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${emp['first_name']} ${emp['last_name']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        emp['faculty_name'] ?? "إدارة عامة",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionMenu(emp),
              ],
            ),
            const Divider(height: 30),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  emp['phone_number'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 18,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  emp['email'] ?? '',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(Map emp) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text("تعديل"),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () =>
              Future.delayed(Duration.zero, () => _openEmployeeModal(emp: emp)),
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text("حذف"),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () => _confirmDelete(emp),
        ),
      ],
    );
  }

  void _openEmployeeModal({Map? emp}) {
    controller.fetchFaculties();
    final fName = TextEditingController(text: emp?['first_name'] ?? '');
    final lName = TextEditingController(text: emp?['last_name'] ?? '');
    final phone = TextEditingController(text: emp?['phone_number'] ?? '');
    final email = TextEditingController(text: emp?['email'] ?? '');
    final password = TextEditingController();

    // تحديث القيمة المختارة في الكنترولر عند الفتح
    if (emp != null) {
      controller.selectedFacultyId.value = emp['faculty_id'];
    } else {
      controller.selectedFacultyId.value = null;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp == null ? "إضافة حساب موظف" : "تحديث بيانات الموظف",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        "الاسم الأول",
                        Icons.person_outline,
                        fName,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildInput("الكنية", Icons.person_outline, lName),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildInput("رقم الهاتف", Icons.phone_android_outlined, phone),
                const SizedBox(height: 15),
                if (emp == null) ...[
                  _buildInput("البريد الإلكتروني", Icons.email_outlined, email),
                  const SizedBox(height: 15),
                  _buildInput(
                    "كلمة المرور",
                    Icons.lock_outline,
                    password,
                    isPass: false,
                  ),
                  const SizedBox(height: 15),
                ],
                const Text(
                  "الكلية التابع لها",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        // الحل الجذري لمشكلة الـ Assertion: التأكد من وجود القيمة في اللستة
                        value:
                            controller.faculties.any(
                              (f) =>
                                  f['id'] == controller.selectedFacultyId.value,
                            )
                            ? controller.selectedFacultyId.value
                            : null,
                        hint: const Text("اختر الكلية"),
                        items: controller.faculties.map((f) {
                          return DropdownMenuItem<int>(
                            value: f['id'],
                            child: Text(f['name']),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            controller.selectedFacultyId.value = val,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("إلغاء"),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.Ocean_Blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final data = {
                          "first_name": fName.text,
                          "last_name": lName.text,
                          "phone_number": phone.text,
                          "faculty_id": controller.selectedFacultyId.value,
                        };
                        if (emp == null) {
                          data["email"] = email.text;
                          data["password"] = password.text;
                          controller.registerEmployee(data);
                        } else {
                          controller.editEmployee(emp['user_id'], data);
                        }
                      },
                      child: Text(
                        emp == null ? "إنشاء الحساب" : "حفظ التعديلات",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPass = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.all(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _confirmDelete(Map emp) {
    Get.defaultDialog(
      title: "حذف الموظف",
      middleText:
          "هل أنت متأكد من حذف حساب ${emp['first_name']}؟ لا يمكن التراجع عن هذا الإجراء.",
      textConfirm: "تأكيد الحذف",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.removeEmployee(emp['user_id']);
        Get.back();
      },
      textCancel: "إلغاء",
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text(
            "لا يوجد موظفين مسجلين حالياً",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
