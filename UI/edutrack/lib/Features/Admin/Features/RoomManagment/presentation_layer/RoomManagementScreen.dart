import 'package:edutrack/Features/Admin/Features/RoomManagment/busines_logic_layer/RoomController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:edutrack/Style/Colors.dart';

class Roommanagementscreen extends StatelessWidget {
  Roommanagementscreen({super.key});

  final Roomcontroller controller = Get.put(Roomcontroller());
  final MyColors colors = MyColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            const SizedBox(height: 30),
            _buildStatsRow(),
            const SizedBox(height: 30),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.rooms.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: colors.Ocean_Blue),
                  );
                }
                if (controller.rooms.isEmpty) {
                  return _buildEmptyState();
                }
                // استخدام GridView للتعامل مع عدد كبير من الغرف بشكل منظم
                return _buildRoomGrid();
              }),
            ),
          ],
        ),
      ),
    );
  }

  // القسم العلوي: العنوان وزر الإضافة
  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('existing_rooms'), // أو "إدارة القاعات الدراسية"
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.Oxford_Blue,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              tr('manage_rooms_subtitle'), // أضف نص فرعي مناسب
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _openRoomModal(),
          icon: const Icon(Icons.add_circle_outline, size: 22),
          label: Text(
            tr('add_new_room'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.Ocean_Blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  // صف الإحصائيات
  Widget _buildStatsRow() {
    return Obx(
      () => Row(
        children: [
          _statItem(
            tr('total_rooms'),
            controller.rooms.length.toString(),
            Icons.meeting_room_outlined,
            Colors.blue,
          ),
          const SizedBox(width: 20),
          _statItem(
            tr('total_capacity'),
            _calculateTotalCapacity(),
            Icons.people_outline,
            Colors.green,
          ),
        ],
      ),
    );
  }

  String _calculateTotalCapacity() {
    int total = 0;
    for (var room in controller.rooms) {
      total += int.tryParse(room['capacity'].toString()) ?? 0;
    }
    return total.toString();
  }

  Widget _statItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // شبكة عرض الغرف
  Widget _buildRoomGrid() {
    return GridView.builder(
      itemCount: controller.rooms.length,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // زيادة الأعمدة لعرض غرف أكثر
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2, // جعل الكارد نحيفاً عرضياً
      ),
      itemBuilder: (context, index) {
        final room = controller.rooms[index];
        return _buildRoomCard(room);
      },
    );
  }

  // كارت الغرفة
  Widget _buildRoomCard(Map room) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // أيقونة الغرفة صغيرة
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.Ocean_Blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.meeting_room,
                color: colors.Ocean_Blue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // تفاصيل الغرفة
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${room['location']} • ${tr('capacity')}: ${room['capacity']}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // أزرار التحكم (تعديل وحذف)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر التعديل
                // IconButton(
                //   onPressed: () => _openRoomModal(),
                //   icon: const Icon(
                //     Icons.edit_outlined,
                //     size: 18,
                //     color: Colors.blue,
                //   ),
                //   constraints:
                //       const BoxConstraints(), // لتقليل المسافات حول الأيقونة
                //   padding: const EdgeInsets.all(4),
                //   tooltip: "تعديل",
                // ),
                // زر الحذف
                IconButton(
                  onPressed: () => controller.deleteRoom(room["id"]),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  tooltip: "حذف",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // نافذة الإضافة (Modal) لتقليل زحمة الواجهة الرئيسية
  void _openRoomModal({Map? room}) {
    // إذا كان هناك بيانات (تعديل)، نملأ الحقول، وإلا نقوم بتصفيرها (إضافة جديدة)
    if (room != null) {
      controller.nameCtrl.text = room['room_name'] ?? room['name'] ?? '';
      controller.locCtrl.text = room['location'] ?? '';
      controller.capCtrl.text = room['capacity']?.toString() ?? '';
    } else {
      controller.nameCtrl.clear();
      controller.locCtrl.clear();
      controller.capCtrl.clear();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room == null ? tr('add_new_room') : "تعديل بيانات القاعة",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              _buildInput(
                tr('room_number_label'),
                Icons.meeting_room_outlined,
                controller.nameCtrl,
              ),
              const SizedBox(height: 15),
              _buildInput(
                tr('location_label'),
                Icons.location_on_outlined,
                controller.locCtrl,
              ),
              const SizedBox(height: 15),
              _buildInput(
                tr('capacity_label'),
                Icons.people_outline,
                controller.capCtrl,
                isNumber: true,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(tr('cancel')),
                  ),
                  const SizedBox(width: 15),
                  Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.Ocean_Blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        Get.back();

                        // استدعاء دالة الإضافة أو التعديل (ستعمل في الخلفية)
                        if (room == null) {
                          controller.createRoom();
                        }

                        // الإغلاق يتم فقط بعد انتهاء العملية بنجاح
                        // ملاحظة: الـ Controller يفضل أن يرمي Error إذا فشل الطلب لضمان عدم الإغلاق عند الخطأ
                      },

                      // تنفيذ العملية (إضافة أو تعديل)
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              room == null ? tr('add_btn') : "حفظ التعديلات",
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String hint,
    IconData icon,
    TextEditingController ctrl, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.all(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 15),
          Text(
            tr('no_rooms_found'),
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
