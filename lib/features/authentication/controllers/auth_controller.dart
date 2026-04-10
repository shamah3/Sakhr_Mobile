import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/notification_service.dart';
import 'package:bytore/core/services/whatsapp_service.dart';
import 'package:bytore/core/services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController appController = Get.find<AppController>();

  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  final Map<String, String> _users = {"777777777": "123456"}.obs;

  // --- Login Logic ---
  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var obscurePassword = true.obs;

  // --- OTP & Auth Logic ---
  var currentOtp = RxnString();
  var isSendingOtp = false.obs;
  var resendCountdown = 0.obs;
  DateTime? _otpExpiry;
  Timer? _countdownTimer;

  Future<bool> sendOtp(String phoneNumber) async {
    isSendingOtp.value = true;
    
    final random = Random();
    currentOtp.value = (100000 + random.nextInt(900000)).toString();
    _otpExpiry = DateTime.now().add(const Duration(minutes: 5)); 
    
    final success = await WhatsAppService().sendOTP(phone: phoneNumber, otp: currentOtp.value!);

    isSendingOtp.value = false;
    if (success) {
      _startResendTimer();
      NotificationService().showNotification(
        id: 999,
        title: "واتساب (تجربة)",
        body: "رمز التحقق الخاص بك هو: ${currentOtp.value}",
      );
    }
    return success;
  }

  void _startResendTimer() {
    resendCountdown.value = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  bool verifyOTP(String enteredCode) {
    if (currentOtp.value != null && _otpExpiry != null && DateTime.now().isAfter(_otpExpiry!)) {
      currentOtp.value = null;
      _otpExpiry = null;
      return false;
    }

    if (currentOtp.value != null && currentOtp.value == enteredCode) {
      currentOtp.value = null;
      _otpExpiry = null;
      _countdownTimer?.cancel();
      resendCountdown.value = 0;
      updateLoginStatus(true);
      return true;
    }
    return false;
  }

  void updateLoginStatus(bool status) {
    isLoggedIn.value = status;
    appController.updateLoginStatus(status); // Use formal update method to ensure persistence
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar("تنبيه", "يرجى إدخال البريد الإلكتروني وكلمة المرور");
        return;
      }

      final data = await _apiService.login(email, password);
      if (data != null && data.containsKey('token')) {
        final token = data['token'];
        appController.token.value = token;
        updateLoginStatus(true);
        Get.offAllNamed('/main'); 
      } else {
        Get.snackbar("خطأ", "فشل تسجيل الدخول، تأكد من البيانات");
      }
    } catch (e) {
      debugPrint("Error in AuthController login: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final token = appController.token.value;
      if (token.isNotEmpty) {
        await _apiService.logout(token);
      }
    } catch (e) {
      debugPrint("Error in AuthController logout: $e");
    } finally {
      await appController.clearSession(); // Clears memory and persistent storage
      updateLoginStatus(false);
      Get.offAllNamed('/login');
    }
  }

  void registerUser(String phone, String password) {
    _users[phone] = password;
  }

  bool validateUser() {
    final phone = phoneController.text;
    final password = passwordController.text;
    return _users.containsKey(phone) && _users[phone] == password;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signInWithGoogle() async {
    Get.snackbar("معلومة", "تم النقر على تسجيل الدخول بجوجل (قيد التطوير)");
  }

  Future<void> performBiometricLogin() async {
    Get.snackbar("معلومة", "تم النقر على تسجيل الدخول بالبصمة (قيد التطوير)");
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
