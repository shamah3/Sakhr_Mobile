import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // وحدات التحكم بالنصوص مع قيم افتراضية
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    // يمكنك هنا جلب البيانات من الكنترولر الخاص بالمستخدم لاحقاً
    firstNameController = TextEditingController(text: 'جيهان');
    lastNameController = TextEditingController(text: 'اسكندر');
    emailController = TextEditingController(text: 'jeehan@example.com');
    phoneController = TextEditingController(text: '777123456');
  }

  void saveProfile() {
    if (formKey.currentState!.validate()) {
      // هنا تضع منطق الإرسال للسيرفر API
      Get.snackbar(
        'تم بنجاح',
        'تم حفظ التغييرات بنجاح!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Profile saved via GetX');
    } else {
      Get.snackbar(
        'خطأ',
        'الرجاء التأكد من صحة البيانات المدخلة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void changeProfilePicture() {
    debugPrint('Change profile picture logic here');
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
