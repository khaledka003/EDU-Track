import 'package:get/get.dart';

class LectureModel {
  final int id; // معرف المحاضرة (lecture_id)
  final String subject;
  final String type;
  final String time;
  final String room;
  final RxBool isChecked;

  LectureModel({
    required this.id,
    required this.subject,
    required this.type,
    required this.time,
    required this.room,
    bool checked = false,
  }) : isChecked = checked.obs;

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['lecture_id'] ?? 0,
      subject: json['course']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      time: "${json['start'] ?? ''} - ${json['end'] ?? ''}",
      room: json['room']?.toString() ?? '',
      checked: json['is_done'] ?? false,
    );
  }
}
