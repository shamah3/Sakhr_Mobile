import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/models/activity_model.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/controllers/app_controller.dart';
class ActivitiesController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  // قائمة الأنشطة (Observable)
  var activities = <ActivityModel>[].obs;
  // حالة التحميل
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivities(); // جلب البيانات فور تشغيل الصفحة
  }

  Future<void> fetchActivities() async {
    try {
      isLoading(true);
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final fetched = await _apiService.fetchActivities(token);
      if (fetched.isNotEmpty) {
        activities.assignAll(fetched);
      } else if (activities.isEmpty) {
        // Fallback or local session mock
        activities.assignAll([
          ActivityModel(title: "تسجيل الدخول", type: "login", time: "09:00 ص", date: "اليوم"),
          ActivityModel(title: "تصفح قسم الإلكترونيات", type: "view", time: "10:30 ص", date: "اليوم"),
        ]);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> logActivity({required String title, required String type}) async {
    // تحديث القائمة محلياً فوراً لتجربة مستخدم سريعة
    final now = DateTime.now();
    final timeStr = "${now.hour > 12 ? now.hour - 12 : now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'م' : 'ص'}";

    final newActivity = ActivityModel(
      title: title,
      time: timeStr,
      date: 'اليوم',
      type: type
    );
    
    activities.insert(0, newActivity);

    // الإرسال للسيرفر
    try {
      final token = _appController.token.value;
      if (token.isEmpty) return;

      await _apiService.postCustomerActivity({
        "title": title,
        "type": type,
        "description": "User performed $type: $title",
      }, token);
    } catch (e) {
      debugPrint("Error logging activity to server: $e");
    }
  }
}
