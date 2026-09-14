import 'package:edutrack/Features/Employee/ExamAssignment/Data_layer/Service/ExamDutyService.dart';
import 'package:edutrack/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExamAssignmentController extends GetxController {
  var selectedCourse = Rxn<Map<String, String>>();
  var selectedRoomId = Rxn<int>(); // نحتاج ID القاعة هنا
  var selectedRoomName = Rxn<String>();
  var selectedDate = Rxn<DateTime>();
  var selectedTime = Rxn<String>(); // سيتم تحديثه تلقائياً هنا
  var selectedStaff = <Map<String, String>>[].obs;
  var facultyInstructors = <dynamic>[].obs; // قائمة المدرسين من الكلية
  var isInstructorsLoading = false.obs;
  var isLoading = false.obs;
  var startTime = Rxn<TimeOfDay>();
  var endTime = Rxn<TimeOfDay>();

  @override
  void onInit() {
    super.onInit();
    fetchFacultyInstructors(box.read('user_id'));
    ever(startTime, (_) => _updateSelectedTime());
    ever(endTime, (_) => _updateSelectedTime());
  }

  // دالة لدمج وقت البداية والنهاية وإسنادها لـ selectedTime
  void _updateSelectedTime() {
    if (startTime.value != null && endTime.value != null) {
      final startStr = _formatTimeForUi(startTime.value!);
      final endStr = _formatTimeForUi(endTime.value!);
      selectedTime.value = "$startStr - $endStr";
    } else if (startTime.value != null) {
      selectedTime.value = "يبدأ ${_formatTimeForUi(startTime.value!)}";
    } else {
      selectedTime.value = null; // عشان تظهر "---" بالواجهة
    }
  }

  // دالة مساعدة لتنسيق الوقت للعرض بالواجهة (مثال: 10:30 AM)
  String _formatTimeForUi(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  Future<void> chooseTime(BuildContext context, bool isStart) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (isStart) {
        startTime.value = picked;
      } else {
        endTime.value = picked;
      }
    }
  }

  // التنسيق الخاص بالإرسال للباك إند (HH:mm:ss)
  String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return "";
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm:ss').format(dt);
  }

  void fetchFacultyInstructors(int employeeId) async {
    isInstructorsLoading.value = true;
    try {
      final res = await ExamDutyService.getInstructorsByFaculty(employeeId);
      if (res.statusCode == 200) {
        facultyInstructors.assignAll(res.data['data'] ?? []);
      }
    } finally {
      isInstructorsLoading.value = false;
    }
  }

  void toggleStaff(Map<String, String> staff) {
    if (selectedStaff.any((element) => element['id'] == staff['id'])) {
      selectedStaff.removeWhere((element) => element['id'] == staff['id']);
    } else {
      selectedStaff.add(staff);
    }
  }

  Future<void> submitAssignment() async {
    if (selectedCourse.value == null ||
        selectedRoomId.value == null ||
        selectedDate.value == null ||
        startTime.value == null ||
        endTime.value == null ||
        selectedStaff.isEmpty) {
      Get.snackbar(
        "تنبيه",
        "يرجى إكمال كافة البيانات",
        backgroundColor: Colors.orange,
      );
      return;
    }

    isLoading.value = true;

    List<int> instructorIds = selectedStaff
        .map((s) => int.parse(s['id']!))
        .toList();

    var result = await ExamDutyService.submitExamDuty(
      courseCode: selectedCourse.value!['id']!,
      examDate: DateFormat('yyyy-MM-dd').format(selectedDate.value!),
      startTime: formatTimeOfDay(startTime.value),
      endTime: formatTimeOfDay(endTime.value),
      roomId: selectedRoomId.value!,
      instructorIds: instructorIds,
    );

    isLoading.value = false;

    if (result['status'] == 'success') {
      Get.snackbar(
        "نجاح",
        "تم حفظ التكليفات بنجاح",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _resetAll();
    } else {
      Get.snackbar(
        "خطأ",
        result['message'] ?? "حدث خطأ ما",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _resetAll() {
    selectedCourse.value = null;
    selectedRoomId.value = null;
    selectedRoomName.value = null;
    selectedDate.value = null;
    selectedStaff.clear();
    // إضافات التصفير لضمان تنظيف الواجهة تماماً بعد الحفظ
    startTime.value = null;
    endTime.value = null;
    selectedTime.value = null;
  }
}
