import 'package:get/get.dart';

enum ActivityType { lecture, exam }

class LogActivityModel {
  final String id;
  final String title;
  final String typeLabel;
  final String time;
  final String room;
  final ActivityType type;
  RxBool isChecked;

  LogActivityModel({
    required this.id,
    required this.title,
    required this.typeLabel,
    required this.time,
    required this.room,
    required this.type,
    bool initialCheck = false,
  }) : isChecked = initialCheck.obs;

  factory LogActivityModel.fromJson(Map<String, dynamic> json) {
    // وظيفة هذه الدالة تحويل أي قيمة (int, double, null) إلى String بأمان
    String safeString(dynamic value, {String defaultValue = ""}) {
      if (value == null ||
          value.toString() == "null" ||
          value.toString() == "None") {
        return defaultValue;
      }
      return value.toString();
    }

    return LogActivityModel(
      id: safeString(json['id']),
      title: safeString(json['title']),
      typeLabel: safeString(json['type']),
      // داخل LogActivityModel.fromJson
      time: safeString(json['time'], defaultValue: "--:--").length >= 5
          ? safeString(json['time']).substring(0, 5)
          : safeString(
              json['time'],
              defaultValue: "--:--",
            ), // قص الوقت لـ HH:mm
      room: safeString(json['room'], defaultValue: "N/A"),
      type: json['category'].toString() == 'exam'
          ? ActivityType.exam
          : ActivityType.lecture,
      // الباك إند قد يرسل 1/0 أو true/false
      initialCheck: json['isChecked'] == true || json['isChecked'] == 1,
    );
  }
}
