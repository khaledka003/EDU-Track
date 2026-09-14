import 'package:edutrack/Features/Insructor/Features/DailyLectures/Data_layer/Model/LectureModel.dart';
import 'package:edutrack/Features/Insructor/Features/ExamAssignment/Data_layer/Model/ExamModel.dart';

class TeachingLoadReportModel {
  // بيانات المدرس الأساسية
  final String instructorName;
  final String faculty;
  final String department;
  final String rank;
  final String reportDate;
  final double totalCompletedHours;
  bool isfinished;

  // القوائم باستخدام موديلاتك الجاهزة + إضافة قائمة المشاريع
  List<LectureModel> confirmedLectures;
  List<ExamModel> confirmedExams;
  List<LectureModel> confirmedProjects; // 🔥 تم إضافة قائمة المشاريع هنا

  TeachingLoadReportModel({
    required this.instructorName,
    required this.faculty,
    required this.department,
    required this.rank,
    required this.reportDate,
    required this.isfinished,
    required this.confirmedLectures,
    required this.confirmedExams,
    required this.confirmedProjects, // 🔥 تم إضافتها هنا
    required this.totalCompletedHours,
  });

  factory TeachingLoadReportModel.fromJson(Map<String, dynamic> json) {
    final info = json['instructor_info'] ?? {};
    final stats = json['statistics'] ?? {};

    // معالجة المحاضرات
    var lecturesList = (stats['lectures'] as List? ?? []).map((e) {
      int done = int.tryParse(e['done'].toString()) ?? 0;
      int total = int.tryParse(e['required'].toString()) ?? 0;

      return LectureModel(
        id: 0,
        subject: e['course'] ?? 'مادة غير مسمى',
        type: "نظري",
        time: "$done - $total",
        room: "مكتمل $done/$total",
        checked: (total > 0 && done >= total),
      );
    }).toList();

    // معالجة الامتحانات
    var examsList = (stats['exams'] as List? ?? []).map((e) {
      double done = double.tryParse(e['done'].toString()) ?? 0;
      double total = double.tryParse(e['required'].toString()) ?? 0;

      return ExamModel(
        id: 0,
        course: e['course'] ?? 'مادة غير محددة',
        date: "",
        room: "",
        time: "$done - $total",
        checked: (total > 0 && done >= total),
      );
    }).toList();

    // 🔥 معالجة المشاريع القادمة من الـ API
    var projectsList = (stats['projects'] as List? ?? []).map((e) {
      int done = int.tryParse(e['done'].toString()) ?? 0;
      int total = int.tryParse(e['required'].toString()) ?? 0;

      return LectureModel(
        id: 0,
        subject: e['course'] ?? 'مشروع غير مسمى',
        type: "عملي/متابعة",
        time: "$done - $total",
        room: "مكتمل $done/$total",
        checked: (total > 0 && done >= total),
      );
    }).toList();

    final double completedHours =
        (json['total_completed_hours'] ?? json['total_hours'] ?? 0).toDouble();

    return TeachingLoadReportModel(
      instructorName: info['name'] ?? 'غير معروف',
      faculty: info['faculty'] ?? '',
      isfinished: info["is_finished"] ?? false,
      department: info['department'] ?? '',
      rank: info['rank'] ?? '',
      reportDate: info['report_date'] ?? '',
      totalCompletedHours: completedHours,
      confirmedLectures: lecturesList,
      confirmedExams: examsList,
      confirmedProjects: projectsList, // 🔥 تمرير القائمة هنا
    );
  }
}
