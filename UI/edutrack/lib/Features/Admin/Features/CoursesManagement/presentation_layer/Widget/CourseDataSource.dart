import 'package:edutrack/Features/Admin/Features/CoursesManagement/Data_layer/Model/Course.dart';
import 'package:edutrack/Features/Admin/Features/CoursesManagement/busines_logic_layer/CourseController.dart';
import 'package:flutter/material.dart';

class CourseDataSource extends DataTableSource {
  final List<Course> courses;
  final CourseController controller;

  CourseDataSource(this.courses, this.controller);

  @override
  DataRow? getRow(int index) {
    if (index >= courses.length) return null;
    final course = courses[index];

    return DataRow(
      cells: [
        DataCell(Text(course.courseId)), // كود المقرر
        DataCell(Text(course.courseName)), // اسم المقرر
        DataCell(Text(course.departmentName)), // القسم
        DataCell(Text(course.creditHours.toString())), // الساعات
        DataCell(
          Row(
            children: [
              // زر التعديل
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  controller.prepareUpdate(course);
                  // إذا كنت بتستخدم ScrollController ممكن تخليه يطلع لفوق للفورم
                },
              ),
              // زر الحذف
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  // استدعاء دالة الحذف من الكنترولر
                  // الدالة بالكنترولر لازم تكون بتعمل حذف من القائمة courses.removeWhere
                  await controller.deleteCourse(course.courseId);

                  // السطر السحري اللي بيعمل ريفريش للجدول فوراً
                  notifyListeners();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => courses.length;

  @override
  int get selectedRowCount => 0;
}
