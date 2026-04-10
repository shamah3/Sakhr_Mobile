import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/checkout/views/address_page.dart';
import 'package:bytore/features/home/views/home_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationView extends GetView<AuthController> {
  final String phoneNumber;
  final bool redirectToAddress;

  OtpVerificationView({
    super.key,
    required this.phoneNumber,
    this.redirectToAddress = false
  });

  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  final RxString _errorMessage = "".obs;
  final RxBool _isLoading = false.obs;

  Future<void> _verifyOtp() async {
    String otp = _otpController.text;
    if (otp.length == 6) { // Changed to 6 digits to match generated OTP
      _isLoading.value = true;
      _errorMessage.value = "";

      await Future.delayed(const Duration(milliseconds: 800));

      // We assume controller.verifyOTP works with what we pass it
      bool isValid = controller.verifyOTP(otp);
      _isLoading.value = false;

      if (isValid) {
        Get.snackbar("تم بنجاح", "تم التحقق بنجاح!", backgroundColor: Colors.green, colorText: Colors.white);

        if (redirectToAddress) {
          Get.offAll(() => const AddressPage());
        } else {
          Get.offAllNamed('/'); // Navigate to home
        }
      } else {
        _errorMessage.value = "الرمز المدخل غير صحيح";
        Get.snackbar("خطأ", "الرمز غير صحيح", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      _errorMessage.value = "يرجى ادخال ٦ ارقام";
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

            // White Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
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
                  const Text(
                    "ادخل رمز التحقق",
                    style: TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5, fontFamily: 'Cairo'),
                      children: [
                        const TextSpan(text: "ادخل الرمز الذي تم ارساله الي رقمك "),
                        TextSpan(
                          text: phoneNumber,
                          style: const TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontFamily: 'sans-serif'),
                        ),
                        const TextSpan(text: "\nعبر "),
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.circle, color: Colors.green, size: 12), // Green dot for WhatsApp
                        ),
                        const TextSpan(text: " الواتس اب"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // OTP Single Box
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Obx(() => Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _errorMessage.value.isNotEmpty ? Colors.red.withOpacity(0.5) : kPrimaryColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(fontSize: 28, letterSpacing: 15, fontWeight: FontWeight.bold, color: kTextColor, fontFamily: 'sans-serif'),
                          decoration: const InputDecoration(
                            hintText: "------",
                            hintStyle: TextStyle(letterSpacing: 15),
                            counterText: "",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            if (value.length == 6) {
                              _otpFocusNode.unfocus();
                              // Auto verify
                              _verifyOtp();
                            }
                          },
                        ),
                      ),
                    )),
                  ),

                  Obx(() => _errorMessage.value.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(_errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 13, fontFamily: 'Cairo')),
                  )
                      : const SizedBox.shrink()),

                  const SizedBox(height: 30),

                  // Countdown Timer
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: controller.resendCountdown.value == 0 ? () {
                          controller.sendOtp(phoneNumber);
                        } : null,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "إعادة الارسال؟",
                          style: TextStyle(
                              color: controller.resendCountdown.value == 0 ? kPrimaryColor : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              fontSize: 15
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "00:${controller.resendCountdown.value.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontFamily: 'sans-serif'),
                      ),
                    ],
                  )),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Confirm Button (Outside Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                    "تأكيد",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
                  ),
                )),
              ),
            ),

            const SizedBox(height: 20),

            // Resend Phone Number
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("اعاده ادخال رقم الجوال", style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Cairo')),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, Color(0xFF4A90E2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              Center(
                child: Text(
                  "ادخال رمز الدخول",
                  style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
