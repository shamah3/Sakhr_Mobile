import 'package:get/get.dart';

class SettingsController extends GetxController {
  // متغيرات تفاعلية
  var selectedGovernorate = 'عدن'.obs;
  var selectedCurrency = 'ريال يمني (YR)'.obs;
  var notificationsEnabled = true.obs;

  void updateGovernorate(String val) => selectedGovernorate.value = val;
  void updateCurrency(String val) => selectedCurrency.value = val;
  void toggleNotifications(bool val) => notificationsEnabled.value = val;

  void logout() {
    // منطق تسجيل الخروج هنا
    Get.snackbar('تسجيل الخروج', 'تم تسجيل خروجك بنجاح');
  }
}