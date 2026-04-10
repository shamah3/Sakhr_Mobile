import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import '../controllers/auth_controller.dart';
import 'otp_verification_view.dart';
import 'SignUpView.dart';

class LoginView extends GetView<AuthController> {
  final bool redirectToAddress;
  LoginView({super.key, this.redirectToAddress = false});

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    final authController = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // خلفية رمادية فاتحة جداً مثل الصورة
      body: SingleChildScrollView(
        child: Column(
          children: [
// 1. الهيدر البنفسجي/الأزرق المنحني كما في الصورة
            _buildImageHeader(),

            const SizedBox(height: 40),

// 2. النصوص التوضيحية (نفس المسافات في الصورة)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Text(
                    "خطوة واحدة للانضمام لى عائلة صخر !",
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "سجل دخولك أو أنشئ حسابًا جديدًا للبدء في التسوق بكل سهولة.",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

// 3. المربع الأبيض (Card) - نفس أبعاد وحواف الصورة
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // حواف ناعمة مثل الصورة
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "أدخل رقم جوالك للمتابعة",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),

// حقل الجوال - مطابق للصورة بملي
                    _buildPhoneFieldLayout(),

                    const SizedBox(height: 20),

// زر تسجيل الدخول (نفس الحجم واللون في الصورة)
                    _buildSubmitButton(authController),

                    const SizedBox(height: 20),

                    Text(
                      "أو قم بالتسجيل عبر",
                      style: GoogleFonts.cairo(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 15),
                    // أيقونة جوجل والبصمة التفاعلية
                    _buildSocialAndBiometricLogin(authController),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

// رابط إنشاء الحساب
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

// تصميم الهيدر (نفس انحناء الصورة)
  Widget _buildImageHeader() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, Color(0xFF4A90E2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "مرحباً بك في صخر",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            const Text("👋", style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

// حقل رقم الجوال (المربع المقسم كما في الصورة)
  Widget _buildPhoneFieldLayout() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
// كود الدولة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "967+ |",
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
// حقل الكتابة
          Expanded(
            child: TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "رقم الجوال",
                hintStyle: GoogleFonts.cairo(color: Colors.grey.shade300, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

// زر تسجيل الدخول
  Widget _buildSubmitButton(AuthController authController) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Obx(() => ElevatedButton(
        onPressed: () {
          if (authController.phoneController.text.isNotEmpty) {
            authController.sendOtp(authController.phoneController.text);
            Get.to(() => OtpVerificationView(phoneNumber: authController.phoneController.text));
          } else {
            Get.snackbar("تنبيه", "يرجى إدخال رقم الجوال");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: authController.isSendingOtp.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          "تسجيل الدخول",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      )),
    );
  }
  // أيقونة جوجل والبصمة
  Widget _buildSocialAndBiometricLogin(AuthController authController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => authController.signInWithGoogle(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.google,
              color: Colors.red,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 20),
        InkWell(
          onTap: () => authController.performBiometricLogin(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fingerprint,
              size: 28,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return TextButton(
      onPressed: () => Get.to(() => const SignUpView()),
      child: const Text(
        "ليس لديك حساب؟ سجل الآن",
        style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: 'Cairo'
        ),
      ),
    );
  }
}