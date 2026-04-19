import 'package:get/get.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/authentication/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final AppController appController = Get.find<AppController>();

  // متغيرات تفاعلية
  var selectedGovernorate = 'عدن'.obs;
  var notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
    selectedGovernorate.value = prefs.getString('selected_governorate') ?? 'عدن';
  }

  // الربط مع العملة في AppController
  String get selectedCurrency {
    switch (appController.currency.value) {
      case 'YER_OLD': return 'ريال يمني قديم (ر.ي.ق)';
      case 'YER_NEW': return 'ريال يمني جديد (ر.ي.ج)';
      case 'SAR': return 'ريال سعودي (ر.س)';
      case 'USD': return r'دولار ($)';
      default: return 'ريال يمني قديم (ر.ي.ق)';
    }
  }

  Future<void> updateGovernorate(String val) async {
    selectedGovernorate.value = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_governorate', val);
  }

  void updateCurrency(String val) {
    if (val.contains('قديم')) appController.changeCurrency('YER_OLD');
    else if (val.contains('جديد')) appController.changeCurrency('YER_NEW');
    else if (val.contains('سعودي')) appController.changeCurrency('SAR');
    else if (val.contains('دولار')) appController.changeCurrency('USD');
  }

  Future<void> toggleNotifications(bool val) async {
    notificationsEnabled.value = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
  }

  void logout() {
    Get.find<AuthController>().logout();
  }
}
