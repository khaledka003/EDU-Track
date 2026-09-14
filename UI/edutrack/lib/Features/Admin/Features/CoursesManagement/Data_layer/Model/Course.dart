class Course {
  final String courseId; // هذا سيمثل الـ course_code في الباكند
  final String courseName;
  final double creditHours;
  final String departmentName;
  final String facultyName;

  Course({
    required this.courseId,
    required this.courseName,
    required this.creditHours,
    required this.departmentName,
    this.facultyName = "",
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      // الباكند بيبعت course_id أو course_code
      courseId:
          json['course_id']?.toString() ??
          json['course_code']?.toString() ??
          '',
      courseName: json['course_name'] ?? '',
      creditHours: (json['credit_hours'] as num? ?? 0).toDouble(),
      departmentName: json['department_name'] ?? 'القسم العام',
      facultyName: json['faculty_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "course_code": courseId,
      "course_name": courseName,
      "credit_hours": creditHours,
      "department_name": departmentName,
      "faculty_name": facultyName,
    };
  }
}
