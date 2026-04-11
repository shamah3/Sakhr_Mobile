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
    // Ensure controller is registered
    if (!Get.isRegistered<AuthController>()) Get.put(AuthController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPremiumHeader(),
            
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Text(
                    "خطوة واحدة للانضمام لعائلة صخر !",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
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

            const SizedBox(height: 30),

            // Login Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
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
                    Text(
                      "أدخل رقم جوالك للمتابعة",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildPhoneFieldLayout(),

                    const SizedBox(height: 25),

                    _buildSubmitButton(),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade200)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("أو المتابعة عبر", 
                            style: GoogleFonts.cairo(color: Colors.grey.shade500, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade200)),
                      ],
                    ),

                    const SizedBox(height: 20),
                    
                    _buildSocialAndBiometricLogin(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            _buildBottomAction(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, Color(0xFF00568C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.login_rounded, size: 35, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Text(
              "بايتور صخر",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneFieldLayout() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "967+ |",
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "رقم الجوال",
                hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value || controller.isSendingOtp.value
            ? null
            : () async {
          if (controller.phoneController.text.isNotEmpty) {
            final phone = controller.phoneController.text.trim();
            final success = await controller.sendOtp(phone);
            if (success) {
              Get.to(() => OtpVerificationView(phoneNumber: phone, redirectToAddress: redirectToAddress));
            } else {
              Get.snackbar("خطأ", "هناك مشكلة في ارسال الكود", backgroundColor: Colors.red, colorText: Colors.white);
            }
          } else {
            Get.snackbar("تنبيه", "يرجى إدخال رقم الجوال", backgroundColor: Colors.orange, colorText: Colors.white);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: controller.isLoading.value || controller.isSendingOtp.value
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
          "تسجيل الدخول",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      )),
    );
  }

  Widget _buildSocialAndBiometricLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(FontAwesomeIcons.google, Colors.red, () => controller.signInWithGoogle()),
        const SizedBox(width: 25),
        _socialButton(Icons.fingerprint, kPrimaryColor, () => controller.performBiometricLogin()),
      ],
    );
  }

  Widget _socialButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildBottomAction() {
    return TextButton(
      onPressed: () => Get.to(() => const SignUpView()),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
          children: const [
            TextSpan(text: "ليس لديك حساب؟ "),
            TextSpan(
              text: "سجل الآن",
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}