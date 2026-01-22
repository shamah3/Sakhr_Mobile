import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      
      bool isValid = controller.verifyOTP(otp);
      _isLoading.value = false;

      if (isValid) {
        Get.snackbar("تم بنجاح", "تم التحقق بنجاح!", backgroundColor: Colors.green, colorText: Colors.white);
        
        if (redirectToAddress) {
          Get.offAll(() => const AddressPage());
        } else {
          // If we are in a nested navigator, we might need to handle this differently
          // For now, offAll is safer to reset the stack
          Get.offAllNamed('/'); // Navigate to home
        }
      } else {
        _errorMessage.value = "الرمز المدخل غير صحيح";
        Get.snackbar("خطأ", "الرمز غير صحيح", backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 30),
               Container(
                 padding: const EdgeInsets.all(22),
                 decoration: BoxDecoration(
                   color: kPrimaryColor.withOpacity(0.05),
                   shape: BoxShape.circle,
                   border: Border.all(color: kPrimaryColor.withOpacity(0.1), width: 1),
                 ),
                 child: Stack(
                   alignment: Alignment.center,
                   children: [
                     const Icon(Icons.lock_person_rounded, size: 55, color: kPrimaryColor),
                     Positioned(
                       top: 0,
                       right: 0,
                       child: Container(
                         padding: const EdgeInsets.all(4),
                         decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle),
                         child: const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
                       ),
                     ),
                   ],
                 ),
               ),
              const SizedBox(height: 30),
              const Text(
                "رمز التحقق",
                style: TextStyle(color: kTextColor, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: kTextLightColor, fontSize: 15, height: 1.4, fontFamily: 'Cairo'),
                    children: [
                      const TextSpan(text: "تم إرسال رمز التحقق المكون من 6 أرقام إلى رقم واتساب الخاص بك "),
                      TextSpan(
                        text: phoneNumber,
                        style: const TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 45,
                            height: 60,
                            decoration: BoxDecoration(
                              color: kBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _errorMessage.value.isNotEmpty ? Colors.red.withOpacity(0.3) : Colors.transparent
                              ),
                            ),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kPrimaryColor),
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
                          child: Text(_errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        )
                      : const SizedBox.shrink()),
                    const SizedBox(height: 40),
                    Obx(() => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_rounded, size: 16, color: kSecondaryColor),
                            const SizedBox(width: 8),
                            Text(
                              "00:${controller.resendCountdown.value.toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 18, color: kSecondaryColor, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: controller.resendCountdown.value == 0 ? () {
                            controller.sendOtp(phoneNumber);
                          } : null,
                          child: Text(
                            "إعادة إرسال الرمز؟",
                            style: TextStyle(
                              color: controller.resendCountdown.value == 0 ? kPrimaryColor : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(height: 25),
                    Container(
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
                        onPressed: _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: _isLoading.value 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text(
                                "تحقق الآن",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
