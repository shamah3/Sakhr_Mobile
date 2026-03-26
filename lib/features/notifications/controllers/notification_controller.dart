import 'package:get/get.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/notifications/models/notification_model.dart';
import 'package:flutter/foundation.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final fetched = await _apiService.fetchNotifications(token);
      notifications.assignAll(fetched);
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNotification(String title, String body, {String? category}) async {
    try {
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final success = await _apiService.createNotification({
        "title": title,
        "content": body,
        "category": category,
      }, token);

      if (success) {
        await loadNotifications();
      }
    } catch (e) {
      debugPrint("Error adding notification: $e");
    }
  }

  void deleteNotification(int id) {
    // Note: Backend endpoint for deleting a specific notification wasn't provided, 
    // but we can remove it from the local list for UI responsiveness.
    notifications.removeWhere((n) => n.id == id);
  }

  void clearNotifications() {
    // Same as above, local clear if no backend endpoint.
    notifications.clear();
  }
}
