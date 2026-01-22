import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ComplaintsController extends GetxController {
  var selectedType = Rxn<String>();
  var fileName = Rxn<String>();
  var isLoading = false.obs;

  // --- السطر الناقص الذي يسبب الخطأ ---
  final List<String> complaintTypes = ['تأخر التوصيل', 'منتج تالف', 'مشكلة تقنية', 'أخرى'];

  void updateSelectedType(String? val) => selectedType.value = val;

  void pickImage() {
    fileName.value = "image_selected.png";
  }

  void submitForm() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;

    Get.snackbar("نجاح", "تم إرسال شكواك بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white
    );
  }
}