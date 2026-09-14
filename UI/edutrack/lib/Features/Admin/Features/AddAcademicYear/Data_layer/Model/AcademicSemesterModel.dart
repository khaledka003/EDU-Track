class AcademicSemesterModel {
  int? id;
  String yearName;
  String semesterName;
  DateTime startDate;
  DateTime endDate;
  DateTime? coordinationStartDate;
  DateTime? coordinationEndDate;
  List<DateTime> holidays;
  bool isArchived;

  AcademicSemesterModel({
    this.id,
    required this.yearName,
    required this.semesterName,
    required this.startDate,
    required this.endDate,
    this.coordinationStartDate,
    this.coordinationEndDate,
    required this.holidays,
    this.isArchived = false,
  });

  // الدالة المستخدمة لتحويل البيانات القادمة من الباك إند (API)
  factory AcademicSemesterModel.fromJson(
    Map<String, dynamic> map, [
    String? yName,
  ]) {
    return AcademicSemesterModel(
      id: map['semester_id'],
      semesterName: map['semester_name'] ?? "غير محدد",
      yearName: yName ?? "",
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'])
          : DateTime.now(),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'])
          : DateTime.now(),
      // ملاحظة: السيرفر يرسل 'coordination_start' بدون كلمة _date في الـ JSON الخاص بك
      coordinationStartDate: map['coordination_start'] != null
          ? DateTime.parse(map['coordination_start'])
          : null,
      coordinationEndDate: map['coordination_end'] != null
          ? DateTime.parse(map['coordination_end'])
          : null,
      holidays:
          (map['holidays'] as List?)
              ?.map((h) => DateTime.parse(h.toString()))
              .toList() ??
          [],
      isArchived: !(map['is_active'] ?? true),
    );
  }

  // الدالة المستخدمة لإرسال البيانات للباك إند
  Map<String, dynamic> toMap(int academicYearId) {
    return {
      "academic_year_id": academicYearId,
      "semester_name": semesterName, // تأكد من مطابقة الاسم مع الباك إند
      "start_date": startDate.toIso8601String(),
      "end_date": endDate.toIso8601String(),
      "coordination_start_date": coordinationStartDate?.toIso8601String(),
      "coordination_end_date": coordinationEndDate?.toIso8601String(),
      "holidays": holidays.map((h) => h.toIso8601String()).toList(),
    };
  }
}
