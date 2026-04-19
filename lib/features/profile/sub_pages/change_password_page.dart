import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isOldPasswordVisible = false.obs;
  var isNewPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  var isLoading = false.obs;

  void toggleOldPasswordVisibility() =>
      isOldPasswordVisible.value = !isOldPasswordVisible.value;
  void toggleNewPasswordVisibility() =>
      isNewPasswordVisible.value = !isNewPasswordVisible.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  Future<void> changePassword() async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        "خطأ",
        "الرجاء تعبئة جميع الحقول",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPass.length < 6) {
      Get.snackbar(
        "خطأ",
        "كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar(
        "خطأ",
        "كلمة المرور الجديدة وتأكيدها غير متطابقين",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    final appController = Get.find<AppController>();
    final apiService = ApiService();

    try {
      final user = await appController.ensureUserLoaded();
      if (appController.token.value.isEmpty || user == null || user.id <= 0) {
        Get.snackbar(
          "انتهت الجلسة",
          "يرجى تسجيل الدخول مرة أخرى",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final success = await apiService.changePassword(
        userId: user.id,
        oldPassword: oldPass,
        newPassword: newPass,
        token: appController.token.value,
      );

      if (success) {
        // Clear old password if stored locally (though we should avoid this)
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_password');

        Get.back();
        Get.snackbar(
          "نجاح",
          "تم تغيير كلمة المرور وتحديثها في الموقع بنجاح!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "فشل التغيير",
          "تأكد من صحة كلمة المرور الحالية أو حاول لاحقاً",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال بالخادم",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
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

  final ChangePasswordController controller = Get.put(
    ChangePasswordController(),
  );

  // ألوان هوية صخر
  static const Color kSakhrBlue = Color(0xFF015C92);
  static const Color kSakhrGold = Color(0xFFFFA931);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'تغيير كلمة المرور',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: kSakhrBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // خلفية منحنية في الأعلى
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: kSakhrBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // كارد البطاقة الرئيسي
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kSakhrGold.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.security_update_good_rounded,
                          size: 45,
                          color: kSakhrGold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "تحديث كلمة المرور",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kSakhrBlue,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "يرجى إدخال كلمة المرور الحالية ثم الجديدة للتحقق",
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 35),

                      // الحقول
                      Obx(
                        () => _buildPremiumField(
                          label: "كلمة المرور الحالية",
                          controller: controller.oldPasswordController,
                          isObscure: !controller.isOldPasswordVisible.value,
                          toggle: controller.toggleOldPasswordVisibility,
                          icon: Icons.lock_open_rounded,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Obx(
                        () => _buildPremiumField(
                          label: "كلمة المرور الجديدة",
                          controller: controller.newPasswordController,
                          isObscure: !controller.isNewPasswordVisible.value,
                          toggle: controller.toggleNewPasswordVisibility,
                          icon: Icons.lock_outline_rounded,
                          isNew: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Obx(
                        () => _buildPremiumField(
                          label: "تأكيد كلمة المرور",
                          controller: controller.confirmPasswordController,
                          isObscure: !controller.isConfirmPasswordVisible.value,
                          toggle: controller.toggleConfirmPasswordVisibility,
                          icon: Icons.lock_clock_rounded,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // زر التحديث
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSakhrBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: kSakhrBlue.withOpacity(0.3),
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "تحديث الآن",
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildSecurityTip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumField({
    required String label,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback toggle,
    required IconData icon,
    bool isNew = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: kSakhrBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isNew ? kSakhrGold.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: IconButton(
                icon: Icon(
                  isObscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: toggle,
              ),
              suffixIcon: Icon(
                icon,
                color: isNew ? kSakhrGold : kSakhrBlue,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTip() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kSakhrGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kSakhrGold.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: kSakhrGold, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "نصيحة: استخدم مزيجاً من الأحرف والأرقام لضمان أعلى مستوى من الحماية لحسابك.",
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: kSakhrBlue.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
