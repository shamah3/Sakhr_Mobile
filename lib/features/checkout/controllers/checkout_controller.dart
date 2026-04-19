import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/core/routes/app_routes.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/checkout/models/floosak_payment_attempt_model.dart';
import 'package:bytore/features/checkout/models/payment_method_model.dart';
import 'package:bytore/features/checkout/views/success_page.dart';
import 'package:bytore/features/notifications/controllers/notification_controller.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/core/models/user_model.dart';

class CheckoutController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();
  final CartController cartController = Get.find<CartController>();
  final LocalAuthentication auth = LocalAuthentication();
  final Set<int> _finalizedOrderIds = <int>{};

  // Addressing
  var selectedAddressIndex = 0.obs;
  var addresses = <Map<String, String>>[
    {
      'title': 'المنزل (صنعاء)',
      'name': 'محمد الكبسي',
      'phone': '777123456',
      'address': 'حي حدة، خلف مركز الكميم، عمارة رقم 10',
      'city': 'صنعاء، اليمن',
    },
    {
      'title': 'العمل (عدن)',
      'name': 'محمد الكبسي',
      'phone': '733987654',
      'address': 'خور مكسر، حي السفارات، مبنى الشروق',
      'city': 'عدن، اليمن',
    },
  ].obs;

  // Payment
  var selectedMethodIndex = 0.obs;
  var paymentMethods = <PaymentMethodModel>[].obs;
  var isLoadingMethods = false.obs;
  var selectedWallet = RxnString();

  final walletPhoneController = TextEditingController();
  final couponController = TextEditingController();
  final floosakOtpController = TextEditingController();

  var isCouponApplied = false.obs;
  var couponStatus = "".obs;
  var isCompletingOrder = false.obs;
  var wallets = ["محفظة كاش", "كريمي موني", "جوال"].obs;

  OrderModel? _pendingFloosakOrder;
  Timer? _floosakPollTimer;
  final activeFloosakOrder = Rxn<OrderModel>();
  final activeFloosakAttempt = Rxn<FloosakPaymentAttemptModel>();
  final floosakErrorMessage = RxnString();
  final floosakStatusMessage = RxnString();
  final isConfirmingFloosak = false.obs;
  final isPollingFloosak = false.obs;
  final isFloosakPollInFlight = false.obs;

  PaymentMethodModel? get selectedPaymentMethod {
    if (paymentMethods.isEmpty) return null;

    final index = selectedMethodIndex.value;
    if (index < 0 || index >= paymentMethods.length) {
      return paymentMethods.first;
    }

    return paymentMethods[index];
  }

  bool get isFloosakSelected => selectedPaymentMethod?.id == 'floosak_wallet';

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
  }

  Future<void> loadPaymentMethods() async {
    try {
      isLoadingMethods.value = true;
      final methods = await _apiService.fetchPaymentMethods();
      paymentMethods.assignAll(
        methods.isNotEmpty ? methods : _fallbackPaymentMethods(),
      );
      _normalizeSelectedMethodIndex();
    } catch (e) {
      debugPrint("Error loading payment methods: $e");
      paymentMethods.assignAll(_fallbackPaymentMethods());
      _normalizeSelectedMethodIndex();
    } finally {
      isLoadingMethods.value = false;
    }
  }

  void selectAddress(int index) => selectedAddressIndex.value = index;

  void selectMethod(int index) {
    selectedMethodIndex.value = index;
    update();
  }

  void selectWallet(String wallet) => selectedWallet.value = wallet;

  void addAddress(Map<String, String> address) {
    addresses.add(address);
    selectedAddressIndex.value = addresses.length - 1;
  }

  void applyCoupon() {
    if (couponController.text.isEmpty) {
      couponStatus.value = "يرجى إدخال الكود";
      return;
    }
    bool success = cartController.applyCoupon(couponController.text);
    isCouponApplied.value = success;
    couponStatus.value = success ? "تم تطبيق الخصم بنجاح!" : "الكود غير صحيح";
  }

  Future<void> completeOrder() async {
    if (cartController.items.isEmpty) return;

    if (!await _authenticateIfNeeded()) return;

    try {
      isCompletingOrder.value = true;
      final token = _appController.token.value;

      if (token.isEmpty) {
        Get.snackbar(
          "تنبيه",
          "يجب تسجيل الدخول أولاً لإتمام الطلب",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final currentUser = await _appController.ensureUserLoaded();
      if (currentUser == null || currentUser.id <= 0) {
        throw Exception("تعذر تحميل بيانات حسابك، يرجى تسجيل الدخول مرة أخرى");
      }

      final order = isFloosakSelected && _pendingFloosakOrder != null
          ? _pendingFloosakOrder
          : await _apiService.createOrder(_buildOrderData(), token);

      if (order == null) return;

      if (isFloosakSelected) {
        _pendingFloosakOrder = order;
        await _startFloosakPayment(order, token);
        return;
      }

      finalizeSuccessfulOrder(order);
      Get.offAll(() => SuccessPage(order: order));
    } catch (e) {
      debugPrint("Critical Error completing order: $e");
      final cleanError = e.toString().replaceAll("Exception: ", "");

      Get.snackbar(
        "فشل إتمام الطلب",
        "تنبيه السيرفر: $cleanError",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isCompletingOrder.value = false;
    }
  }

  Future<FloosakPaymentAttemptModel> confirmFloosakOtp(
    FloosakPaymentAttemptModel attempt,
    String otp,
  ) async {
    final token = _requireToken();
    return _apiService.confirmFloosakPayment(
      attempt.paymentAttemptId,
      otp,
      token,
    );
  }

  Future<void> confirmActiveFloosakOtp(String otp) async {
    final attempt = activeFloosakAttempt.value;
    if (attempt == null) return;
    if (otp.isEmpty) {
      setFloosakError("يرجى إدخال رمز التحقق");
      return;
    }

    try {
      isConfirmingFloosak.value = true;
      floosakErrorMessage.value = null;
      floosakStatusMessage.value = null;
      floosakOtpController.clear();

      final nextAttempt = await confirmFloosakOtp(attempt, otp);
      _handleActiveFloosakAttempt(
        nextAttempt,
        pendingMessage: "تم إرسال رمز التحقق، وما زالت العملية قيد المعالجة.",
      );
    } catch (e) {
      floosakErrorMessage.value = _cleanError(e);
    } finally {
      if (!isClosed) {
        isConfirmingFloosak.value = false;
      }
    }
  }

  Future<FloosakPaymentAttemptModel> refreshFloosakAttempt(
    FloosakPaymentAttemptModel attempt,
  ) async {
    final token = _requireToken();
    return _apiService.fetchFloosakPaymentStatus(
      attempt.paymentAttemptId,
      token,
    );
  }

  Future<void> refreshActiveFloosakAttempt() async {
    final attempt = activeFloosakAttempt.value;
    if (attempt == null || isFloosakPollInFlight.value) return;

    try {
      isFloosakPollInFlight.value = true;
      final nextAttempt = await refreshFloosakAttempt(attempt);
      _handleActiveFloosakAttempt(nextAttempt);
    } catch (e) {
      floosakErrorMessage.value = _cleanError(e);
    } finally {
      if (!isClosed) {
        isFloosakPollInFlight.value = false;
      }
    }
  }

  void initializeFloosakPayment(
    OrderModel order,
    FloosakPaymentAttemptModel attempt,
  ) {
    if (activeFloosakOrder.value?.id == order.id &&
        activeFloosakAttempt.value?.paymentAttemptId ==
            attempt.paymentAttemptId) {
      if (attempt.isProcessing) {
        startFloosakPolling();
      }
      return;
    }

    activeFloosakOrder.value = order;
    activeFloosakAttempt.value = attempt;
    floosakErrorMessage.value = null;
    floosakStatusMessage.value = null;

    if (attempt.isProcessing) {
      startFloosakPolling();
    } else {
      stopFloosakPolling();
    }
  }

  void setFloosakError(String message) {
    floosakErrorMessage.value = message;
    floosakStatusMessage.value = null;
  }

  void startFloosakPolling() {
    if (_floosakPollTimer != null) return;

    isPollingFloosak.value = true;
    _floosakPollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => refreshActiveFloosakAttempt(),
    );
    refreshActiveFloosakAttempt();
  }

  void stopFloosakPolling() {
    _floosakPollTimer?.cancel();
    _floosakPollTimer = null;
    isPollingFloosak.value = false;
  }

  void finalizeSuccessfulOrder(OrderModel order) {
    if (!_finalizedOrderIds.add(order.id)) return;

    _appController.addNotification(
      title: "تم إتمام الطلب بنجاح",
      body: "طلبك رقم #${order.id} قيد المعالجة الآن وسوف يتم توصيله قريباً.",
      category: "الطلبات",
      color: Colors.green,
    );

    try {
      Get.find<NotificationController>().addNotification(
        "تم إتمام الطلب بنجاح",
        "طلبك رقم #${order.id} قيد المعالجة الآن وسوف يتم توصيله قريباً.",
        category: "الطلبات",
      );
    } catch (_) {}

    try {
      Get.find<PurchaseReportsController>().addOrder(order);
    } catch (e) {
      debugPrint("Failed to update PurchaseReportsController: $e");
    }

    cartController.clearCart();

    try {
      Get.find<ActivitiesController>().logActivity(
        title: "إتمام طلب شراء رقم #${order.id}",
        type: "buy",
      );
    } catch (e) {
      debugPrint("Activity Log Error: $e");
    }

    if (_pendingFloosakOrder?.id == order.id) {
      _pendingFloosakOrder = null;
    }
  }

  Future<bool> _authenticateIfNeeded() async {
    if (!_appController.isBiometricEnabled.value) return true;

    try {
      final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) return true;

      final didAuthenticate = await auth.authenticate(
        localizedReason:
            'يرجى تأكيد هويتك بالبصمة لإتمام عملية الشراء وتأكيد الطلب',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!didAuthenticate) {
        Get.snackbar(
          "تنبيه",
          "فشل التحقق من الهوية، يرجى المحاولة مرة أخرى",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint("Biometric Error: $e");
    }

    return true;
  }

  Map<String, dynamic> _buildOrderData() {
    final user = _appController.user.value;
    if (user == null || user.id <= 0) {
      throw Exception("بيانات المستخدم غير مكتملة، يرجى تسجيل الدخول مرة أخرى");
    }

    return {
      "user_id": user.id,
      "store_id": cartController.items.values.first.product.storeId,
      "products": cartController.items.values
          .map(
            (item) => {
              "product_id": item.product.id,
              "quantity": item.quantity.value,
              "price": item.product.price,
            },
          )
          .toList(),
      "total_price": cartController.totalAmount + cartController.shippingCost,
      "payment_method": selectedPaymentMethod?.id ?? "cash",
      "address": addresses[selectedAddressIndex.value]['address'],
      "city": addresses[selectedAddressIndex.value]['city'] ?? "صنعاء",
    };
  }

  Future<void> _startFloosakPayment(OrderModel order, String token) async {
    // محاكاة النجاح الفوري لفلوسك بناءً على طلب المستخدم
    finalizeSuccessfulOrder(order);
    
    Get.snackbar(
      "نجاح العملية",
      "تم الدفع عبر محفظة فلوسك بنجاح",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );

    // الانتقال مباشرة لصفحة تتبع الطلب
    Get.offAllNamed(
      AppRoutes.TRACKING,
      arguments: order,
    );
  }

  String _requireToken() {
    final token = _appController.token.value;
    if (token.isEmpty) {
      throw Exception("يجب تسجيل الدخول أولاً لإتمام الدفع");
    }

    return token;
  }

  void _handleActiveFloosakAttempt(
    FloosakPaymentAttemptModel nextAttempt, {
    String? pendingMessage,
  }) {
    activeFloosakAttempt.value = nextAttempt;
    floosakErrorMessage.value = null;
    floosakStatusMessage.value = pendingMessage;

    if (nextAttempt.isCompleted) {
      final order = activeFloosakOrder.value;
      if (order == null) return;

      stopFloosakPolling();
      finalizeSuccessfulOrder(order);
      Get.offAll(() => SuccessPage(order: order));
      return;
    }

    if (nextAttempt.isProcessing) {
      startFloosakPolling();
      return;
    }

    if (nextAttempt.isFailed || nextAttempt.isPendingOtp) {
      stopFloosakPolling();
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceAll("Exception: ", "");
  }

  void _normalizeSelectedMethodIndex() {
    if (paymentMethods.isEmpty) {
      selectedMethodIndex.value = 0;
      return;
    }

    if (selectedMethodIndex.value < 0 ||
        selectedMethodIndex.value >= paymentMethods.length) {
      selectedMethodIndex.value = 0;
    }
  }

  List<PaymentMethodModel> _fallbackPaymentMethods() {
    return [
      PaymentMethodModel(
        id: 'wallet',
        name: "المحفظة الإلكترونية",
        description: "جوال، كاش، كريمي موني",
        iconUrl: null,
      ),
      PaymentMethodModel(
        id: 'bank_transfer',
        name: "تحويل بنكي",
        description: "إلى حسابنا في بنك الأمل",
        iconUrl: null,
      ),
      PaymentMethodModel(
        id: 'cash',
        name: "الدفع عند الاستلام",
        description: "الدفع نقداً للمندوب",
        iconUrl: null,
      ),
    ];
  }

  @override
  void onClose() {
    stopFloosakPolling();
    walletPhoneController.dispose();
    couponController.dispose();
    floosakOtpController.dispose();
    super.onClose();
  }
}
