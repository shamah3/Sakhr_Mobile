import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/notification_service.dart';
import 'package:bytore/core/services/whatsapp_service.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/models/user_model.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bytore/features/checkout/views/address_page.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController appController = Get.find<AppController>();
  final LocalAuthentication auth = LocalAuthentication();

  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  final Map<String, String> _users = {"777777777": "123456"}.obs;

  // --- Login Logic ---
  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var obscurePassword = true.obs;

  // --- OTP & Auth Logic ---
  var currentOtp = RxnString();
  var isSendingOtp = false.obs;
  var resendCountdown = 0.obs;
  DateTime? _otpExpiry;
  Timer? _countdownTimer;

  Future<bool> sendOtp(String phoneNumber) async {
    isSendingOtp.value = true;
    phoneController.text = phoneNumber;
    appController.phoneNumber.value = phoneNumber;

    // 1. Send via API (Primary)
    String? fetchedCode = await _apiService.sendOtp(phoneNumber);
    bool success = fetchedCode != null;

    // 2. Fallback or parallel send via WhatsApp if needed (premium feature)
    if (success) {
      currentOtp.value = fetchedCode;
      _otpExpiry = DateTime.now().add(const Duration(minutes: 5));

      // Optional: Also send via WhatsApp for premium feel
      try {
        await WhatsAppService().sendOTP(phone: phoneNumber, otp: fetchedCode);
      } catch (e) {
        debugPrint("WhatsApp OTP delivery skipped: $e");
      }
    }

    isSendingOtp.value = false;
    if (success) {
      _startResendTimer();
      NotificationService().showNotification(
        id: 999,
        title: "كود التحقق",
        body: "كود التحقق الخاص بك هو: $fetchedCode (لأغراض التجربة)",
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

  Future<bool> verifyOTP(String enteredCode, {String? phoneNumber}) async {
    try {
      if (_otpExpiry != null && DateTime.now().isAfter(_otpExpiry!)) {
        currentOtp.value = null;
        _otpExpiry = null;
        return false;
      }

      final String resolvedPhone =
          (phoneNumber ?? phoneController.text).trim().isNotEmpty
          ? (phoneNumber ?? phoneController.text).trim()
          : appController.phoneNumber.value.trim();

      if (resolvedPhone.isEmpty) {
        return false;
      }

      final data = await _apiService.verifyOtp(resolvedPhone, enteredCode);
      final String? serverToken = data?['token']?.toString();

      if (serverToken != null && serverToken.isNotEmpty) {
        currentOtp.value = null;
        _otpExpiry = null;
        _countdownTimer?.cancel();
        resendCountdown.value = 0;
        phoneController.text = resolvedPhone;
        appController.phoneNumber.value = resolvedPhone;

        return _applyAuthenticatedSession(data!);
      }
    } catch (e) {
      debugPrint("Verify OTP Error: $e");
    }
    return false;
  }

  void updateLoginStatus(bool status) {
    isLoggedIn.value = status;
    appController.updateLoginStatus(
      status,
    ); // Use formal update method to ensure persistence
  }

  Future<bool> _applyAuthenticatedSession(Map<String, dynamic> data) async {
    final token = data['token']?.toString() ?? "";
    if (token.isEmpty) {
      return false;
    }

    appController.token.value = token;

    if (data.containsKey('user') && data['user'] is Map) {
      appController.user.value = UserModel.fromJson(
        Map<String, dynamic>.from(data['user']),
      );
      appController.isBiometricEnabled.value =
          appController.user.value?.hasBiometric ?? false;
      appController.updateUserName(
        appController.user.value!.firstName,
        appController.user.value!.lastName,
        phone: appController.user.value!.phone,
      );
    } else {
      await appController.loadUserProfile();
    }

    updateLoginStatus(true);
    await appController.persistSessionNow();
    return true;
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();

      if (phone.isEmpty || password.isEmpty) {
        Get.snackbar("تنبيه", "يرجى إدخال رقم الهاتف وكلمة المرور");
        return;
      }

      final data = await _apiService.login(phone, password);
      if (data != null && await _applyAuthenticatedSession(data)) {
        bool redirectToAddress = Get.arguments?['redirectToAddress'] ?? false;
        if (redirectToAddress) {
          Get.offAll(() => AddressPage());
        } else {
          Get.offAllNamed('/main');
        }
      } else {
        Get.snackbar("خطأ", "فشل تسجيل الدخول، تأكد من البيانات");
      }
    } catch (e) {
      debugPrint("Error in AuthController login: $e");
      Get.snackbar(
        "خطأ",
        _cleanError(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      await appController
          .clearSession(); // Clears memory and persistent storage
      updateLoginStatus(false);
      Get.offAllNamed('/login');
    }
  }

  Future<void> register() async {
    try {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (name.isEmpty ||
          phone.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty) {
        Get.snackbar("تنبيه", "يرجى ملء جميع الحقول المطلوبة");
        return;
      }

      if (password != confirmPassword) {
        Get.snackbar(
          "تنبيه",
          "كلمة المرور وتأكيدها غير متطابقين",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      // تقسيم الاسم
      final names = name.split(' ');
      final firstName = names.isNotEmpty ? names.first : 'مستخدم';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'جديد';

      final response = await _apiService.registerCustomer(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
      );

      if (response != null && await _applyAuthenticatedSession(response)) {
        Get.snackbar(
          "نجاح",
          "تم إنشاء الحساب وتسجيل الدخول بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        bool redirectToAddress = Get.arguments?['redirectToAddress'] ?? false;
        if (redirectToAddress) {
          Get.offAll(() => AddressPage());
        } else {
          Get.offAllNamed('/main');
        }
      } else if (response != null) {
        Get.snackbar(
          "نجاح",
          "تم إنشاء الحساب بنجاح، يمكنك الآن تسجيل الدخول",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar(
          "خطأ",
          "فشل إنشاء الحساب، قد يكون الرقم مسجلاً مسبقاً",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error in register: $e");
      Get.snackbar(
        "خطأ",
        _cleanError(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        Get.snackbar(
          "تنبيه",
          "جهازك لا يدعم المصادقة الحيوية",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 2. طلب المصادقة من المستخدم
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'يرجى تأكيد هويتك لتسجيل الدخول',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        isLoading.value = true;

        final prefs = await SharedPreferences.getInstance();
        String? bioToken = prefs.getString('device_biometric_token');
        if (bioToken == null || bioToken.isEmpty) {
          Get.snackbar(
            "تنبيه",
            "فعّل تسجيل الدخول بالبصمة من داخل الحساب أولاً",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }

        final data = await _apiService.biometricLogin(bioToken);

        if (data != null && await _applyAuthenticatedSession(data)) {
          Get.snackbar(
            "نجاح",
            "تم تسجيل الدخول بنجاح",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          bool redirectToAddress = Get.arguments?['redirectToAddress'] ?? false;
          if (redirectToAddress) {
            Get.offAll(() => AddressPage());
          } else {
            Get.offAllNamed('/main');
          }
        } else {
          Get.snackbar(
            "خطأ",
            "فشل التحقق من البصمة مع السيرفر",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint("🔥 Biometric Login Error: $e");
      Get.snackbar(
        "خطأ",
        _cleanError(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> enableBiometricForCurrentUser() async {
    try {
      final token = appController.token.value;
      final user = await appController.ensureUserLoaded();
      if (token.isEmpty || user == null || user.id <= 0) {
        Get.snackbar(
          "انتهت الجلسة",
          "يرجى تسجيل الدخول مرة أخرى قبل تفعيل البصمة",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }

      final canCheckBiometrics = await auth.canCheckBiometrics;
      final canAuthenticate =
          canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        Get.snackbar(
          "عذراً",
          "جهازك لا يدعم المصادقة الحيوية",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'يرجى تأكيد هويتك لتفعيل البصمة',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (!authenticated) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      String? bioToken = prefs.getString('device_biometric_token');
      if (bioToken == null || bioToken.isEmpty) {
        bioToken =
            "bio_${Random().nextInt(1000000)}_${DateTime.now().millisecondsSinceEpoch}";
        await prefs.setString('device_biometric_token', bioToken);
      }

      final success = await _apiService.enableBiometric(
        biometricToken: bioToken,
        token: token,
      );

      if (success) {
        appController.isBiometricEnabled.value = true;
        if (appController.user.value != null) {
          final currentUser = appController.user.value!;
          appController.user.value = UserModel(
            id: currentUser.id,
            firstName: currentUser.firstName,
            lastName: currentUser.lastName,
            email: currentUser.email,
            phone: currentUser.phone,
            profilePhotoUrl: currentUser.profilePhotoUrl,
            hasBiometric: true,
          );
        }
        await appController.persistSessionNow();
        Get.snackbar(
          "نجاح",
          "تم تفعيل الدخول بالبصمة بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
    } catch (e) {
      debugPrint("Enable Biometric Error: $e");
      Get.snackbar(
        "خطأ",
        _cleanError(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    return false;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst("Exception: ", "");
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
