import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/checkout/views/success_page.dart';
import '../controllers/checkout_controller.dart';

class PaymentPage extends GetView<CheckoutController> {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final appController = Get.find<AppController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("وسيلة الدفع",
            style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // الشريط العلوي المستلهم تماماً من AddressPage
          _buildModernProgress(),
          const SizedBox(height: 30),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text(
                  "اختر وسيلة الدفع",
                  style: TextStyle(fontWeight: FontWeight.w900, color: kTextColor, fontSize: 16),
                ),
                const SizedBox(height: 15),

                Obx(() {
                  if (controller.isLoadingMethods.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.paymentMethods.isEmpty) {
                    return const Center(child: Text("لا توجد طرق دفع متاحة"));
                  }
                  return Column(
                    children: List.generate(
                        controller.paymentMethods.length,
                            (index) => _buildPaymentMethod(index)
                    ),
                  );
                }),

                Obx(() {
                  if (controller.selectedMethodIndex.value == 0) {
                    return _buildWalletSection();
                  } else if (controller.selectedMethodIndex.value == 1) {
                    return _buildBankDetails();
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 25),
                _buildCouponInput(),
              ],
            ),
          ),

          _buildBottomAction(cartController, appController),
        ],
      ),
    );
  }

  // شريط التقدم بتصميم مطابق تماماً لـ AddressPage
  Widget _buildModernProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // مرحلة العنوان: مكتملة (تظهر كـ Done)
          _stepNode(Icons.check_circle_rounded, "العنوان", false, isDone: true),
          _stepLine(true), // خط ملون بالأزرق لأنه يتبع مرحلة مكتملة

          // مرحلة الدفع: النشطة حالياً
          _stepNode(Icons.payment_rounded, "الدفع", true),
          _stepLine(false), // خط رمادي للمرحلة القادمة

          // مرحلة التأكيد: غير نشطة
          _stepNode(Icons.assignment_turned_in_rounded, "التأكيد", false),
        ],
      ),
    );
  }

  Widget _stepNode(IconData icon, String label, bool isActive, {bool isDone = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? kPrimaryColor : (isDone ? Colors.white : kBgColor),
            shape: BoxShape.circle,
            border: Border.all(
                color: (isActive || isDone) ? kPrimaryColor : Colors.grey.shade200,
                width: 1.5
            ),
          ),
          child: Icon(
            isDone ? Icons.check : icon,
            color: isActive ? Colors.white : (isDone ? kPrimaryColor : Colors.grey.shade400),
            size: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
              color: (isActive || isDone) ? kTextColor : Colors.grey,
              fontSize: 11,
              fontWeight: (isActive || isDone) ? FontWeight.bold : FontWeight.normal
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22, left: 10, right: 10),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  // تفاصيل بنك الأمل والكويت
  Widget _buildBankDetails() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSecondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kSecondaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "التحويل لحسابنا في بنك الأمل والكويت على الرقم التالي:",
            style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor, fontSize: 14),
          ),
          const SizedBox(height: 15),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("رقم الحساب:", style: TextStyle(fontSize: 14, color: kTextLightColor)),
              Text("123456789", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kPrimaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(int index) {
    final method = controller.paymentMethods[index];
    final isSelected = controller.selectedMethodIndex.value == index;
    return GestureDetector(
      onTap: () => controller.selectMethod(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : kBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? kPrimaryColor : Colors.transparent, width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: kPrimaryColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))] : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? kPrimaryColor : Colors.grey.shade300, width: 2),
                color: isSelected ? kPrimaryColor : Colors.transparent,
              ),
              child: Icon(Icons.check, size: 12, color: isSelected ? Colors.white : Colors.transparent),
            ),
            const SizedBox(width: 20),
            Icon(method.defaultIcon, color: isSelected ? kPrimaryColor : Colors.grey, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (method.description != null)
                    Text(method.description!, style: const TextStyle(fontSize: 12, color: kTextLightColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(CartController cart, AppController app) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Obx(() {
        String currency = "ر.ي";
        try { currency = (app as dynamic).selectedCurrency.value; } catch (e) {}

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("المجموع الإجمالي", style: TextStyle(color: kTextLightColor, fontWeight: FontWeight.bold)),
                Text(
                    "${cart.totalAmount.toStringAsFixed(2)} $currency",
                    style: const TextStyle(fontWeight: FontWeight.w900, color: kSecondaryColor, fontSize: 18)
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: ElevatedButton(
                  onPressed: controller.isCompletingOrder.value 
                  ? null 
                  : () async {
                  final order = await controller.completeOrder();
                  if (order != null) {
                    Get.offAll(() => SuccessPage(order: order));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kPrimaryColor.withOpacity(0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: controller.isCompletingOrder.value 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text("إتمام الدفع وتأكيد الطلب", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40), // Increased from 20 to 40
          ],
        );
      }),
    );
  }

  // تنسيقات إضافية للمحفظة والكوبون متناغمة مع التصميم الجديد
  Widget _buildWalletSection() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kBgColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildWalletDropdown(),
          const SizedBox(height: 15),
          TextField(
            controller: controller.walletPhoneController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: "رقم هاتف المحفظة",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.phone_android, color: kPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.couponController,
            decoration: InputDecoration(
              hintText: "كود الخصم",
              filled: true,
              fillColor: kBgColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: controller.applyCoupon,
          style: ElevatedButton.styleFrom(
            backgroundColor: kSecondaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          ),
          child: const Text("تطبيق", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildWalletDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedWallet.value ?? controller.wallets[0],
      items: controller.wallets.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
      onChanged: (val) => controller.selectWallet(val!),
      decoration: const InputDecoration(border: InputBorder.none),
    ));
  }
}