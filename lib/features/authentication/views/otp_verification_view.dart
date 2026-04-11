import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/checkout/views/address_page.dart';
import 'package:bytore/features/home/views/home_view.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationView extends GetView<AuthController> {
  final String phoneNumber;
  final bool redirectToAddress;

  OtpVerificationView({
    super.key, 
    required this.phoneNumber, 
    this.redirectToAddress = false
  });

  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final RxString _errorMessage = "".obs;
  final RxBool _isLoading = false.obs;

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _isLoading.value = true;
      _errorMessage.value = "";
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      bool isValid = await controller.verifyOTP(otp);
      _isLoading.value = false;

      if (isValid) {
        Get.snackbar("تم بنجاح", "تم التحقق بنجاح!", backgroundColor: Colors.green, colorText: Colors.white);
        
        if (redirectToAddress) {
          Get.offAll(() => const AddressPage());
        } else {
          Get.offAllNamed('/main'); // Navigate to main (which contains Home)
        }
      } else {
        _errorMessage.value = "الرمز المدخل غير صحيح";
        Get.snackbar("خطأ", "الرمز غير صحيح", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      _errorMessage.value = "يرجى ادخال ٦ أرقام";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGradientHeader(context),

            const SizedBox(height: 30),

            // Main Verification Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(30),
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
              child: Column(
                children: [
                  const Icon(Icons.lock_person_rounded, size: 50, color: kPrimaryColor),
                  const SizedBox(height: 20),
                  Text(
                    "أدخل رمز التحقق (OTP)",
                    style: GoogleFonts.cairo(color: kTextColor, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.cairo(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
                      children: [
                        const TextSpan(text: "تم إرسال رمز التحقق إلى رقمك \n"),
                        TextSpan(
                          text: phoneNumber,
                          style: const TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: " عبر الواتساب"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 6 Box OTP Input
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 42,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _errorMessage.value.isNotEmpty ? Colors.red.withOpacity(0.3) : kPrimaryColor.withOpacity(0.1)
                            ),
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kTextColor),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                              if (_controllers.every((c) => c.text.isNotEmpty)) {
                                _verifyOtp();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ),

                  Obx(() => _errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(_errorMessage.value, style: GoogleFonts.cairo(color: Colors.red, fontSize: 12)),
                      )
                    : const SizedBox.shrink()),

                  const SizedBox(height: 35),

                  // Resend logic
                  Obx(() => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "00:${controller.resendCountdown.value.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 16, color: kTextColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: controller.resendCountdown.value == 0 ? () {
                          controller.sendOtp(phoneNumber);
                        } : null,
                        child: Text(
                          "لم يصلك الرمز؟ إعادة الارسال",
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: controller.resendCountdown.value == 0 ? kPrimaryColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )),

                  const SizedBox(height: 25),

                  _buildConfirmButton(),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Get.back(),
              child: Text("تغيير رقم الجوال؟", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14)),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() => ElevatedButton(
        onPressed: _isLoading.value ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading.value 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                "تحقق الآن",
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      )),
    );
  }

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, Color(0xFF00568C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            Center(
              child: Text(
                "تأكيد الرمز",
                style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
