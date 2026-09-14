import 'package:get/get.dart';

class ExamModel {
  final int id; // أضفنا الـ ID للضرورة
  final String course;
  final String date;
  final String room;
  final String time;
  RxBool isChecked;

  ExamModel({
    required this.id,
    required this.course,
    required this.date,
    required this.room,
    required this.time,
    bool checked = false,
  }) : isChecked = checked.obs;

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] ?? 0,
      course: json['course'] ?? 'مادة غير محددة',
      date: json['date'] ?? '',
      room: json['room'] ?? '',
      time: json['time'] ?? '--:--', // يستقبل الوقت من السيرفر
      checked:
          json['is_done'] ??
          false, // حالياً لا يوجد حقل تأكيد في الباك إند، نضعها false افتراضياً
    );
  }
}
