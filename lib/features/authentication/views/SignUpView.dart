import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import '../controllers/auth_controller.dart';

class SignUpView extends GetView<AuthController> {
  final bool redirectToAddress;
  const SignUpView({super.key, this.redirectToAddress = false});

  static const Color kSakhrBlue = Color(0xFF015C92);
  static const Color kSakhrGold = Color(0xFFFFA931);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // الهيدر المصغر الخاص بـ "صخر" مع زر العودة
            _buildSmallHeader(context),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Text(
                    "إنشاء حساب جديد",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "انضم إلى عائلة صخر واستمتع بأفضل الخدمات",
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // حقول البيانات
                  _buildTextField(
                    hint: "الاسم الكامل",
                    icon: Icons.person_outline_rounded,
                    controller: controller.nameController,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: "رقم الهاتف",
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    controller: controller.phoneController,
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    "كلمة المرور",
                    controller.passwordController,
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    "تأكيد كلمة المرور",
                    controller.confirmPasswordController,
                  ),

                  const SizedBox(height: 30),

                  // زر التسجيل الرئيسي
                  _buildRegisterButton(),

                  const SizedBox(height: 25),

                  // العودة لتسجيل الدخول
                  _buildLoginPrompt(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160, // أصغر قليلاً من صفحة الدخول
      decoration: const BoxDecoration(
        color: kSakhrBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_rounded,
                    size: 35,
                    color: kSakhrGold,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "SAKHR | صخر",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.register(),
          style: ElevatedButton.styleFrom(
            backgroundColor: kSakhrBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "تسجيل حساب جديد",
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
  }) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        style: GoogleFonts.cairo(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: kSakhrBlue.withOpacity(0.5), size: 20),
          filled: true,
          fillColor: kBgColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kSakhrGold, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String hint,
    TextEditingController textController,
  ) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: textController,
        textAlign: TextAlign.right,
        obscureText: true,
        style: GoogleFonts.cairo(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: kSakhrBlue.withOpacity(0.5),
            size: 20,
          ),
          suffixIcon: Icon(
            Icons.visibility_off_outlined,
            size: 18,
            color: Colors.grey.shade400,
          ),
          filled: true,
          fillColor: kBgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "لديك حساب بالفعل؟",
          style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            "سجل دخولك",
            style: GoogleFonts.cairo(
              color: kSakhrGold,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
