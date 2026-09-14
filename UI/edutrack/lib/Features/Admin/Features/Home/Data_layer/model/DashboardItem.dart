import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DashboardItem {
  final String title;
  final IconData icon;
  final String value;
  final Color color;
  DashboardItem(this.title, this.icon, this.value, this.color);
}

final List<DashboardItem> dashboardData = [
  DashboardItem(
    "إجمالي المدرسين",
    Icons.people_alt,
    "45",
    MyColors().Ocean_Blue,
  ),
  DashboardItem("المقررات النشطة", Icons.menu_book, "87", Colors.green),
  DashboardItem(
    "تخصيصات هذا الفصل",
    Icons.assignment_turned_in,
    "120",
    Colors.orange,
  ),
  DashboardItem("القاعات المشغولة", Icons.meeting_room, "15", Colors.redAccent),
];
