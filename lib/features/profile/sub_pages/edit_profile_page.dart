import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/edit_profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'edit_profile_controller.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  // استدعاء الكنترولر
  final EditProfileController controller = Get.put(EditProfileController());

  static const Color primaryColor = Color(0xFF015C92);
  static const Color secondaryColor = Color(0xFFFFA931);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'إعدادات الملف الشخصي'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildProfileImagePicker(), // استدعاء دالة الصورة
              const SizedBox(height: 30),
              _buildTextField(
                controller: controller.firstNameController,
                label: 'الاسم الأول',
                icon: Icons.person_outline,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'الرجاء إدخال الاسم الأول'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.lastNameController,
                label: 'الاسم الأخير',
                icon: Icons.person_outline,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'الرجاء إدخال الاسم الأخير'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.emailController,
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value != null &&
                        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
                    ? null
                    : 'الرجاء إدخال بريد إلكتروني صحيح',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.phoneController,
                label: 'رقم الجوال',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الجوال';
                  }
                  if (!RegExp(r'^(7[01378])\d{7}$').hasMatch(value)) {
                    return 'الرجاء إدخال رقم جوال يمني صحيح (9 أرقام)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => controller.saveProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'حفظ التغييرات',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            child: const CircleAvatar(
              radius: 58,
              backgroundImage: CachedNetworkImageProvider(
                'https://i.pravatar.cc/150?u=a042581f4e29026704d',
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor,
                border: Border.all(width: 2, color: Colors.white),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                onPressed: () => controller.changeProfilePicture(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: secondaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
