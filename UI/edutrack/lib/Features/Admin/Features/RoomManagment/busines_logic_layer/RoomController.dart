import 'package:edutrack/Features/Admin/Features/RoomManagment/Data_layer/Service/RoomService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

class Roomcontroller extends GetxController {
  final Roomservice _service = Roomservice();

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController locCtrl = TextEditingController();
  TextEditingController capCtrl = TextEditingController();

  var isLoading = false.obs;
  var rooms = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  // --- جلب البيانات ---
  Future<void> fetchRooms() async {
    try {
      isLoading(true);
      final response = await _service.getAllRooms();
      if (response['status'] == 'success') {
        rooms.assignAll(List<Map<String, dynamic>>.from(response['data']));
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  // --- إضافة قاعة ---
  Future<void> createRoom() async {
    if (!_validateInputs()) return;

    try {
      isLoading(true);
      await _service.addRoom({
        "room_name": nameCtrl.text.trim(),
        "location": locCtrl.text.trim(),
        "capacity": int.parse(capCtrl.text.trim()),
      });

      _successAction("تمت إضافة القاعة بنجاح");
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  // --- تحديث قاعة (تعديل) ---

  // --- حذف قاعة ---
  Future<void> deleteRoom(int roomId) async {
    try {
      isLoading(true);
      // تأكد من وجود دالة deleteRoom في الـ RoomService
      await _service.deleteRoom(roomId);

      // تحديث القائمة محلياً فوراً لتحسين تجربة المستخدم
      rooms.removeWhere((room) => room['id'] == roomId);

      Get.snackbar(
        "نجاح",
        "تم حذف القاعة بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  // --- دوال مساعدة ---

  bool _validateInputs() {
    if (nameCtrl.text.isEmpty || locCtrl.text.isEmpty || capCtrl.text.isEmpty) {
      Get.snackbar("تنبيه", "يرجى ملء جميع الحقول");
      return false;
    }
    if (int.tryParse(capCtrl.text.trim()) == null) {
      Get.snackbar("خطأ", "السعة يجب أن تكون رقماً");
      return false;
    }
    return true;
  }

  void _successAction(String msg) {
    Get.snackbar("نجاح", msg);
    nameCtrl.clear();
    locCtrl.clear();
    capCtrl.clear();
    fetchRooms();
  }

  void _handleError(dynamic e) {
    if (e is dio.DioException) {
      String msg = e.response?.data?['message'] ?? "حدث خطأ في الاتصال";
      Get.snackbar("خطأ", msg);
    } else {
      Get.snackbar("خطأ", "حدث خطأ غير متوقع");
    }
  }
}
