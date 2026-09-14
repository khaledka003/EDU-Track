import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/Data_layer/Model/Instructor.dart';
import 'package:edutrack/Features/Admin/Features/InstructorsManagement/presentation_layer/Widget/InstructorDataSource.dart';
import 'package:flutter/material.dart';

class InstructorsTable extends StatelessWidget {
  final List<Instructor> instructors;
  const InstructorsTable({super.key, required this.instructors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('current_instructors_list'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            _buildSmallBadge("${instructors.length} مدرس"),
          ],
        ),
        const SizedBox(height: 20),
        Theme(
          data: Theme.of(context).copyWith(),
          child: PaginatedDataTable(
            header: null,
            rowsPerPage: instructors.length < 8
                ? (instructors.isEmpty ? 1 : instructors.length)
                : 8,
            columnSpacing: 20,
            horizontalMargin: 10,
            columns: [
              DataColumn(label: _headerText(tr('col_name'))),
              DataColumn(label: _headerText(tr('col_email'))),
              DataColumn(label: _headerText(tr('col_faculty'))),
              DataColumn(label: _headerText(tr('col_rank'))),
              DataColumn(label: _headerText(tr('col_actions'))),
            ],
            source: InstructorDataSource(instructors, context),
          ),
        ),
      ],
    );
  }

  Widget _headerText(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF64748B),
    ),
  );

  Widget _buildSmallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF3B82F6),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
