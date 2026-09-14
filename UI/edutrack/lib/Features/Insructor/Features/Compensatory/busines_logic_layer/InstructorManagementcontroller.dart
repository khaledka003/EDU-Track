import 'package:edutrack/Features/Employee/Lecture_mangment/data_layer/Model/EmployeeLectureModel.dart';
import 'package:edutrack/Features/Employee/Lecture_mangment/data_layer/service/EmployeeManagementService.dart';
import 'package:edutrack/main.dart';
import 'package:get/get.dart';

class InstructorManagementcontroller extends GetxController {
  final EmployeeManagementService _service = EmployeeManagementService();

  // حالات التحميل
  var isLoadingLectures = false.obs;
  var isLoadingFilters = false.obs;

  // القوائم الأساسية للفلترة والعرض (تعتمد على الموديل الجديد المخصص للفصل)
  var lectures = <EmployeeLectureModel>[].obs;
  var facultyInstructors = [].obs;
  final facultyCourses = [].obs;

  // القيم المختارة حالياً في الفلاتر (تكون null إذا لم يتم الاختيار)
  var instructorId = Rxn<dynamic>();

  var selectedHolidayDate = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    instructorId.value = box.read("ins_id");
    fetchLectures();
  }

  // جلب الفلاتر الأساسية (مدرسين، مواد، عطل) بناءً على بيانات الموظف المتاحة

  // جلب الفئات مع تطبيق الفلاتر المحددة حالياً
  // جلب الفئات مع تطبيق الفلاتر المحددة حالياً
  Future<void> fetchLectures() async {
    isLoadingLectures.value = true;
    try {
      final res = await _service.getLectures(instructorId: instructorId.value);

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
    instructorId.value = null;
    selectedHolidayDate.value = null;
    fetchLectures();
  }

  // حذف فئة

  // تعديل فئة

  // إضافة محاضرة تعويضية
  Future<void> addCompensatory({
    required int courseAllocationId,
    required int roomId,
    required String date,
    required String start,
    required String end,
  }) async {
    final res = await _service.addCompensatoryLecture(
      courseAllocationId: courseAllocationId,
      roomId: roomId,
      lectureDate: date,
      startTime: start,
      endTime: end,
    );

    if (res != null && res.statusCode == 201) {
      Get.back(); // إغلاق البوب أب أو الشاشة الفرعية
      Get.snackbar(
        'نجاح',
        'تمت إضافة المحاضرة التعويضية بنجاح إلى نصاب المدرس الأكاديمي',
      );
      // لا نحتاج لعمل fetchLectures هنا لأن التعويض ينزل بجدول مستقل (Teaching Load) ولا يؤثر على قائمة الفئات الأساسية المعروضة
    } else {
      Get.snackbar(
        'خطأ',
        res?.data?['message'] ?? 'فشل إضافة المحاضرة التعويضية',
      );
    }
  }
}
