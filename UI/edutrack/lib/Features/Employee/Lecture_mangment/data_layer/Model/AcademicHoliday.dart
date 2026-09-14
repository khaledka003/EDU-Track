class AcademicHoliday {
  final String date;
  final String dayName;

  AcademicHoliday({required this.date, required this.dayName});

  factory AcademicHoliday.fromJson(Map<String, dynamic> json) {
    return AcademicHoliday(
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
    );
  }
}
