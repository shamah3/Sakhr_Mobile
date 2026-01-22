import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // متغيرات النصوص
  final titleController = TextEditingController();
  final streetController = TextEditingController();
  final buildingController = TextEditingController();
  final apartmentController = TextEditingController();

  // المنطقة المختارة (مراقبة)
  var selectedArea = Rxn<String>();

  final List<String> sanaaAreas = [
    'التحرير', 'حدة', 'الصافية', 'شعوب', 'أزال', 'معين',
    'السبعين', 'صنعاء القديمة', 'الوحدة', 'الثورة',
    'الحصبة', 'مذبح', 'شملان',
  ];

  void updateArea(String? value) {
    selectedArea.value = value;
  }

  void saveAddress() {
    if (formKey.currentState!.validate()) {
      // منطق الحفظ هنا
      Get.snackbar(
        'نجاح',
        'تم حفظ العنوان بنجاح!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back(); // العودة للصفحة السابقة
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    streetController.dispose();
    buildingController.dispose();
    apartmentController.dispose();
    super.onClose();
  }
}