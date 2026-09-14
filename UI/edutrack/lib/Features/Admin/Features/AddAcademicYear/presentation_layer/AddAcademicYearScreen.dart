import 'package:edutrack/Features/Admin/Features/AddAcademicYear/Data_layer/Model/AcademicSemesterModel.dart';
import 'package:edutrack/Features/Admin/Features/AddAcademicYear/busines_logic_layer/AcademicController.dart';
import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddAcademicYearScreen extends StatelessWidget {
  final controller = Get.put(AcademicController());
  final yearNameController = TextEditingController();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  AddAcademicYearScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: MyColors().oxfordBlue,
        elevation: 0,
        title: const Text(
          "إدارة السنوات الأكاديمية",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showYearDialog(),
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            tooltip: "إضافة عام جديد",
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allYears.isEmpty) return _buildEmptyState();

        return Column(
          children: [
            // شريط اختيار السنوات (عرض السنة من yearDisplay)
            _buildYearHorizontalSelector(),

            // قائمة الفصول المفلترة بناءً على السنة المختارة
            Expanded(child: _buildFilteredSemestersList()),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.allYears.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () {
            if (controller.selectedYearId.value != null) {
              _showSemesterSheet(controller.selectedYearId.value!);
            }
          },
          backgroundColor: MyColors().oceanBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "فصل جديد",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  // --- شريط اختيار السنة الأفقي ---
  Widget _buildYearHorizontalSelector() {
    return Container(
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColors().oxfordBlue,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          itemCount: controller.allYears.length,
          itemBuilder: (context, index) {
            final yearModel = controller.allYears[index];

            return Obx(() {
              bool isSelected =
                  controller.selectedYearId.value == yearModel.yearId;
              return GestureDetector(
                onTap: () => controller.selectYear(yearModel.yearId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      yearModel.yearDisplay, // استخدام الحقل الصحيح من الموديل
                      style: TextStyle(
                        color: isSelected
                            ? MyColors().oxfordBlue
                            : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  // --- عرض القائمة المفلترة ---
  Widget _buildFilteredSemestersList() {
    return Obx(() {
      // الفلترة بتصير بالكنترولر عن طريق selectedYearId
      final filteredList = controller.filteredSemesters;

      if (filteredList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 10),
              const Text(
                "لا توجد فصول دراسية لهذه السنة",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filteredList.length,
        itemBuilder: (context, index) =>
            _buildSemesterCard(filteredList[index]),
      );
    });
  }

  // --- بطاقة الفصل الدراسي ---
  Widget _buildSemesterCard(AcademicSemesterModel sem) {
    // منطق التحقق إذا كان الفصل الدراسي هو الحالي
    final now = DateTime.now();
    bool isNow = now.isAfter(sem.startDate) && now.isBefore(sem.endDate);
    bool archived = sem.isArchived;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: archived ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isNow && !archived
            ? Border.all(color: Colors.green.shade200, width: 1.5)
            : Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: archived
                  ? Colors.grey[200]
                  : (isNow
                        ? Colors.green.withOpacity(0.08)
                        : Colors.blue.withOpacity(0.05)),
              child: Row(
                children: [
                  Icon(
                    archived
                        ? Icons.archive
                        : (isNow ? Icons.lens : Icons.calendar_today),
                    color: archived
                        ? Colors.grey
                        : (isNow ? Colors.green : MyColors().oceanBlue),
                    size: 14,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sem.semesterName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: archived
                            ? Colors.grey[600]
                            : MyColors().oxfordBlue,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _actionBtn(
                        Icons.edit_outlined,
                        Colors.blue,
                        () => _showSemesterSheet(
                          controller.selectedYearId.value!,
                          sem: sem,
                        ),
                      ),
                      _actionBtn(
                        archived
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                        archived ? Colors.orange : Colors.redAccent,
                        () {
                          if (sem.id != null) controller.toggleArchive(sem.id!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dateInfo("البداية", formatter.format(sem.startDate)),
                  _dateInfo("النهاية", formatter.format(sem.endDate)),
                  _dateInfo("العطلات", "${sem.holidays.length} أيام"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(icon, size: 19, color: color),
    );
  }

  Widget _dateInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showSemesterSheet(int yearId, {AcademicSemesterModel? sem}) {
    controller.resetInputs(sem);
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                sem == null ? "إضافة فصل جديد" : "تعديل بيانات الفصل",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MyColors().oxfordBlue,
                ),
              ),
              const SizedBox(height: 25),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedSemType.value,
                  decoration: _inputStyle("نوع الفصل الدراسي"),
                  items:
                      [
                            "الفصل الدراسي الأول",
                            "الفصل الدراسي الثاني",
                            "الفصل الدراسي الصيفي",
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => controller.selectedSemType.value = v!,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _dateTile("تاريخ البدء", controller.startDate),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dateTile("تاريخ الانتهاء", controller.endDate),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "فترة التنسيق",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _dateTile("بدء التنسيق", controller.coordStartDate),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dateTile("انتهاء التنسيق", controller.coordEndDate),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "العطلات الرسمية",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // أضفنا Row داخلي لترتيب الزرين بجانب بعضهما
                  Row(
                    children: [
                      // زر إضافة يوم واحد فقط
                      _holidayBtn("إضافة يوم", Icons.event_available, () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: Get.context!,
                          initialDate:
                              controller.startDate.value ?? DateTime.now(),
                          firstDate:
                              controller.startDate.value ?? DateTime(2020),
                          lastDate: controller.endDate.value ?? DateTime(2035),
                        );

                        if (pickedDate != null) {
                          // التحقق لمنع التكرار وترتيب القائمة
                          if (!controller.selectedHolidays.contains(
                            pickedDate,
                          )) {
                            controller.selectedHolidays.add(pickedDate);
                            controller.selectedHolidays.sort();
                          } else {
                            Get.snackbar("تنبيه", "هذا اليوم مضاف مسبقاً");
                          }
                        }
                      }),

                      const SizedBox(width: 8), // مسافة بسيطة بين الزرين
                      // زر إضافة فترة (الكود الخاص بك مع إضافة الترتيب)
                      _holidayBtn(
                        "إضافة فترة",
                        Icons.date_range_rounded,
                        () async {
                          if (controller.startDate.value == null ||
                              controller.endDate.value == null)
                            return;

                          DateTimeRange? range = await showDateRangePicker(
                            context: Get.context!,
                            firstDate: controller.startDate.value!,
                            lastDate: controller.endDate.value!,
                          );

                          if (range != null) {
                            DateTime temp = range.start;
                            while (temp.isBefore(range.end) ||
                                temp.isAtSameMomentAs(range.end)) {
                              if (!controller.selectedHolidays.contains(temp)) {
                                controller.selectedHolidays.add(temp);
                              }
                              temp = temp.add(const Duration(days: 1));
                            }
                            controller.selectedHolidays.sort();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: controller.selectedHolidays
                      .map(
                        (h) => Chip(
                          label: Text(
                            formatter.format(h),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: MyColors().oceanBlue,
                          onDeleted: () =>
                              controller.selectedHolidays.remove(h),
                          deleteIconColor: Colors.white,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors().oxfordBlue,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => controller.submitSemester(
                  yearId: yearId,
                  semesterId: sem?.id,
                ),
                child: const Text(
                  "حفظ البيانات",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _holidayBtn(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: MyColors().oceanBlue),
      label: Text(
        label,
        style: TextStyle(color: MyColors().oxfordBlue, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _dateTile(String label, Rxn<DateTime> obs) {
    return Obx(
      () => InkWell(
        onTap: () async {
          DateTime? d = await showDatePicker(
            context: Get.context!,
            initialDate: obs.value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
          );
          if (d != null) obs.value = d;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
              Text(
                obs.value == null
                    ? "حدد التاريخ"
                    : formatter.format(obs.value!),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
  );

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            "لا توجد سنوات أكاديمية حالياً",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showYearDialog(),
            child: const Text("إضافة أول عام دراسي"),
          ),
        ],
      ),
    );
  }

  void _showYearDialog() {
    yearNameController.clear();
    Get.defaultDialog(
      title: "عام دراسي جديد",
      content: TextField(
        controller: yearNameController,
        decoration: _inputStyle("مثال: 2025/2026"),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (yearNameController.text.isNotEmpty) {
            controller.submitYear(yearNameController.text);
            Get.back();
          }
        },
        child: const Text("إنشاء"),
      ),
    );
  }
}
