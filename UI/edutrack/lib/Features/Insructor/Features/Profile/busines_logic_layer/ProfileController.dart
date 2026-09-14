import 'package:edutrack/Features/Insructor/Features/Profile/Data_layer/Model/ProfileModel.dart';
import 'package:edutrack/Features/Insructor/Features/Profile/Data_layer/Service/ProfileService.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();

  var isLoading = true.obs;
  var profile =
      Rxn<ProfileModel>(); // سنخزن البيانات هنا كـ Map مؤقتاً أو استخدم Model

  @override
  void onInit() {
    super.onInit();
    getProfile(); // يجلب البيانات تلقائياً بمجرد تشغيل الكنترولر
  }

  void getProfile() async {
    try {
      isLoading(true);
      var data = await _service.fetchProfileData();
      if (data != null) {
        profile.value = data;
      }
    } finally {
      isLoading(false);
    }
  }
}
