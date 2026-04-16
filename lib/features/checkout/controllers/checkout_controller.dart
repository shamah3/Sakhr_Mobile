import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import '../models/payment_method_model.dart';
import 'package:local_auth/local_auth.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import 'package:bytore/features/notifications/controllers/notification_controller.dart';
import '../models/payment_method_model.dart';

class CheckoutController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();
  final CartController cartController = Get.find<CartController>();
  final LocalAuthentication auth = LocalAuthentication();

  // Addressing
  var selectedAddressIndex = 0.obs;
  var addresses = <Map<String, String>>[
    {
      'title': 'المنزل (صنعاء)',
      'name': 'محمد الكبسي',
      'phone': '777123456',
      'address': 'حي حدة، خلف مركز الكميم، عمارة رقم 10',
      'city': 'صنعاء، اليمن'
    },
    {
      'title': 'العمل (عدن)',
      'name': 'محمد الكبسي',
      'phone': '733987654',
      'address': 'خور مكسر، حي السفارات، مبنى الشروق',
      'city': 'عدن، اليمن'
    },
  ].obs;

  // Payment
  var selectedMethodIndex = 0.obs;
  var paymentMethods = <PaymentMethodModel>[].obs;
  var isLoadingMethods = false.obs;
  var selectedWallet = RxnString();

  final walletPhoneController = TextEditingController();
  final couponController = TextEditingController();

  var isCouponApplied = false.obs;
  var couponStatus = "".obs;
  var isCompletingOrder = false.obs;
  var wallets = ["محفظة كاش", "كريمي موني", "جوال"].obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
  }

  Future<void> loadPaymentMethods() async {
    try {
      isLoadingMethods.value = true;
      final methods = await _apiService.fetchPaymentMethods();
      if (methods.isNotEmpty) {
        paymentMethods.assignAll(methods);
      } else {
        // Fallback to mock if API returns empty for now
        final mockMethods = [
          PaymentMethodModel(id: 1, name: "المحفظة الإلكترونية", description: "جوال، كاش، كريمي موني", iconUrl: null),
          PaymentMethodModel(id: 2, name: "تحويل بنكي", description: "إلى حسابنا في بنك الأمل", iconUrl: null),
          PaymentMethodModel(id: 3, name: "الدفع عند الاستلام", description: "الدفع نقداً للمندوب", iconUrl: null),
        ];
        paymentMethods.assignAll(mockMethods);
      }
    } catch (e) {
      debugPrint("Error loading payment methods: $e");
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

  Future<OrderModel?> completeOrder() async {
    if (cartController.items.isEmpty) return null;

    // ✅ الخطوة الأولى: التأكيد بالبصمة قبل إتمام الطلب (في حال تفعيلها)
    if (_appController.isBiometricEnabled.value) {
      try {
        final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
        final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

        if (canAuthenticate) {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'يرجى تأكيد هويتك بالبصمة لإتمام عملية الشراء وتأكيد الطلب',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          );

          if (!didAuthenticate) {
            Get.snackbar("تنبيه", "فشل التحقق من الهوية، يرجى المحاولة مرة أخرى", 
                backgroundColor: Colors.orange, colorText: Colors.white);
            return null;
          }
        }
      } catch (e) {
        debugPrint("Biometric Error: $e");
      }
    }

    try {
      isCompletingOrder.value = true;
      final token = _appController.token.value;
      
      // If no token, we might show a message, but if user wants mock/guest, we handle
      if (token.isEmpty) {
        Get.snackbar("تنبيه", "يجب تسجيل الدخول أولاً لإتمام الطلب", backgroundColor: Colors.orange, colorText: Colors.white);
        return null;
      }

      final orderData = {
        "user_id": _appController.user.value?.id ?? 1, // Get current user ID
        "store_id": cartController.items.values.first.product.storeId, // Get store ID from first item
        "products": cartController.items.values.map((item) => {
          "product_id": item.product.id,
          "quantity": item.quantity.value,
          "price": item.product.price,
        }).toList(),
        "total_price": cartController.totalAmount + (cartController.shippingCost ?? 0.0),
        "payment_method": paymentMethods.isNotEmpty 
            ? paymentMethods[selectedMethodIndex.value].name 
            : "الدفع عند الاستلام",
        "address": addresses[selectedAddressIndex.value]['address'],
        "city": addresses[selectedAddressIndex.value]['city'] ?? "صنعاء", // Send city from addresses
      };

      final order = await _apiService.createOrder(orderData, token);
      
      if (order != null) {
        // Trigger Notification
        _appController.addNotification(
          title: "تم إتمام الطلب بنجاح",
          body: "طلبك رقم #${order.id} قيد المعالجة الآن وسوف يتم توصيله قريباً.",
          category: "الطلبات",
          color: Colors.green,
        );

        // Update Notification Center
        try {
          Get.find<NotificationController>().addNotification(
            "تم إتمام الطلب بنجاح",
            "طلبك رقم #${order.id} قيد المعالجة الآن وسوف يتم توصيله قريباً.",
            category: "الطلبات",
          );
        } catch (_) {}

        // Update purchase reports so it appears instantly
        try {
          Get.find<PurchaseReportsController>().addOrder(order);
        } catch (e) {
          debugPrint("Failed to update PurchaseReportsController: $e");
        }

        // Clear Cart
        cartController.clearCart();
        
        // سجل النشاط: إكمال عملية شراء
        try {
          Get.find<ActivitiesController>().logActivity(
            title: "إتمام طلب شراء رقم #${order.id}",
            type: "buy"
          );
        } catch (e) {
          debugPrint("Activity Log Error: $e");
        }

        return order;
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Critical Error completing order: $e");
      String cleanError = e.toString().replaceAll("Exception: ", "");
      
      Get.snackbar(
        "فشل إتمام الطلب", 
        "تنبيه السيرفر: $cleanError", 
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return null;
    } finally {
      isCompletingOrder.value = false;
    }
  }

  @override
  void onClose() {
    walletPhoneController.dispose();
    couponController.dispose();
    super.onClose();
  }
}