import 'package:get/get.dart';

class ProfileController extends GetxController {
  // حالة تسجيل الدخول (Observable)
  var isLoggedIn = true.obs;

  // بيانات المستخدم (يمكن جلبها من API لاحقاً)
  var userName = 'jino Eskander'.obs;

  void handleLogout() {
    isLoggedIn.value = false;
    Get.snackbar('تسجيل الخروج', 'تم تسجيل خروجك بنجاح');
  }

  void handleLogin() {
    isLoggedIn.value = true;
    Get.snackbar('أهلاً بك', 'تم تسجيل الدخول بنجاح');
  }
}