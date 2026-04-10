import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import '../controllers/auth_controller.dart';
import 'otp_verification_view.dart';
import 'package:bytore/core/components/custom_image.dart';
import 'package:bytore/core/components/bytore_logo.dart';

class LoginView extends GetView<AuthController> {
  final bool redirectToAddress;
  LoginView({super.key, this.redirectToAddress = false});

  final _formKey = GlobalKey<FormState>();

  String? _validatePhone(String? v) => (v == null || v.length < 8) ? 'رقم الهاتف غير صحيح' : null;
  String? _validatePass(String? v) => (v == null || v.length < 6) ? 'كلمة المرور قصيرة' : null;

  @override
  Widget build(BuildContext context) {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: kTextColor, size: 20),
            onPressed: () => Get.back())
            : const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Top Icon from screenshot
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: kBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.login_rounded, size: 35, color: kPrimaryColor),
                    Positioned(
                      bottom: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.shield_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "بايتور",
                style: TextStyle(color: kPrimaryColor, fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                "تسجيل الدخول للمتابعة",
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("مرحباً بك مجدداً",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextColor)),
                      const SizedBox(height: 30),

                      _buildPhoneField(authController),

                      const SizedBox(height: 15),

                      _buildPasswordField(authController),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                          child: const Text("نسيت كلمة المرور؟",
                              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildMainButton(context, authController),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("أو المتابعة عبر", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ],
              ),
              const SizedBox(height: 25),
              _buildSocialLoginSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(AuthController authController) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: authController.emailController, // Using same controller to store data temporarily
        textAlign: TextAlign.right,
        keyboardType: TextInputType.phone,
        validator: _validatePhone,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        decoration: InputDecoration(
          hintText: "رقم الهاتف",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
          prefixIcon: const Icon(Icons.phone_android_rounded, color: kPrimaryColor, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField(AuthController authController) {
    return Obx(() => Container(
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: authController.passwordController,
        textAlign: TextAlign.right,
        obscureText: authController.obscurePassword.value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        decoration: InputDecoration(
          hintText: "كلمة المرور",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
          prefixIcon: const Icon(Icons.lock_outline_rounded, color: kPrimaryColor, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
                authController.obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey, size: 20),
            onPressed: authController.togglePasswordVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        ),
      ),
    ));
  }

  Widget _buildMainButton(BuildContext context, AuthController authController) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Obx(() => ElevatedButton(
        onPressed: authController.isLoading.value
            ? null
            : () async {
          if (_formKey.currentState!.validate()) {
            final phone = authController.emailController.text.trim();
            // In API V1, we send OTP for login
            final success = await authController.sendOtp(phone);
            if (success) {
              Get.to(() => OtpVerificationView(phoneNumber: phone, redirectToAddress: redirectToAddress));
            } else {
              Get.snackbar("خطأ", "هناك مشكلة في ارسال الكود", snackPosition: SnackPosition.BOTTOM);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00568C), // Match exact solid blue from image
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: authController.isLoading.value
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("إرسال رمز التحقق", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      )),
    );
  }

  Widget _buildSocialLoginSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialCircleParam(Icons.apple, Colors.black, () {}),
        const SizedBox(width: 20),
        _socialCircleParam(Icons.g_mobiledata, Colors.black, () {},
            isImage: true, imgUrl: 'https://cdn-icons-png.flaticon.com/512/300/300221.png'), // Replace with actual G logo if available
      ],
    );
  }

  Widget _socialCircleParam(IconData icon, Color color, VoidCallback onTap, {bool isImage = false, String? imgUrl}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 55, height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: isImage && imgUrl != null
              ? const Icon(Icons.circle_outlined, color: Colors.blue) // Placeholder for G
              : Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}