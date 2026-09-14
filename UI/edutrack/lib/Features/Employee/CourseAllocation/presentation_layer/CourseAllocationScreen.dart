import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edutrack/Features/Employee/CourseAllocation/presentation_layer/Widget/CustomSearchPicker.dart';
import 'package:edutrack/Features/Admin/Features/RoomManagment/busines_logic_layer/RoomController.dart';
import 'package:edutrack/Features/Employee/CourseAllocation/busines_logic_layer/CourseAllocationController.dart';
import 'package:edutrack/Features/Admin/Features/CoursesManagement/busines_logic_layer/CourseController.dart';

class CourseAllocationScreen extends StatefulWidget {
  const CourseAllocationScreen({super.key});

  @override
  State<CourseAllocationScreen> createState() => _CourseAllocationScreenState();
}

class _CourseAllocationScreenState extends State<CourseAllocationScreen> {
  final CourseController courseController = Get.put(CourseController());

  final Roomcontroller roomController = Get.put(Roomcontroller());
  final AllocationController allocationController = Get.put(
    AllocationController(),
  );

  final Color primaryDark = const Color(0xFF003366);
  final Color bgGrey = const Color(0xFFF8F9FA);

  Map<String, String>? _selectedCourse;
  List<Map<String, dynamic>> _theorySections = [];
  List<Map<String, dynamic>> _practicalSections = [];

