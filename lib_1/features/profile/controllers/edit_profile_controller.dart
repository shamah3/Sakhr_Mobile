import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  final formKey = GlobalKey<FormState>();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  var isLoading = false.obs;
  var isUploadingImage = false.obs;
  var selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    // Initialize with real data from AppController
    firstNameController = TextEditingController(text: _appController.user.value?.firstName ?? _appController.firstName.value);
    lastNameController = TextEditingController(text: _appController.user.value?.lastName ?? _appController.lastName.value);
    emailController = TextEditingController(text: _appController.user.value?.email ?? "");
    phoneController = TextEditingController(text: _appController.user.value?.phone ?? _appController.phoneNumber.value);
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'خطأ',
        'الرجاء التأكد من صحة البيانات المدخلة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final token = _appController.token.value;
      await _appController.ensureUserLoaded();
      
      // If no token, we can only update locally (Visitor mode)
      bool success = true;
      if (token.isNotEmpty) {
        success = await _apiService.saveAdminCustomer(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          fingerprint: "1", 
          profileImagePath: _appController.profilePicturePath.value,
          token: token,
        );
      }

      if (success) {
        // Update local state and persistence
        _appController.updateUserName(
          firstNameController.text.trim(),
          lastNameController.text.trim(),
          phone: phoneController.text.trim(),
        );

        Get.snackbar(
          'تم بنجاح',
          'تم تحديث بياناتك في المنصة بنجاح!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        Get.back();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل تحديث البيانات في المنصة، يرجى المحاولة لاحقاً',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, 
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        // Automatically save locally and upload
        _appController.profilePicturePath.value = image.path;
        await _uploadProfileImage(image.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      Get.snackbar("خطأ", "فشل الوصول إلى الاستوديو");
    }
  }

  Future<void> _uploadProfileImage(String filePath) async {
    final token = _appController.token.value;
    if (token.isEmpty) return; 

    try {
      isUploadingImage.value = true;
      final result = await _apiService.uploadProfilePicture(filePath, token);

      if (result != null) {
        if (result != "SUCCESS") {
          _appController.profilePictureUrl.value = result;
        }
        Get.snackbar("تم بنجاح", "تم تحديث الصورة الشخصية في المنصة");
      } else {
        Get.snackbar("تنبيه", "تم حفظ الصورة محلياً فقط، فشل الرفع للمنصة حالياً");
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
    } finally {
      isUploadingImage.value = false;
    }
  }

  void changeProfilePicture() {
    pickImage();
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
