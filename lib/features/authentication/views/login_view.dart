import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import '../controllers/auth_controller.dart';
import 'otp_verification_view.dart';
import 'package:bytore/core/components/custom_image.dart';

class LoginView extends GetView<AuthController> {
  final bool redirectToAddress;
  LoginView({super.key, this.redirectToAddress = false});

  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? v) => (v == null || !v.contains('@')) ? 'البريد الإلكتروني غير صحيح' : null;
  String? _validatePass(String? v) => (v == null || v.length < 6) ? 'كلمة المرور قصيرة' : null;

  @override
  Widget build(BuildContext context) {
    // التأكد من تسجيل المتحكم في الذاكرة لتجنب الشاشة الحمراء
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
            icon: const Icon(Icons.arrow_back_ios, color: kTextColor),
            onPressed: () => Get.back())
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor.withOpacity(0.1), width: 1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.login_rounded, size: 50, color: kPrimaryColor),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: kSecondaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.security, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "بايتور",
                style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1),
              ),
              const Text(
                "تسجيل الدخول للمتابعة",
                style: TextStyle(color: kTextLightColor, fontSize: 16),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
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
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kTextColor)),
                      const SizedBox(height: 35),

                      // حقل البريد الإلكتروني
                      _buildEmailField(authController),

                      const SizedBox(height: 20),

                      // حقل كلمة المرور (مع Obx لمراقبة إظهار/إخفاء النص)
                      _buildPasswordField(authController),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("نسيت كلمة المرور؟",
                              style: TextStyle(color: kTextLightColor, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildMainButton(context, authController),

                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("أو المتابعة عبر",
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 13)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildSocialLoginSection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // دالة حقل البريد الإلكتروني
  Widget _buildEmailField(AuthController authController) {
    return Container(
      decoration: BoxDecoration(
        color: kBgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: authController.emailController,
        textAlign: TextAlign.right,
        keyboardType: TextInputType.emailAddress,
        validator: _validateEmail,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        decoration: InputDecoration(
          hintText: "البريد الإلكتروني",
          hintStyle: const TextStyle(
              color: kTextLightColor, fontSize: 14, fontWeight: FontWeight.normal),
          prefixIcon: const Icon(Icons.email_outlined, color: kPrimaryColor, size: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  // دالة حقل كلمة المرور (تحتوي على Obx لأنها تراقب حالة الرؤية)
  Widget _buildPasswordField(AuthController authController) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: kBgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: authController.passwordController,
        textAlign: TextAlign.right,
        obscureText: authController.obscurePassword.value,
        validator: _validatePass,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        decoration: InputDecoration(
          hintText: "كلمة المرور",
          hintStyle: const TextStyle(
              color: kTextLightColor, fontSize: 14, fontWeight: FontWeight.normal),
          prefixIcon: const Icon(Icons.lock_open_rounded, color: kPrimaryColor, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
                authController.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey,
                size: 20),
            onPressed: authController.togglePasswordVisibility,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    ));
  }

  Widget _buildMainButton(BuildContext context, AuthController authController) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() => ElevatedButton(
        onPressed: authController.isLoading.value
            ? null
            : () async {
          if (_formKey.currentState!.validate()) {
            await authController.login();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: authController.isLoading.value
            ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("تسجيل الدخول",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      )),
    );
  }

  Widget _buildSocialLoginSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialCircleParam(Icons.apple, Colors.black, () {}),
        const SizedBox(width: 25),
        _socialCircleParam(Icons.g_mobiledata, Colors.red, () {},
            isImage: true,
            imgUrl: 'https://cdn-icons-png.flaticon.com/512/300/300221.png'),
      ],
    );
  }

  Widget _socialCircleParam(IconData icon, Color color, VoidCallback onTap,
      {bool isImage = false, String? imgUrl}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: isImage && imgUrl != null
              ? CustomImage(imageUrl: imgUrl, width: 28, height: 28)
              : Icon(icon, color: color, size: 30),
        ),
      ),
    );
  }
}