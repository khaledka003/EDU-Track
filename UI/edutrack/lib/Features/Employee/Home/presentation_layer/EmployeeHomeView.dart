import 'package:flutter/material.dart';

class EmployeeHomeView extends StatelessWidget {
  const EmployeeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رسالة ترحيبية
          const Text(
            "أهلاً بك مجدداً  👋",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "إليك ملخص نشاطك لهذا اليوم",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 30),

          // صف البطاقات العلوية (إحصائيات سريعة)
          Row(
            children: [
              _buildStatCard(
                "المهام المنجزة",
                "12/15",
                Icons.task_alt_rounded,
                Colors.blue,
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                "ساعات العمل",
                "140 ساعة",
                Icons.timer_rounded,
                Colors.orange,
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                "الراتب المتوقع",
                "4,500 \$",
                Icons.payments_rounded,
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // قسم المهام الحالية والجدول
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قائمة المهام اليومية
              Expanded(
                flex: 2,
                child: _buildSectionContainer(
                  "مهامي الحالية",
                  Column(
                    children: [
                      _buildTaskItem(
                        "تحديث قاعدة بيانات الطلاب",
                        "عالي",
                        Colors.red,
                      ),
                      _buildTaskItem(
                        "إعداد تقرير الحضور والغياب",
                        "متوسط",
                        Colors.orange,
                      ),
                      _buildTaskItem(
                        "مراجعة طلبات الإجازات",
                        "عادي",
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 25),
              // بطاقة الدوام أو الإعلانات
              Expanded(
                flex: 1,
                child: _buildSectionContainer(
                  "سجل الدوام اليوم",
                  Column(
                    children: [
                      _buildAttendanceRow(
                        "تسجيل الدخول",
                        "08:00 AM",
                        Colors.green,
                      ),
                      const Divider(height: 30),
                      _buildAttendanceRow("تسجيل الخروج", "--:--", Colors.grey),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "تسجيل الانصراف",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ويلجيت بناء بطاقة إحصائية
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ويلجيت حاوية الأقسام
  Widget _buildSectionContainer(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 25),
          child,
        ],
      ),
    );
  }

  // ويلجيت عنصر المهمة
  Widget _buildTaskItem(String task, String priority, Color priorityColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 12, color: priorityColor),
              const SizedBox(width: 15),
              Text(task, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: priorityColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويلجيت سجل الحضور
  Widget _buildAttendanceRow(String label, String time, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
