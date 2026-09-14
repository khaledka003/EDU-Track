import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String subTitle; // التاريخ أو (نظري/عملي)
  final String time;
  final String room;
  final RxBool isChecked; // استلمنا الـ RxBool مباشرة من الموديل
  final VoidCallback onCheckChanged; // دالة التبديل بالكنترولر

  const InfoCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.time,
    required this.room,
    required this.isChecked,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // السطر العلوي: (نظري/عملي أو التاريخ) + الـ Checkbox
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
              // الـ Obx هون فقط لمراقبة الـ Checkbox
              Obx(
                () => Checkbox(
                  activeColor: Colors.green,
                  value: isChecked.value, // يقرأ القيمة من الـ RxBool مباشرة
                  onChanged: (value) {
                    onCheckChanged(); // ينادي الدالة الموجودة بالكنترولر
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // العنوان (اسم المادة)
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),
          const Divider(height: 20),

          // السطر السفلي: الوقت والقاعة
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Spacer(),
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 4),
              Text(
                room,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
