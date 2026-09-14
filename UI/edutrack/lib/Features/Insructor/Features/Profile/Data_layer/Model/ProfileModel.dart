class ProfileModel {
  final String fullName;
  final String email;
  final String academicRank;
  final String specialization;
  final String faculty;
  final String mobile;

  ProfileModel({
    required this.fullName,
    required this.email,
    required this.academicRank,
    required this.specialization,
    required this.faculty,
    required this.mobile,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      academicRank: json['academic_rank'] ?? 'غير محدد',
      specialization: json['specialization'] ?? 'غير محدد',
      faculty: json['faculty'] ?? 'غير محدد',
      mobile: json['mobile'] ?? 'لا يوجد',
    );
  }
}
