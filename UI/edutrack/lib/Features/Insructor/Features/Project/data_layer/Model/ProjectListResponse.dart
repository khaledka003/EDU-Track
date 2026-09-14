class ProjectListResponse {
  final String status;
  final int count;
  final List<ProjectModel> projects;

  ProjectListResponse({
    required this.status,
    required this.count,
    required this.projects,
  });

  factory ProjectListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectListResponse(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      projects:
          (json['data'] as List?)
              ?.map((item) => ProjectModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ProjectModel {
  final int projectId;
  final String projectTitle;
  final String projectTypeKey;
  final String projectTypeDisplay;

  final String facultyName;
  final String departmentName;

  final double theoryHours;
  final double practicalHours;

  ProjectModel({
    required this.projectId,
    required this.projectTitle,
    required this.projectTypeKey,
    required this.projectTypeDisplay,

    required this.facultyName,
    required this.departmentName,

    required this.theoryHours,
    required this.practicalHours,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['project_id'] ?? 0,
      projectTitle: json['project_title'] ?? '',
      projectTypeKey: json['project_type_key'] ?? '',
      projectTypeDisplay: json['project_type_display'] ?? '',

      facultyName: json['faculty_name'] ?? '',
      departmentName: json['department_name'] ?? '',

      theoryHours: (json['theory_hours'] as num?)?.toDouble() ?? 0.0,
      practicalHours: (json['practical_hours'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