  final List<String> _days = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];
  final List<String> _times = [
    '08:30 - 10:00', // أضف الصفر قبل الـ 8
    '10:00 - 11:30',
    '11:30 - 01:00', // يفضل استخدام نظام 24 ساعة لضمان الدقة (13 بدل 01)
    '01:00 - 02:30',
    '02:30 - 04:00',
  ];

  List<String> _formatTime(String range) {
    var parts = range.split(' - ');
    return ["${parts[0].trim()}:00", "${parts[1].trim()}:00"];
  }

  void _handleFinalSubmit() {
    if (_selectedCourse == null) {
      Get.snackbar(
        "تنبيه",
        "يرجى اختيار مقرر أولاً",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    List<Map<String, dynamic>> payloadList = [];
    void collect(List<Map<String, dynamic>> sections, String type) {
      for (var s in sections) {
        if (s['instructor_id'] != null &&
            s['day'] != null &&
            s['time'] != null &&
            s['room_id'] != null) {
          var times = _formatTime(s['time']);

          payloadList.add({
            "instructor_id": s['instructor_id'], // الـ User ID للمدرس
            "course_id":
                _selectedCourse!['id'], // الكود النصي للمادة (مثل CSE412)
            "room_id": s['room_id'], // ID القاعة
            "day_of_week": s['day'], // "الأحد"، "الاثنين"...
            "start_time": times[0], // "08:00:00"
            "end_time": times[1], // "10:00:00"
            "lecture_type": type, // "نظري" أو "عملي"
          });
        }
      }
    }

    collect(_theorySections, "نظري");
    collect(_practicalSections, "عملي");

    if (payloadList.isNotEmpty) {
      allocationController.submitAllAllocations(payloadList);
    } else {
      Get.snackbar(
        "تنبيه",
        "يرجى إكمال بيانات فئة واحدة على الأقل بالكامل",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: Colors.grey[300]!)),
              ),
              child: _buildInputsList(),
            ),
          ),
          Expanded(flex: 6, child: _buildPreviewArea()),
        ],
      ),
    );
  }
  // ... داخل كلاس _CourseAllocationScreenState

  Widget _buildInputsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("1. اختيار المقرر", Icons.search_rounded),

          // عرض المقررات القادمة من الباك إند
          Obx(() {
            if (allocationController.isDataLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (allocationController.facultyCourses.isEmpty) {
              return const Text(
                "لا توجد مقررات متاحة لكليتك حالياً",
                style: TextStyle(color: Colors.red),
              );
            }
            return CustomSearchPicker(
              title: "البحث في مقررات الكلية",
              hint: "اضغط للبحث عن مقرر...",
              icon: Icons.library_books_rounded,
              selectedItem: _selectedCourse?['name'],
              items: RxList<String>(
                allocationController.facultyCourses
                    .map((e) => e['course_name'].toString())
                    .toList(),
              ),
              onSelected: (val) {
                setState(() {
                  var selected = allocationController.facultyCourses.firstWhere(
                    (e) => e['course_name'] == val,
                  );
                  _selectedCourse = {
                    'name': selected['course_name'],
                    'id': selected['course_id'].toString(), // الـ ID من الباك
                  };
                  // تنظيف القوائم عند تغيير المقرر
                  _theorySections.clear();
                  _practicalSections.clear();
                });
              },
            );
          }),

          if (_selectedCourse != null) ...[
            const SizedBox(height: 25),
            _buildHeader(
              "2. أعداد الفئات",
              Icons.format_list_numbered_rtl_rounded,
            ),

            Row(
              children: [
                Expanded(
                  child: _buildNumberInputField(
                    "النظرية",
                    Colors.green,
                    (v) => _updateSections(v, true),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildNumberInputField(
                    "العملية",
                    Colors.orange,
                    (v) => _updateSections(v, false),
                  ),
                ),
              ],
            ),

            // عرض الفئات النظرية
            if (_theorySections.isNotEmpty) ...[
              _buildTypeLabel(
                "الفئات النظرية",
                Colors.green,
                Icons.menu_book_rounded,
              ),
              ..._theorySections.asMap().entries.map(
                (e) => _buildSectionCard(
                  e.key,
                  "نظري",
                  Colors.green,
                  _theorySections,
                ),
              ),
            ],

            // عرض الفئات العملية
            if (_practicalSections.isNotEmpty) ...[
              _buildTypeLabel(
                "الفئات العملية",
                Colors.orange,
                Icons.science_rounded,
              ),
              ..._practicalSections.asMap().entries.map(
                (e) => _buildSectionCard(
                  e.key,
                  "عملي",
                  Colors.orange,
                  _practicalSections,
                ),
              ),
            ],

            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    int index,
    String type,
    Color color,
    List<Map<String, dynamic>> source,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // اختيار المدرس (ديناميكي)
            Obx(() {
              return CustomSearchPicker(
                title: "مدرسي الكلية",
                hint: "اختر المدرس لهذه الفئة...",
                icon: Icons.person_search_rounded,
                selectedItem: source[index]['instructor'],
                items: RxList<String>(
                  allocationController.facultyInstructors
                      .map((i) => i['full_name'].toString())
                      .toList(),
                ),
                onSelected: (val) {
                  setState(() {
                    source[index]['instructor'] = val;
                    var selectedInst = allocationController.facultyInstructors
                        .firstWhere((i) => i['full_name'] == val);

                    // التعديل هنا: غير 'instructor_id' إلى 'user_id'
                    source[index]['instructor_id'] = selectedInst['user_id'];
                  });
                },
              );
            }),

            const SizedBox(height: 10),

            // اختيار اليوم والوقت
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    "اليوم",
                    _days,
                    source[index]['day'],
                    (v) => setState(() => source[index]['day'] = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    "الوقت",
                    _times,
                    source[index]['time'],
                    (v) => setState(() => source[index]['time'] = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // اختيار القاعة (هنا نستخدم الـ roomController تبعك)
            Obx(() {
              return CustomSearchPicker(
                title: "القاعات المتاحة",
                hint: "اختر القاعة...",
                icon: Icons.meeting_room_rounded,
                selectedItem: source[index]['room'],
                items: RxList<String>(
                  roomController.rooms
                      .map((r) => r['name'].toString())
                      .toList(),
                ),
                onSelected: (val) {
                  setState(() {
                    final selectedRoom = roomController.rooms.firstWhere(
                      (r) => r['name'] == val,
                    );
                    source[index]['room'] = val;
                    source[index]['room_id'] = selectedRoom['id'];
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      children: [
        Icon(icon, color: primaryDark),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryDark,
          ),
        ),
      ],
    ),
  );

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    ),
    items: items
        .map(
          (i) => DropdownMenuItem(
            value: i,
            child: Text(i, style: const TextStyle(fontSize: 12)),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );

  void _updateSections(String val, bool isTheory) {
    int count = int.tryParse(val) ?? 0;
    setState(() {
      List<Map<String, dynamic>> target = isTheory
          ? _theorySections
          : _practicalSections;
      if (target.length < count) {
        target.addAll(
          List.generate(
            count - target.length,
            (i) => {
              'id':
                  DateTime.now().millisecondsSinceEpoch +
                  i +
                  (isTheory ? 0 : 1000),
              'instructor': null,
              'instructor_id': null,
              'day': null,
              'time': null,
              'room': null,
              'room_id': null,
            },
          ),
        );
      } else {
        if (isTheory)
          _theorySections = _theorySections.sublist(0, count);
        else
          _practicalSections = _practicalSections.sublist(0, count);
      }
    });
  }

  Widget _buildTypeLabel(String title, Color color, IconData icon) => Container(
    margin: const EdgeInsets.only(top: 25, bottom: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _buildNumberInputField(
    String label,
    Color color,
    Function(String) onChanged,
  ) => TextFormField(
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(Icons.add_task_rounded, color: color),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    keyboardType: TextInputType.number,
    onChanged: onChanged,
  );

  Widget _buildSubmitButton() => Obx(
    () => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: allocationController.isLoading.value
            ? null
            : _handleFinalSubmit,
        icon: allocationController.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          allocationController.isLoading.value
              ? "جاري الحفظ..."
              : "حفظ واعتماد التوزيع",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    ),
  );

  Widget _buildPreviewArea() => Container(
    padding: const EdgeInsets.all(30),
    child: _selectedCourse == null
        ? Center(
            child: Text(
              "يرجى اختيار مقرر لبدء المعاينة",
              style: TextStyle(color: Colors.grey[400], fontSize: 18),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "معاينة توزيع: ${_selectedCourse!['name']}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              const Divider(height: 40),
              if (_theorySections.any((s) => s['instructor'] != null)) ...[
                Text(
                  "الفئات النظرية المخصصة:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                ..._theorySections
                    .where((s) => s['instructor'] != null)
                    .map(
                      (s) => Text(
                        "- ${s['instructor']} (${s['day']} - ${s['time']}) في ${s['room'] ?? 'لم تحدد قاعة'}",
                      ),
                    ),
              ],
              const SizedBox(height: 20),
              if (_practicalSections.any((s) => s['instructor'] != null)) ...[
                Text(
                  "الفئات العملية المخصصة:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                ..._practicalSections
                    .where((s) => s['instructor'] != null)
                    .map(
                      (s) => Text(
                        "- ${s['instructor']} (${s['day']} - ${s['time']}) في ${s['room'] ?? 'لم تحدد قاعة'}",
                      ),
                    ),
              ],
            ],
          ),
  );
}
