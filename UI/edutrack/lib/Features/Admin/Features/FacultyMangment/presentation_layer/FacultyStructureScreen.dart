import 'package:edutrack/Features/Admin/Features/FacultyMangment/Data_layer/Model/AcademyFacultyModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edutrack/Features/Admin/Features/FacultyMangment/busines_logic_layer/FacultyController.dart';
import 'package:edutrack/Style/Colors.dart';
// import 'AcademyFacultyModel.dart';

// ignore: must_be_immutable
class FacultyStructureScreen extends StatelessWidget {
  FacultyStructureScreen({super.key});

  final FacultyController controller = Get.put(FacultyController());
  final MyColors colors = MyColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverPadding(
            padding: const EdgeInsets.all(30),
            sliver: Obx(
              () => controller.isLoading.value
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _buildFacultyGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 40, 30, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الهيكل التنظيمي",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colors.Oxford_Blue,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.Ocean_Blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "إدارة الكليات والأقسام العلمية",
                    style: TextStyle(
                      color: colors.Ocean_Blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            _buildHeaderButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => controller.fetchFaculties(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text("تحديث"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: colors.Oxford_Blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton.icon(
          onPressed: () => _showAddFacultyModal(),
          icon: const Icon(Icons.add_box_rounded),
          label: const Text("إضافة كلية"),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.Ocean_Blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            shadowColor: colors.Ocean_Blue.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildFacultyGrid() {
    if (controller.faculties.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("لا توجد كليات مضافة حالياً")),
      );
    }
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        childAspectRatio: 1.6,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final faculty = controller.faculties[index];
        return _buildEnhancedFacultyCard(faculty);
      }, childCount: controller.faculties.length),
    );
  }

  Widget _buildEnhancedFacultyCard(AcademyFacultyModel faculty) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.school_rounded,
                size: 150,
                color: colors.Ocean_Blue.withOpacity(0.03),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.Ocean_Blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: colors.Ocean_Blue,
                        ),
                      ),
                      _buildAddDeptBtn(faculty),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    faculty.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "الأقسام الأكاديمية:",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Expanded(child: _buildDeptsList(faculty.departments)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptsList(List<AcademyDepartmentModel> depts) {
    if (depts.isEmpty) {
      return const Text(
        "لا يوجد أقسام مضافة",
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 13,
          color: Colors.grey,
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: depts.length,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(left: 8, bottom: 5),
          child: ActionChip(
            label: Text(depts[i].name, style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.grey.shade50,
            onPressed: () {},
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddDeptBtn(AcademyFacultyModel faculty) {
    return TextButton.icon(
      onPressed: () => _showAddDeptModal(faculty.id, faculty.name),
      icon: const Icon(Icons.add_circle, size: 20),
      label: const Text("إضافة قسم"),
      style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
    );
  }

  void _showAddFacultyModal() {
    final controllerText = TextEditingController();
    _showCustomModal(
      "إضافة كلية جديدة",
      "يرجى إدخال اسم الكلية الأكاديمية المراد إنشاؤها",
      controllerText,
      () {
        if (controllerText.text.isNotEmpty) {
          controller.createFaculty(controllerText.text);
        }
      },
    );
  }

  void _showAddDeptModal(int fId, String fName) {
    final controllerText = TextEditingController();
    _showCustomModal(
      "إضافة قسم لـ $fName",
      "سيتم ربط هذا القسم تلقائياً بكلية $fName",
      controllerText,
      () {
        if (controllerText.text.isNotEmpty) {
          controller.createDepartment(fId, controllerText.text);
        }
      },
    );
  }

  void _showCustomModal(
    String title,
    String subtitle,
    TextEditingController tec,
    Function onSave,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: tec,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
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
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => onSave(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.Ocean_Blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("تأكيد وحفظ"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
