import 'package:edutrack/Features/Admin/Features/AddAcademicYear/Data_layer/Model/AcademicSemesterModel.dart';

class AcademicYearModel {
  final int yearId;
  final String yearDisplay;
  final List<AcademicSemesterModel> semesters;

  AcademicYearModel({
    required this.yearId,
    required this.yearDisplay,
    required this.semesters,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      yearId: json['year_id'],
      yearDisplay: json['year_display'],
      semesters: (json['semesters'] as List)
          .map((s) => AcademicSemesterModel.fromJson(s, json['year_display']))
          .toList(),
    );
  }
}
