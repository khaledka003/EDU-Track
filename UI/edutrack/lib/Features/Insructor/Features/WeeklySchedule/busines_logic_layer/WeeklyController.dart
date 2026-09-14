import 'package:edutrack/Features/Insructor/Features/WeeklySchedule/Data_layer/Service/WeeklyService.dart';
import 'package:get/get.dart';
import 'package:edutrack/main.dart'; // للوصول لـ box

class WeeklyController extends GetxController {
  final WeeklyService _weeklyService = WeeklyService();

  var isLoading = true.obs;
  var weeklyData = <String, List<dynamic>>{}.obs;

  @override
  void onInit() {
    loadSchedule();
    super.onInit();
  }

  Future<void> loadSchedule() async {
    try {
      isLoading(true);

      // جلب الـ ID من التخزين المحلي
      int? instructorId = box.read('user_id');

      if (instructorId == null) {
        return;
      }

      // استدعاء السيرفس
      final data = await _weeklyService.getWeeklySchedule(instructorId);

      if (data != null) {
        weeklyData.value = Map<String, List<dynamic>>.from(data);
      } else {
        weeklyData.clear();
      }
    } catch (e) {
      Get.snackbar("خطأ في البيانات", e.toString());
    } finally {
      isLoading(false);
    }
  }

  // 🔥 الدالة السحرية لفحص إذا كان الوقت محجوزاً بالجدول الأسبوعي للمحاضر
  bool isTimeSlotOccupied(String dayArabic, String timeSlot) {
    if (!weeklyData.containsKey(dayArabic)) return false;

    final dayLectures = weeklyData[dayArabic] ?? [];

    // فحص المطابقة داخل القائمة (تأكد من توافق المفتاح 'time' مع الـ API عندك)
    return dayLectures.any((lecture) => lecture['time'].toString() == timeSlot);
  }

  String get currentDayArabic {
    var now = DateTime.now();
    Map<int, String> arDays = {
      7: "الأحد",
      1: "الاثنين",
      2: "الثلاثاء",
      3: "الأربعاء",
      4: "الخميس",
      5: "الجمعة",
      6: "السبت",
    };
    return arDays[now.weekday] ?? "";
  }
}
