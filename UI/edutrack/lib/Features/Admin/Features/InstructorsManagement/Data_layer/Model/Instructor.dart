class Instructor {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber; // الحقل الجديد
  final String facultyName;
  final String departmentName;
  final String academicRank;

  Instructor({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.facultyName,
    required this.departmentName,
    required this.academicRank,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '', // مابينغ مع الباكند
      facultyName: json['faculty_name'] ?? 'لم يحدد',
      departmentName: json['department_name'] ?? 'لم يحدد',
      academicRank: (json['academic_rank'] ?? '').toString().trim(),
    );
  }
  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) return "اسم غير معروف";
    return "$firstName $lastName".trim();
  }
}
