import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isOldPasswordVisible = false.obs;
  var isNewPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  var isLoading = false.obs;

  void toggleOldPasswordVisibility() => isOldPasswordVisible.value = !isOldPasswordVisible.value;
  void toggleNewPasswordVisibility() => isNewPasswordVisible.value = !isNewPasswordVisible.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  Future<void> changePassword() async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar("خطأ", "الرجاء تعبئة جميع الحقول", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (newPass.length < 6) {
      Get.snackbar("خطأ", "كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar("خطأ", "كلمة المرور الجديدة وتأكيدها غير متطابقين", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    // محاكاة إرسال الطلب للخادم (API) والتأكد من كلمة المرور القديمة
    // TODO: استبدل هذا الجزء بربط حقيقي بالـ API
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final currentStoredPassword = prefs.getString('user_password') ?? "123456"; // افتراضي لحساب التجربة

    if (oldPass != currentStoredPassword) {
      isLoading.value = false;
      Get.snackbar("كلمة مرور خاطئة", "كلمة المرور الحالية غير صحيحة!", backgroundColor: Colors.orange, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // حفظ الكلمة الجديدة
    await prefs.setString('user_password', newPass);

    isLoading.value = false;

    // الرسالة والرجوع
    Get.back();
    Get.snackbar("نجاح", "تم تغيير كلمة المرور وتحديثها في الموقع بنجاح!", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final ChangePasswordController controller = Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('تغيير كلمة المرور', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(Icons.lock_reset_rounded, size: 80, color: kPrimaryColor.withOpacity(0.8)),
            const SizedBox(height: 20),
            Text(
              "قم بإنشاء كلمة مرور قوية لتأمين حسابك",
              style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // كلمة المرور الحالية
            Obx(() => _buildPasswordField(
              label: "كلمة المرور الحالية",
              textController: controller.oldPasswordController,
              isObscure: !controller.isOldPasswordVisible.value,
              onToggleVisibility: controller.toggleOldPasswordVisibility,
            )),
            const SizedBox(height: 15),

            // كلمة المرور الجديدة
            Obx(() => _buildPasswordField(
              label: "كلمة المرور الجديدة",
              textController: controller.newPasswordController,
              isObscure: !controller.isNewPasswordVisible.value,
              onToggleVisibility: controller.toggleNewPasswordVisibility,
            )),
            const SizedBox(height: 15),

            // تأكيد كلمة المرور الجديدة
            Obx(() => _buildPasswordField(
              label: "تأكيد كلمة المرور الجديدة",
              textController: controller.confirmPasswordController,
              isObscure: !controller.isConfirmPasswordVisible.value,
              onToggleVisibility: controller.toggleConfirmPasswordVisibility,
            )),

            const SizedBox(height: 40),

            // زر الحفظ
            Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: controller.isLoading.value ? null : controller.changePassword,
                child: controller.isLoading.value
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("حفظ التغييرات", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController textController,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          ),
        ),
        TextField(
          controller: textController,
          obscureText: isObscure,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFFA931), size: 20),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey.shade400, size: 20),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
