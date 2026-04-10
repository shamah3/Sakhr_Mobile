import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import '../models/payment_method_model.dart';

class CheckoutController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();
  final CartController cartController = Get.find<CartController>();

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
      
      // محاكاة طرق الدفع محلياً بدلاً من الـ API
      final mockMethods = [
        PaymentMethodModel(id: 1, name: "المحفظة الإلكترونية", description: "جوال، كاش، كريمي موني", iconUrl: null),
        PaymentMethodModel(id: 2, name: "تحويل بنكي", description: "إلى حسابنا في بنك الأمل", iconUrl: null),
        PaymentMethodModel(id: 3, name: "الدفع عند الاستلام", description: "الدفع نقداً للمندوب", iconUrl: null),
      ];
      paymentMethods.assignAll(mockMethods);
    } catch (e) {
      debugPrint("Error loading mock payment methods: $e");
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

    try {
      isCompletingOrder.value = true;
      
      // لا يشترط توكن للطلب الوهمي محلياً
      await Future.delayed(const Duration(seconds: 2)); // محاكاة وقت الإرسال

      // محاكاة استجابة الخادم وإنشاء طلب وهمي بنجاح
      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch % 100000, 
        dateTime: DateTime.now(),
        status: OrderStatus.pending,
        totalPrice: cartController.totalAmount + (cartController.shippingCost ?? 0.0),
        itemCount: cartController.items.length,
        shippingAddress: addresses[selectedAddressIndex.value]['address'] ?? "بدون عنوان",
        itemsNames: cartController.items.values.map((e) => e.product.name).toList(),
        productIds: cartController.items.values.map((e) => e.product.id).toList(),
      );

      // Log Activity
      try {
        if (Get.isRegistered<ActivitiesController>()) {
          Get.find<ActivitiesController>().logActivity(
            title: 'إتمام طلب جديد بنجاح (وهمي)',
            type: 'buy'
          );
        }
      } catch (e) {}

      // Clear Cart
      cartController.clearCart();
      
      return order;
    } catch (e) {
      debugPrint("Error completing mock order: $e");
      Get.snackbar("خطأ", "حدث خطأ أثناء إتمام الطلب محلياً", backgroundColor: Colors.redAccent, colorText: Colors.white);
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