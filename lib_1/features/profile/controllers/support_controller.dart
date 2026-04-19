import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';

class SupportController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  var isLoading = false.obs;

  Future<void> submitSupportTicket() async {
    if (subjectController.text.isEmpty || messageController.text.isEmpty) {
      Get.snackbar("تنبيه", "يرجى تعبئة جميع الحقول", 
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) {
        Get.snackbar("خطأ", "يجب تسجيل الدخول أولاً", 
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }

      final success = await _apiService.postSupportTicket({
        "subject": subjectController.text.trim(),
        "message": messageController.text.trim(),
        "type": "technical",
      }, token);

      if (success) {
        Get.snackbar("نجاح", "تم إرسال تذكرة الدعم بنجاح", 
            backgroundColor: Colors.green, colorText: Colors.white);
        
        // Log Activity
        Get.find<ActivitiesController>().logActivity(
          title: "إرسال تذكرة دعم: ${subjectController.text}",
          type: 'support'
        );

        subjectController.clear();
        messageController.clear();
      } else {
        Get.snackbar("خطأ", "فشل إرسال التذكرة، حاول لاحقاً", 
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error submitting support ticket: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
