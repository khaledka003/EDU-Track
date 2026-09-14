import 'package:edutrack/Features/Admin/Features/FacultyMangment/Data_layer/Model/AcademyFacultyModel.dart';
import 'package:get/get.dart';
import 'package:edutrack/Features/Admin/Features/FacultyMangment/Data_layer/FacultyService.dart'
    show FacultyService;
// import 'AcademyFacultyModel.dart';

class FacultyController extends GetxController {
  final FacultyService service = FacultyService();

  var faculties = <AcademyFacultyModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchFaculties();
    super.onInit();
  }

  // جلب الكليات ثم حقن الأقسام الخاصة بكل كلية تلقائياً
  void fetchFaculties() async {
    try {
      isLoading(true);
      var response = await service.getAllFaculties();

      if (response.data != null) {
        List<AcademyFacultyModel> tempFaculties = [];

        // 1. تحليل بيانات الكليات الأساسية أولاً
        if (response.data is List) {
          tempFaculties = (response.data as List)
              .map((e) => AcademyFacultyModel.fromJson(e))
              .toList();
        } else if (response.data is Map) {
          if (response.data['data'] != null && response.data['data'] is List) {
            tempFaculties = (response.data['data'] as List)
                .map((e) => AcademyFacultyModel.fromJson(e))
                .toList();
          } else {
            tempFaculties.add(AcademyFacultyModel.fromJson(response.data));
          }
        }

        // 2. جلب الأقسام لكل كلية من رابط الأقسام المنفصل الخاص بك
        for (var faculty in tempFaculties) {
          if (faculty.id != 0) {
            try {
              var deptResponse = await service.getDepartmentsByFaculty(
                faculty.id,
              );
              if (deptResponse.data != null) {
                List deptData = [];
                if (deptResponse.data is Map &&
                    deptResponse.data['data'] != null) {
                  deptData = deptResponse.data['data'];
                } else if (deptResponse.data is List) {
                  deptData = deptResponse.data;
                } else if (deptResponse.data is Map) {
                  // في حال كان الـ Object يحتوي على الأقسام مباشرة
                  deptData = deptResponse.data['departments'] ?? [];
                }

                faculty.departments = deptData
                    .map((d) => AcademyDepartmentModel.fromJson(d))
                    .toList();
              }
            } catch (e) {
              print("فشل جلب أقسام الكلية رقم ${faculty.id}: $e");
            }
          }
        }

        // تحديث القائمة النهائية المتكاملة في الواجهة
        faculties.assignAll(tempFaculties);
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل جلب الكليات: $e");
    } finally {
      isLoading(false);
    }
  }

  // إضافة كلية
  Future<void> createFaculty(String name) async {
    try {
      var response = await service.addFaculty({"name": name});
      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchFaculties();
        Get.back();
        Get.snackbar("نجاح", "تمت إضافة الكلية بنجاح");
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل إضافة الكلية");
    }
  }

  // إضافة قسم جديد
  Future<void> createDepartment(int facultyId, String name) async {
    try {
      var response = await service.addDepartment({
        "name": name,
        "faculty_id": facultyId,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchFaculties();
        Get.back();
        Get.snackbar("نجاح", "تمت إضافة القسم بنجاح");
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل إضافة القسم");
    }
  }
}
