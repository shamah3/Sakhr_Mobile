import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/notification_service.dart';
import 'package:bytore/core/services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController appController = Get.find<AppController>();

  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  final RxMap<String, String> _users = <String, String>{"777777777": "123456"}.obs;

  // --- Login Logic ---
  var emailController = TextEditingController();
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
    
    // إرسال كود التحقق عبر الـ API
    final success = await _apiService.sendOtp(phoneNumber);
    
    if (success) {
      // For local testing logic without limits, you might still set currentOtp manually.
      // But ideally the user gets it via SMS.
      currentOtp.value = "123456"; // Keep for dev testing
      _otpExpiry = DateTime.now().add(const Duration(minutes: 5)); 
    }
    
    isSendingOtp.value = false;
    if (success) {
      _startResendTimer();
      NotificationService().showNotification(
        id: 999,
        title: "كود التحقق",
        body: "تم الإرسال بنجاح (الكود التجريبي: 123456)",
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

  Future<bool> verifyOTP(String enteredCode) async {
    if (_otpExpiry != null && DateTime.now().isAfter(_otpExpiry!)) {
      currentOtp.value = null;
      _otpExpiry = null;
      return false;
    }

    final String phoneNumber = phoneController.text.trim();
    // التحقق عبر الـ API
    final token = await _apiService.verifyOtp(phoneNumber, enteredCode);

    if (token != null || (currentOtp.value != null && currentOtp.value == enteredCode)) {
      currentOtp.value = null;
      _otpExpiry = null;
      _countdownTimer?.cancel();
      resendCountdown.value = 0;
      appController.token.value = token ?? "mock_local_token_123456";
      updateLoginStatus(true);
      return true;
    }
    return false;
  }

  void updateLoginStatus(bool status) {
    isLoggedIn.value = status;
    appController.isLoggedIn.value = status; // Sync with AppController for global state
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

      // محاكاة تسجيل الدخول محلياً لأن الدليل لا يحتوي على login بالبريد الإلكتروني 
      // الدليل يحتوي على إرسال OTP والتحقق منه وتسجيل حساب جديد.
      await Future.delayed(const Duration(seconds: 1)); 
      
      appController.token.value = "mock_local_token_123456";
      updateLoginStatus(true);
      Get.offAllNamed('/checkout-address'); 
      
    } catch (e) {
      debugPrint("Error in AuthController login: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      if (appController.token.value.isNotEmpty) {
        await _apiService.logout(appController.token.value);
      }
    } catch (e) {
      debugPrint("Error in AuthController logout: $e");
    } finally {
      appController.token.value = "";
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

  @override
  void onClose() {
    _countdownTimer?.cancel();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
