import 'package:edutrack/Features/Insructor/Features/Notifecation/buisnes_logic_layer/NotificationController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // خلفية رمادية فاتحة جداً مريحة

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }

        if (controller.notificationsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 65,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "لا يوجد لديك أي إشعارات حالياً",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notificationsList.length,
          itemBuilder: (context, index) {
            final notification = controller.notificationsList[index];

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                // تمييز الإشعار غير المقروء بخلفية بيضاء نقية ونبضة زرقاء خفيفة على الحواف
                color: notification.isRead
                    ? Colors.white
                    : const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: notification.isRead
                      ? Colors.grey.shade200
                      : Colors.blueAccent.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onTap: () {
                  controller.markSingleNotificationAsRead(
                    notification.notificationId,
                  );
                },

                // أيقونة مخصصة حسب نوع الإشعار مع إشارة نقطية صغيرة (Badge) للمقروء
                leading: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getIconColor(
                          notification.notificationType,
                        ).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconData(notification.notificationType),
                        color: _getIconColor(notification.notificationType),
                        size: 24,
                      ),
                    ),
                    if (!notification.isRead)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),

                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: notification.isRead
                        ? FontWeight.w600
                        : FontWeight.bold,
                    color: notification.isRead
                        ? Colors.black87
                        : Colors.blue.shade900,
                  ),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification.createdAt.substring(
                            0,
                            16,
                          ), // عرض السنة والشهر واليوم والوقت فقط
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // دالة مساعدة لاختيار الأيقونة حسب نوع الإشعار القادم من الباك إند
  IconData _getIconData(String type) {
    switch (type) {
      case 'REMINDER':
        return Icons.notification_important_rounded;
      case 'ALERT':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  // دالة مساعدة لتلوين الأيقونة
  Color _getIconColor(String type) {
    switch (type) {
      case 'REMINDER':
        return Colors.orange.shade700;
      case 'ALERT':
        return Colors.red.shade700;
      default:
        return Colors.blue.shade700;
    }
  }
}
