import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bytore/features/authentication/controllers/auth_controller.dart';
import 'package:bytore/core/routes/app_routes.dart';

class PhoneVerificationView extends GetView<AuthController> {
  final bool redirectToAddress;
  const PhoneVerificationView({super.key, this.redirectToAddress = false});

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
              // Enhanced WhatsApp/Phone Icon
               Container(
                 padding: const EdgeInsets.all(22),
                 decoration: BoxDecoration(
                   color: const Color(0xFF25D366).withOpacity(0.05),
                   shape: BoxShape.circle,
                   border: Border.all(color: const Color(0xFF25D366).withOpacity(0.1), width: 1),
                 ),
                 child: Stack(
                   alignment: Alignment.center,
                   children: [
                     const Icon(FontAwesomeIcons.whatsapp, size: 55, color: Color(0xFF25D366)),
                     Positioned(
                       bottom: 0,
                       right: 0,
                       child: Container(
                         padding: const EdgeInsets.all(4),
                         decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
                         child: const Icon(Icons.verified_user_rounded, size: 14, color: Colors.white),
                       ),
                     ),
                   ],
                 ),
               ),
              const SizedBox(height: 30),
              const Text(
                "توثيق الحساب",
                style: TextStyle(color: kTextColor, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "يرجى إدخال رقم هاتفك لإرسال كود التحقق عبر الواتساب",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextLightColor, fontSize: 15, height: 1.4),
                ),
              ),
              const SizedBox(height: 50),
              
              // Floating Input Card
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: kBgColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.right, // RTL
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2),
                        decoration: InputDecoration(
                          hintText: "7xxxxxxxx",
                          hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 1),
                          labelText: "رقم الهاتف",
                          labelStyle: const TextStyle(color: kTextLightColor, fontSize: 14, fontWeight: FontWeight.normal),
                          prefixIcon: const Icon(Icons.phone_android_rounded, color: kPrimaryColor),
                          suffixIcon: Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: const Text("967+ ", style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: 16)),
                          ),
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    
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
                        onPressed: controller.isSendingOtp.value ? null : () async {
                          if (controller.phoneController.text.length < 9) {
                            Get.snackbar("تنبيه", "يرجى إدخال رقم هاتف صحيح");
                            return;
                          }
                          
                          bool success = await controller.sendOtp(controller.phoneController.text);
                          
                          if (success) {
                            Get.toNamed(AppRoutes.OTP, arguments: {
                              'phoneNumber': controller.phoneController.text,
                              'redirectToAddress': redirectToAddress,
                            });
                          } else {
                            Get.snackbar("خطأ", "فشل إرسال الرمز");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: controller.isSendingOtp.value 
                             ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                             : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mark_email_read_rounded, size: 20),
                            SizedBox(width: 12),
                            Text(
                              "إرسال كود التحقق",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "* قد تستغرق عملية إرسال الكود عدة ثوانٍ",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
