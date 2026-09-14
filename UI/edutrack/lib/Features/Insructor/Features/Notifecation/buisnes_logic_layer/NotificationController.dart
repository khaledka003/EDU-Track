import 'package:edutrack/Features/Insructor/Features/Notifecation/data_layer/Model/NotificationResponseModel.dart';
import 'package:edutrack/Features/Insructor/Features/Notifecation/data_layer/service/NotificationService.dart';
import 'package:get/get.dart';
import 'package:edutrack/main.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  var notificationsList = <NotificationModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // 1. جلب الإشعارات فقط (بدون تعديل حالتها أوتوماتيكياً)
  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      int currentUserId = box.read('user_id') ?? 0;
      if (currentUserId == 0) throw Exception("مستخدم غير معروف");

      final result = await _notificationService.getMyNotifications(
        currentUserId,
      );
      notificationsList.value = result.notifications;

      // ❌ تم حذف الدالة الفورية من هنا نهائياً لضمان بقاء الألوان الرمادية
    } catch (e) {
      Get.snackbar(
        "تنبيه",
        e.toString().replaceAll("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 2. دالة ذكية وجديدة: تُستدعى *فقط* عند كبسة الدكتور على إشعار محدد
  Future<void> markSingleNotificationAsRead(int notificationId) async {
    try {
      // البحث عن الإشعار المحدد داخل اللستة المحلية
      var index = notificationsList.indexWhere(
        (n) => n.notificationId == notificationId,
      );

      if (index != -1 && !notificationsList[index].isRead) {
        // تحديث الواجهة محلياً فوراً ليقلب لونه لأبيض وتختفي النقطة
        notificationsList[index].isRead = true;
        notificationsList.refresh();

        // إرسال الطلب للباك إند بالخلفية لتحديث قاعدة البيانات
        await _notificationService.markAllAsRead(notificationId);
      }
    } catch (e) {
      print("Error updating single notification: $e");
    }
  }
}
