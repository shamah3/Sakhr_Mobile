import 'package:get/get.dart';
import 'package:bytore/core/controllers/app_controller.dart';

class SettingsController extends GetxController {
  final AppController appController = Get.find<AppController>();

  // متغيرات تفاعلية
  var selectedGovernorate = 'عدن'.obs;
  var notificationsEnabled = true.obs;

  // الربط مع العملة في AppController
  String get selectedCurrency {
    switch (appController.currency.value) {
      case 'YER_OLD': return 'ريال يمني قديم (ر.ي.ق)';
      case 'YER_NEW': return 'ريال يمني جديد (ر.ي.ج)';
      case 'SAR': return 'ريال سعودي (ر.س)';
      case 'USD': return 'دولار (\$)';
      default: return 'ريال يمني قديم (ر.ي.ق)';
    }
  }

  void updateGovernorate(String val) => selectedGovernorate.value = val;

  void updateCurrency(String val) {
    if (val.contains('قديم')) appController.changeCurrency('YER_OLD');
    else if (val.contains('جديد')) appController.changeCurrency('YER_NEW');
    else if (val.contains('سعودي')) appController.changeCurrency('SAR');
    else if (val.contains('دولار')) appController.changeCurrency('USD');
  }

  void toggleNotifications(bool val) => notificationsEnabled.value = val;

  void logout() {
    // منطق تسجيل الخروج هنا
    Get.snackbar('تسجيل الخروج', 'تم تسجيل خروجك بنجاح');
  }
}
