class AcademyFacultyModel {
  final int id;
  final String name;
  // جعلنا القائمة قابلة للتعديل لكي نحقن الأقسام القادمة من الرابط الثاني بداخلها
  List<AcademyDepartmentModel> departments;

  AcademyFacultyModel({
    required this.id,
    required this.name,
    required this.departments,
  });

  factory AcademyFacultyModel.fromJson(Map<String, dynamic> json) {
    return AcademyFacultyModel(
      id: json['id'] ?? json['faculty_id'] ?? 0,
      name: json['faculty_name'] ?? json['name'] ?? '',
      departments:
          (json['departments'] as List?)
              ?.map((d) => AcademyDepartmentModel.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class AcademyDepartmentModel {
  final int id;
  final String name;

  AcademyDepartmentModel({required this.id, required this.name});

  factory AcademyDepartmentModel.fromJson(Map<String, dynamic> json) {
    return AcademyDepartmentModel(
      id: json['department_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
