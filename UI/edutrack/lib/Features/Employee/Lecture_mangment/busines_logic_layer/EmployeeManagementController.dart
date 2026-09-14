import 'package:edutrack/Features/Employee/Lecture_mangment/data_layer/Model/AcademicHoliday.dart';
import 'package:edutrack/Features/Employee/Lecture_mangment/data_layer/Model/EmployeeLectureModel.dart';
import 'package:edutrack/Features/Employee/Lecture_mangment/data_layer/service/EmployeeManagementService.dart';
import 'package:edutrack/main.dart';
import 'package:get/get.dart';

class EmployeeManagementController extends GetxController {
  final EmployeeManagementService _service = EmployeeManagementService();

  // حالات التحميل
  var isLoadingLectures = false.obs;
  var isLoadingFilters = false.obs;

  // القوائم الأساسية للفلترة والعرض (تعتمد على الموديل الجديد المخصص للفصل)
  var lectures = <EmployeeLectureModel>[].obs;
  var holidays = <AcademicHoliday>[].obs;
  var facultyInstructors = [].obs;
  final facultyCourses = [].obs;

  // القيم المختارة حالياً في الفلاتر (تكون null إذا لم يتم الاختيار)
  var selectedInstructorId = Rxn<int>();
  var selectedCourseId = Rxn<dynamic>();
  var selectedHolidayDate = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadInitialFilters();
    fetchLectures();
  }

  // جلب الفلاتر الأساسية (مدرسين، مواد، عطل) بناءً على بيانات الموظف المتاحة
  Future<void> loadInitialFilters() async {
    isLoadingFilters.value = true;
    try {
      int? userId = box.read("user_id");
      int? facultyId = box.read("faculty_id");

      // طباعة للتأكد من القيم المخزنة في الـ Local Storage
      print("Local Storage Check -> UserID: $userId, FacultyID: $facultyId");

      if (userId == null || facultyId == null) {
        Get.snackbar('تنبيه', 'بيانات المستخدم أو الكلية غير متوفرة محلياً');
        return;
      }

      // 1. جلب المدرسين
      final instRes = await _service.getInstructorsByEmployeeFaculty(userId);
      if (instRes != null && instRes.statusCode == 200) {
        facultyInstructors.value = instRes.data['data'] ?? [];
        print("Instructors Loaded: ${facultyInstructors.length}");
      }

      // 2. جلب المواد
      final courseRes = await _service.getCoursesByFaculty(facultyId);
      if (courseRes != null && courseRes.statusCode == 200) {
        facultyCourses.value = courseRes.data['data'] ?? [];
        print("Courses Loaded: ${facultyCourses.length}");
      }

      // 3. جلب العطل
      final holidayRes = await _service.getAcademicHolidays();
      if (holidayRes != null && holidayRes.statusCode == 200) {
        var list = holidayRes.data['data'] as List?;
        if (list != null) {
          holidays.value = list
              .map((e) => AcademicHoliday.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      // الآن أي خطأ 404 أو 500 قادم من الباك إند سيظهر هنا فوراً في الـ Snackbar
      Get.snackbar(
        'خطأ في البيانات',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingFilters.value = false;
    }
  }

  // جلب الفئات مع تطبيق الفلاتر المحددة حالياً
  // جلب الفئات مع تطبيق الفلاتر المحددة حالياً
  Future<void> fetchLectures() async {
    isLoadingLectures.value = true;
    try {
      final res = await _service.getLectures(
        holidayDate: selectedHolidayDate.value,
        instructorId: selectedInstructorId.value,
        courseId: selectedCourseId.value,
      );

      if (res != null && res.statusCode == 200) {
        // 1. استخراج الـ دكشنري الأساسي للـ response body
        final Map<String, dynamic> responseData = res.data;

        // 2. استخراج المصفوفة الموجودة جوات مفتاح الـ 'data' وتأمينها في حال كانت Null
        final List<dynamic>? lecturesList = responseData['data'];

        if (lecturesList != null) {
          // 3. تحويل عناصر المصفوفة إلى الـ Model الجديد تبعنا وتحديث القائمة الـ Rx
          lectures.value = lecturesList
              .map((lectureJson) => EmployeeLectureModel.fromJson(lectureJson))
              .toList();
        } else {
          lectures.clear();
        }
      } else {
        Get.snackbar(
          'خطأ',
          res?.data?['message'] ?? 'فشل جلب بيانات المحاضرات من السيرفر',
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء معالجة البيانات: $e');
    } finally {
      isLoadingLectures.value = false;
    }
  }

  // تصفير الفلاتر وإعادة التحديث
  void resetFilters() {
    selectedInstructorId.value = null;
    selectedCourseId.value = null;
    selectedHolidayDate.value = null;
    fetchLectures();
  }

  // حذف فئة
  Future<void> deleteLecture(int lectureId) async {
    final res = await _service.manageLecture(lectureId, 'DELETE');
    if (res != null && res.statusCode == 200) {
      Get.snackbar('نجاح', 'تم حذف الفئة بنجاح من الجدول الأسبوعي');
      fetchLectures();
    } else {
      Get.snackbar(
        'خطأ',
        res?.data?['message'] ?? 'لم يتم الحذف، يرجى المحاولة لاحقاً',
      );
    }
  }

  // تعديل فئة
  Future<void> updateLecture(
    int lectureId,
    Map<String, dynamic> updatedData,
  ) async {
    final res = await _service.manageLecture(
      lectureId,
      'PUT',
      data: updatedData,
    );
    if (res != null && res.statusCode == 200) {
      Get.back(); // إغلاق الدايلوج تلقائياً بعد النجاح
      Get.snackbar('نجاح', 'تم تحديث بيانات الفئة بنجاح');
      fetchLectures();
    } else {
      Get.snackbar('خطأ', res?.data?['message'] ?? 'لم يتم تحديث البيانات');
    }
  }

  // إضافة محاضرة تعويضية
}
