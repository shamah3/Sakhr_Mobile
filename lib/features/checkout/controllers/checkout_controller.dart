import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/cart_controller.dart';

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
    {'title': 'محافظ إلكترونية', 'icon': Icons.account_balance_wallet_rounded, 'subtitle': 'جوالي، ون كاش، بيس'},
    {'title': 'حوالة مصرفية', 'icon': Icons.account_balance_rounded, 'subtitle': 'الكريمي، النجم، الامتياز'},
    {'title': 'الدفع عند الاستلام', 'icon': Icons.payments_outlined, 'subtitle': 'رسوم إضافية 1000 ر.ي'},
  ];

  final List<String> wallets = ['جوالي (Jawwal Pay)', 'ون كاش (OneCash)', 'بيس (Pyes)'];

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

  void completeOrder() {
    cartController.clearCart();
  }

  @override
  void onClose() {
    walletPhoneController.dispose();
    couponController.dispose();
    super.onClose();
  }
}