import 'package:edutrack/Features/Admin/Features/AddAcademicYear/Data_layer/Model/AcademicYearModel.dart';
import 'package:edutrack/Features/Admin/Features/AddAcademicYear/Data_layer/Model/AcademicSemesterModel.dart';
import 'package:edutrack/Features/Admin/Features/AddAcademicYear/Data_layer/Service/SystemService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AcademicController extends GetxController {
  final AcademicService _service = AcademicService();

  var isLoading = false.obs;
  var allYears = <AcademicYearModel>[].obs;
  var selectedYearId = Rxn<int>();

  // متغيرات الإدخال
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var coordStartDate = Rxn<DateTime>();
  var coordEndDate = Rxn<DateTime>();
  var selectedHolidays = <DateTime>[].obs;
  var selectedSemType = "الفصل الدراسي الأول".obs;

  @override
  void onInit() {
    super.onInit();
    refreshAllData();
  }

  // القائمة المفلترة تجلب الفصول من السنة المختارة
  List<AcademicSemesterModel> get filteredSemesters {
    if (selectedYearId.value == null || allYears.isEmpty) return [];
    var year = allYears.firstWhereOrNull(
      (y) => y.yearId == selectedYearId.value,
    );
    return year?.semesters ?? [];
  }

  Future<void> refreshAllData() async {
    await fetchYearsAndSemesters();
  }

  Future<void> fetchYearsAndSemesters() async {
    try {
      isLoading.value = true;
      final res = await _service.getYears();
      if (res.statusCode == 200) {
        List data = res.data['data'];
        allYears.assignAll(
          data.map((e) => AcademicYearModel.fromJson(e)).toList(),
        );
        if (allYears.isNotEmpty && selectedYearId.value == null) {
          selectedYearId.value = allYears.first.yearId;
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectYear(int yearId) {
    selectedYearId.value = yearId;
  }

  // --- التابع الذي كان ناقصاً: إضافة سنة دراسية ---
  Future<void> submitYear(String name) async {
    try {
      isLoading.value = true;
      // افترضت هنا أن السيرفس لديه تابع addYear، عدله حسب اسم التابع عندك
      final res = await _service.openYear(name);
      if (res.statusCode == 201 || res.statusCode == 200) {
        await refreshAllData();
        Get.snackbar("نجاح", "تمت إضافة السنة الدراسية");
      }
    } catch (e) {
      _showError("خطأ في إضافة السنة: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitSemester({required int yearId, int? semesterId}) async {
    if (startDate.value == null ||
        endDate.value == null ||
        coordStartDate.value == null ||
        coordEndDate.value == null) {
      Get.snackbar(
        "تنبيه",
        "يرجى تحديد كافة التواريخ",
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      isLoading.value = true;
      Map<String, dynamic> data = {
        "academic_year_id": yearId,
        "semesterName": selectedSemType.value,
        "startDate": startDate.value!.toIso8601String(),
        "endDate": endDate.value!.toIso8601String(),
        // التأكد من إرسال هذه المسميات بدقة
        "coordination_start_date": coordStartDate.value!.toIso8601String(),
        "coordination_end_date": coordEndDate.value!.toIso8601String(),
        "holidays": selectedHolidays.map((h) => h.toIso8601String()).toList(),
      };

      if (semesterId == null) {
        final res = await _service.openSemester(data);
        if (res.statusCode == 201) {
          await refreshAllData();
          Get.back();
          Get.snackbar("نجاح", "تم إضافة الفصل الدراسي");
        }
      } else {
        final res = await _service.updateSemester(semesterId, data);
        if (res.statusCode == 200) {
          await refreshAllData();
          Get.back();
          Get.snackbar("نجاح", "تم تحديث الفصل");
        }
      }
    } catch (e) {
      _showError("حدث خطأ: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // تابع مساعد للتحقق من التاريخ الحالي (كان ناقصاً للواجهة)
  bool isTermNow(DateTime start, DateTime end) {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  // تابع الأرشفة (إذا لم يكن موجوداً في الباك إند، يمكنك تركه فارغاً حالياً)
  void toggleArchive(int id) {
    Get.snackbar("تنبيه", "ميزة الأرشفة سيتم ربطها قريباً");
  }

  void resetInputs(AcademicSemesterModel? sem) {
    if (sem != null) {
      startDate.value = sem.startDate;
      endDate.value = sem.endDate;
      selectedSemType.value = sem.semesterName;
      selectedHolidays.assignAll(sem.holidays);
      // ملاحظة: الحقول الناقصة في الموديل ستظهر كـ null حتى يتم تحديث الموديل
    } else {
      startDate.value = null;
      endDate.value = null;
      coordStartDate.value = null;
      coordEndDate.value = null;
      selectedHolidays.clear();
    }
  }

  void _showError(String msg) => Get.snackbar(
    "خطأ",
    msg,
    backgroundColor: Colors.redAccent,
    colorText: Colors.white,
  );
}
