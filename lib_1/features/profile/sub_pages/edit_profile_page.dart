import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/profile/controllers/edit_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final EditProfileController controller = Get.put(EditProfileController());
  final AppController appController = Get.find<AppController>();

  static const Color kSakhrBlue = Color(0xFF015C92);
  static const Color kSakhrGold = Color(0xFFFFA931);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Obx(() => SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    // صورة الملف الشخصي مع زر التعديل
                    _buildProfileImage(),
                    const SizedBox(height: 30),

                    // حقول الإدخال
                    _buildEditableField("الاسم الأول", Icons.person_outline, controller.firstNameController),
                    const SizedBox(height: 15),
                    _buildEditableField("الاسم الأخير", Icons.person_outline, controller.lastNameController),
                    const SizedBox(height: 15),
                    _buildEditableField("البريد الإلكتروني", Icons.email_outlined, controller.emailController),
                    const SizedBox(height: 15),
                    _buildEditableField("رقم الهاتف", Icons.phone_android_outlined, controller.phoneController),

                    const SizedBox(height: 25),

                    // إعدادات البصمة (تفاعلية)
                    _buildBiometricToggle(),

                    const SizedBox(height: 35),

                    // زر الحفظ الرئيسي
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
        color: kSakhrBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "إعدادات الحساب",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Obx(() {
          ImageProvider? imageProvider;
          
          if (controller.selectedImage.value != null) {
            imageProvider = FileImage(controller.selectedImage.value!);
          } else if (appController.profilePicturePath.value.isNotEmpty) {
            imageProvider = FileImage(File(appController.profilePicturePath.value));
          } else if (appController.profilePictureUrl.value.isNotEmpty) {
            imageProvider = NetworkImage(appController.profilePictureUrl.value);
          } else {
            imageProvider = const NetworkImage("https://via.placeholder.com/150");
          }

          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kSakhrGold, width: 2),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: imageProvider,
              child: controller.isUploadingImage.value 
                  ? Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                      child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    )
                  : null,
            ),
          );
        }),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: () => controller.pickImage(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: kSakhrBlue, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, IconData icon, TextEditingController textController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 8),
          child: Text(label, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        TextFormField(
          controller: textController,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: kSakhrBlue, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBiometricToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: appController.isBiometricEnabled.value,
            onChanged: (val) {
              appController.isBiometricEnabled.value = val;
            },
            activeColor: kSakhrGold,
          ),
          Row(
            children: [
              Text("تفعيل تسجيل الدخول بالبصمة", style: GoogleFonts.cairo(fontSize: 13)),
              const SizedBox(width: 10),
              const Icon(Icons.fingerprint, color: kSakhrBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: kSakhrBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text("حفظ التعديلات", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
