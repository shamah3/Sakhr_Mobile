import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/profile/models/complaint_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ComplaintsController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  var complaints = <ComplaintModel>[].obs;
  var selectedType = Rxn<String>();
  var fileName = Rxn<String>();
  var isLoading = false.obs;
  var isFetching = false.obs;

  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final List<String> complaintTypes = ['تأخر التوصيل', 'منتج تالف', 'مشكلة تقنية', 'أخرى'];

  @override
  void onInit() {
    super.onInit();
    fetchComplaints();
  }

  void updateSelectedType(String? val) => selectedType.value = val;

  void pickImage() {
    fileName.value = "image_selected.png";
  }

  Future<void> fetchComplaints() async {
    try {
      isFetching.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final fetched = await _apiService.fetchComplaints(token);
      complaints.assignAll(fetched);
    } catch (e) {
      debugPrint("Error fetching complaints: $e");
    } finally {
      isFetching.value = false;
    }
  }

  void submitForm() async {
    if (selectedType.value == null || messageController.text.isEmpty) {
      Get.snackbar("تنبيه", "يرجى تعبئة جميع الحقول المطلوبة", 
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final data = {
        "type": selectedType.value,
        "order_id": orderIdController.text,
        "message": messageController.text,
      };

      final success = await _apiService.createComplaint(data, token);
      
      if (success) {
        Get.snackbar("نجاح", "تم إرسال شكواك بنجاح",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white
        );
        fetchComplaints();
        // Clear fields
        messageController.clear();
        orderIdController.clear();
        selectedType.value = null;
        fileName.value = null;
      } else {
        Get.snackbar("خطأ", "فشل إرسال الشكوى، يرجى المحاولة لاحقاً", 
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error submitting complaint: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    orderIdController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
