import 'package:get/get.dart';

class EmployeeLectureModel {
  final int lectureId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String lectureType;
  final String durationTime; // دمج التوقيت للعرض السريع

  // تفاصيل القاعة
  final int? roomId;
  final String roomName;

  // تفاصيل المادة
  final String courseId;
  final String courseName;

  // تفاصيل المدرس (هون الاستلام الكامل اللي طلبته)
  final int instructorId;
  final String instructorName;

  final int courseAllocationId; // الحقل الذهبي للتعويض
  final RxBool isChecked;

  EmployeeLectureModel({
    required this.lectureId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.lectureType,
    required this.durationTime,
    this.roomId,
    required this.roomName,
    required this.courseId,
    required this.courseName,
    required this.instructorId,
    required this.instructorName,
    required this.courseAllocationId,
    bool checked = false,
  }) : isChecked = checked.obs;

  factory EmployeeLectureModel.fromJson(Map<String, dynamic> json) {
    String start = json['start_time'] ?? '--:--';
    String end = json['end_time'] ?? '--:--';

    return EmployeeLectureModel(
      lectureId: json['lecture_id'] ?? 0,
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: start,
      endTime: end,
      lectureType: json['lecture_type'] ?? '',
      durationTime: "$start - $end",

      // تفكيك دكشنري القاعة
      roomId: json['room']?['id'],
      roomName: json['room']?['name']?.toString() ?? 'غير محدد',

      // تفكيك دكشنري المادة
      courseId: json['course']?['id']?.toString() ?? '',
      courseName: json['course']?['name']?.toString() ?? 'غير محدد',

      // تفكيك دكشنري المدرس واستلامه بالكامل 🔥
      instructorId: json['instructor']?['id'] ?? 0,
      instructorName: json['instructor']?['name']?.toString() ?? 'غير محدد',

      courseAllocationId: json['course_allocation_id'] ?? 0,
      checked: json['is_done'] ?? false,
    );
  }
}
