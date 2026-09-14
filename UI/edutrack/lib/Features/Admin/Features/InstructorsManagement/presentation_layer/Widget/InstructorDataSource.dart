import 'package:edutrack/Features/Admin/Features/InstructorsManagement/Data_layer/Model/Instructor.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/busines_logic_layer/InstructorController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';

class InstructorDataSource extends DataTableSource {
  final List<Instructor> _data;
  final BuildContext context;
  InstructorDataSource(this._data, this.context);
  InstructorController controller = Get.put(InstructorController());

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final instructor = _data[index];
    return DataRow(
      cells: [
        DataCell(
          Text(
            instructor.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(Text(instructor.email)),
        DataCell(Text(instructor.facultyName)),
        DataCell(
          _statusChip(instructor.academicRank),
        ), // تحويل الرتبة لـ Chip ملون
        DataCell(
          Row(
            children: [
              _actionIcon(Icons.edit_note_rounded, Colors.blue, () {
                controller.prepareEdit(instructor);
              }),
              const SizedBox(width: 8),
              _actionIcon(Icons.delete_sweep_rounded, Colors.redAccent, () {
                controller.deleteInstructor(instructor.userId);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rank,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
}
