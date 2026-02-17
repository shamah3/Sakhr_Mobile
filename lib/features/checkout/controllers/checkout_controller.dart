import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/orders/models/order_model.dart';

class CheckoutController extends GetxController {
  // استخدام lazy find إذا لم يكن موجوداً
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
  var selectedWallet = RxnString();

  // تأكد من تهيئة الـ Controllers
  final walletPhoneController = TextEditingController();
  final couponController = TextEditingController();

  var isCouponApplied = false.obs;
  var couponStatus = "".obs;

  // تعريف النوع بوضوح لتجنب أخطاء الـ Dynamic في الـ UI
  final List<Map<String, dynamic>> methods = [
    {'title': 'محافظ إلكترونية', 'icon': Icons.account_balance_wallet_rounded, 'subtitle': 'جوالي، ون كاش، بيس، جيب'},
    {'title': 'حوالة مصرفية', 'icon': Icons.account_balance_rounded, 'subtitle': 'الكريمي، النجم، الامتياز'},
    {'title': 'الدفع عند الاستلام', 'icon': Icons.payments_outlined, 'subtitle': 'رسوم إضافية 1000 ر.ي'},
  ];

  final List<String> wallets = ['جوالي (Jawwal Pay)', 'ون كاش (OneCash)', 'بيس (Pyes)', 'جيب (Jeeb)'];

  void selectAddress(int index) => selectedAddressIndex.value = index;

  void selectMethod(int index) {
    selectedMethodIndex.value = index;
    // تحديث الواجهة عند تغيير الاختيار
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

  OrderModel? completeOrder() {
    // 1. Create Order
    final cart = cartController;
    if (cart.items.isEmpty) return null;
    
    final orderId = "#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}"; // Simple ID
    final now = DateTime.now();
    final dateStr = "${now.day}/${now.month}";
    
    final order = OrderModel(
      id: orderId,
      dateTime: now,
      status: OrderStatus.pending,
      totalPrice: cart.totalAmount + cart.shippingCost,
      itemCount: cart.items.length,
      shippingAddress: addresses[selectedAddressIndex.value]['address'] ?? "No address",
      itemsNames: cart.items.values.map((e) => e.product.name).toList(),
    );
    
    // 2. Add to Reports
    try {
      Get.find<PurchaseReportsController>().addOrder(order);
    } catch (e) { print(e); }
    
    // 3. Log Activity
    try {
      Get.find<ActivitiesController>().logActivity(
        title: 'إتمام طلب جديد $orderId',
        type: 'buy'
      );
    } catch (e) { print(e); }

    // 4. Clear Cart
    cartController.clearCart();
    
    return order;
  }

  @override
  void onClose() {
    walletPhoneController.dispose();
    couponController.dispose();
    super.onClose();
  }
}